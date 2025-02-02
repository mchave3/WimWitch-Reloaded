<#
.SYNOPSIS
    Download Microsoft update items from ConfigMgr.

.DESCRIPTION
    This function downloads Microsoft update items from ConfigMgr using the provided
    parameters. It handles the download process and error checking.

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
    Invoke-MSUpdateItemDownload -Path "C:\Updates" -UpdateName "KB123456" -CIID "12345"
#>
function Invoke-MSUpdateItemDownload {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the path to where the update item will be downloaded.')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$UpdateName,

        [Parameter(Mandatory = $true)]
        [string]$CIID
    )

    process {
        try {
            # Get update item instance
            $UpdateItem = Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter "CI_ID = $CIID" -ErrorAction Stop

            if ($null -ne $UpdateItem) {
                # Determine the ContentID instances associated with the update instance
                $UpdateItemContentIDs = Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_CIToContent -ComputerName $global:SiteServer -Filter "CI_ID = $($UpdateItem.CI_ID)" -ErrorAction Stop
                
                if ($null -ne $UpdateItemContentIDs) {
                    foreach ($ContentID in $UpdateItemContentIDs) {
                        # Get the actual content instance
                        $UpdateItemContent = Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_CIContent -ComputerName $global:SiteServer -Filter "ContentID = $($ContentID.ContentID)" -ErrorAction Stop
                        
                        if ($null -ne $UpdateItemContent) {
                            # Build the network path to the update content source
                            $UpdateContent = "$($global:SiteServer)\$($UpdateItemContent.LocationUNC)"
                            
                            # Create the destination path if it doesn't exist
                            if (-not(Test-Path -Path $Path -PathType Container)) {
                                New-Item -Path $Path -ItemType Directory -Force | Out-Null
                            }
                            
                            # Copy update content source file to destination
                            $DestinationFile = Join-Path -Path $Path -ChildPath (Split-Path -Path $UpdateItemContent.LocationUNC -Leaf)
                            Copy-Item -Path $UpdateContent -Destination $DestinationFile -Force
                        }
                    }
                }
                else {
                    Write-Warning -Message "No content IDs found for update: $UpdateName"
                }
            }
            else {
                Write-Warning -Message "Unable to find update item for: $UpdateName"
            }
        }
        catch [System.Exception] {
            Write-Warning -Message "An error occurred while downloading update item '$($UpdateName)'. Error message: $($_.Exception.Message)"
        }
    }
}
