<#
.SYNOPSIS
    Download Microsoft update items from ConfigMgr.

.DESCRIPTION
    This function will download Microsoft update items from ConfigMgr.

.NOTES
    Name:        Invoke-MSUpdateItemDownload.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-02
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Invoke-MSUpdateItemDownload -Path 'C:\Temp' -UpdateName 'KB1234567'
#>
function Invoke-MSUpdateItemDownload {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the path to where the update item will be downloaded.')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$UpdateName
    )

    process {
        #write-host $updatename
        #write-host $filepath

        $OptionalUpdateCheck = 0

        #Adding in optional updates

        if ($UpdateName -like '*Adobe*') {
            $UpdateClass = 'AdobeSU'
            $OptionalUpdateCheck = 1
        }
        if ($UpdateName -like '*Microsoft .NET Framework*') {
            $UpdateClass = 'DotNet'
            $OptionalUpdateCheck = 1
        }
        if ($UpdateName -like '*Cumulative Update for .NET Framework*') {
            $OptionalUpdateCheck = 1
            $UpdateClass = 'DotNetCU'
        }
        if ($UpdateName -like '*Cumulative Update for Windows*') {
            $UpdateClass = 'LCU'
            $OptionalUpdateCheck = 1
        }
        if ($UpdateName -like '*Cumulative Update for Microsoft*') {
            $UpdateClass = 'LCU'
            $OptionalUpdateCheck = 1
        }
        if ($UpdateName -like '*Servicing Stack Update*') {
            $OptionalUpdateCheck = 1
            $UpdateClass = 'SSU'
        }
        if ($UpdateName -like '*Dynamic*') {
            $OptionalUpdateCheck = 1
            $UpdateClass = 'Dynamic'
        }

        if ($OptionalUpdateCheck -eq '0') {

            #Update-Log -data "This update appears to be optional. Skipping..." -Class Warning
            #return
            if ($WPFUpdatesCBEnableOptional.IsChecked -eq $True) { 
                Update-Log -data 'This update appears to be optional. Downloading...' -Class Information 
            }
            else {
                Update-Log -data 'This update appears to be optional, but are not enabled for download. Skipping...' `
                -Class Information
                return
            }
            #Update-Log -data "This update appears to be optional. Downloading..." -Class Information

            $UpdateClass = 'Optional'

        }

        if ($UpdateName -like '*Windows 10*') {
            if (($UpdateName -like '* 1903 *') -or ($UpdateName -like '* 1909 *') -or ($UpdateName -like '* 2004 *') -or 
                ($UpdateName -like '* 20H2 *') -or ($UpdateName -like '* 21H1 *') -or ($UpdateName -like '* 21H2 *') -or 
                ($UpdateName -like '* 22H2 *')) { 
                $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10, version 1903 and later'" 
            }
            else { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10'" }
            if ($updateName -like '*Dynamic*') {
                if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True) { 
                    $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10 Dynamic Update'" 
                }
            }
            #else{
            #Update-Log -data "Dynamic updates have not been selected for downloading. Skipping..." -Class Information
            #return
            #}
        }

        if ($UpdateName -like '*Windows 11*') {
            { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 11'" }

            if ($updateName -like '*Dynamic*') {
                if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True) { 
                    $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 11 Dynamic Update'" 
                }
            }

        }

        if (($UpdateName -like '*Windows Server*') -and ($ver -eq '1607')) { 
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2016'" 
        }
        if (($UpdateName -like '*Windows Server*') -and ($ver -eq '1809')) { 
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2019'" 
        }
        if (($UpdateName -like '*Windows Server*') -and ($ver -eq '21H2')) { 
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Microsoft Server operating system-21H2'" 
        }

        $UpdateItem = Get-CimInstance -Namespace "root\SMS\Site_$($Script:SiteCode)" -ClassName SMS_SoftwareUpdate `
            -ComputerName $Script:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | 
            Where-Object { ($_.LocalizedDisplayName -eq $UpdateName) }

        if ($null -ne $UpdateItem) {

            # Determine the ContentID instances associated with the update instance
            $UpdateItemContentIDs = Get-CimInstance -Namespace "root\SMS\Site_$($Script:SiteCode)" `
                -ClassName SMS_CIToContent -ComputerName $Script:SiteServer -Filter "CI_ID = $($UpdateItem.CI_ID)" `
                -ErrorAction Stop
            if ($null -ne $UpdateItemContentIDs) {

                # Account for multiple content ID items
                foreach ($UpdateItemContentID in $UpdateItemContentIDs) {
                    # Get the content files associated with current Content ID
                    $UpdateItemContent = Get-CimInstance -Namespace "root\SMS\Site_$($Script:SiteCode)" `
                        -ClassName SMS_CIContentFiles -ComputerName $Script:SiteServer `
                        -Filter "ContentID = $($UpdateItemContentID.ContentID)" -ErrorAction Stop
                    if ($null -ne $UpdateItemContent) {
                        # Create new custom object for the update content
                        #write-host $UpdateItemContent.filename
                        $PSObject = [PSCustomObject]@{
                            'DisplayName' = $UpdateItem.LocalizedDisplayName
                            'ArticleID'   = $UpdateItem.ArticleID
                            'FileName'    = $UpdateItemContent.filename
                            'SourceURL'   = $UpdateItemContent.SourceURL
                            'DateRevised' = [System.Management.ManagementDateTimeConverter]::ToDateTime($UpdateItem.DateRevised)
                        }

                        $variable = $FilePath + $UpdateClass + '\' + $UpdateName

                        if ((Test-Path -Path $variable) -eq $false) {
                            Update-Log -Data "Creating folder $variable" -Class Information
                            New-Item -Path $variable -ItemType Directory | Out-Null
                            Update-Log -data 'Created folder' -Class Information
                        } else {
                            $testpath = $variable + '\' + $PSObject.FileName

                            if ((Test-Path -Path $testpath) -eq $true) {
                                Update-Log -Data 'Update already exists. Skipping the download...' -Class Information
                                return
                            }
                        }

                        try {
                            Update-Log -Data "Downloading update item content from: $($PSObject.SourceURL)" -Class Information

                            $DNLDPath = $variable + '\' + $PSObject.FileName

                            $WebClient = New-Object -TypeName System.Net.WebClient
                            $WebClient.DownloadFile($PSObject.SourceURL, $DNLDPath)

                            Update-Log -Data "Download completed successfully, renamed file to: $($PSObject.FileName)" -Class Information
                            $ReturnValue = 0
                        } catch [System.Exception] {
                            Update-Log -data "Unable to download update item content. Error message: $($_.Exception.Message)" -Class Error
                            $ReturnValue = 1
                        }
                    } else {
                        Update-Log -data "Unable to determine update content instance for CI_ID: $($UpdateItemContentID.ContentID)" -Class Error
                        $ReturnValue = 1
                    }
                }
            } else {
                Update-Log -Data "Unable to determine ContentID instance for CI_ID: $($UpdateItem.CI_ID)" -Class Error
                $ReturnValue = 1
            }
        } else {
            Update-Log -data "Unable to locate update item from SMS Provider for update type: $($UpdateType)" -Class Error
            $ReturnValue = 2
        }

        # Handle return value from Function
        return $ReturnValue | Out-Null
    }
}
