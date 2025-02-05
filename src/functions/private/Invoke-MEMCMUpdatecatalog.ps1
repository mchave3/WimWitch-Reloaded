<#
.SYNOPSIS
    Check for updates against ConfigMgr and download them to the working directory.

.DESCRIPTION
    This function will check for updates against ConfigMgr and download them to the working directory.

.NOTES
    Name:        Invoke-MEMCMUpdatecatalog.ps1
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
    Invoke-MEMCMUpdatecatalog -prod "Windows 10" -ver "21H2"
#>
function Invoke-MEMCMUpdatecatalog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$prod,
        
        [Parameter(Mandatory = $true)]
        [string]$ver
    )

    process {
        #set-ConfigMgrConnection
        Set-Location $CMDrive
        $Arch = 'x64'

        if ($prod -eq 'Windows 10') {
            if (($ver -ge '1903') -or ($ver -like '2*')) { 
                $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10, version 1903 and later'" 
            }

            if ($ver -le '1809') { 
                $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10'" 
            }

            $Updates = (Get-CimInstance -Namespace "root\SMS\Site_$($global:SiteCode)" -ClassName SMS_SoftwareUpdate `
                -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | 
                Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$($ver)*$($Arch)*") } )
        }

        if (($prod -like '*Windows Server*') -and ($ver -eq '1607')) {
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2016'"
            $Updates = (Get-CimInstance -CimNamespace "root\SMS\Site_$($global:SiteCode)" -ClassName SMS_SoftwareUpdate `
                -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | 
                Where-Object { 
                    ($_.IsSuperseded -eq $false) -and 
                    ($_.LocalizedDisplayName -notlike '* Next *') -and 
                    ($_.LocalizedDisplayName -notlike '*(1703)*') -and 
                    ($_.LocalizedDisplayName -notlike '*(1709)*') -and 
                    ($_.LocalizedDisplayName -notlike '*(1803)*') 
                })
        }

        if (($prod -like '*Windows Server*') -and ($ver -eq '1809')) {
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2019'"
            $Updates = (Get-CimInstance -CimNamespace "root\SMS\Site_$($global:SiteCode)" -ClassName SMS_SoftwareUpdate `
                -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | 
                Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$($Arch)*") } )
        }

        if (($prod -like '*Windows Server*') -and ($ver -eq '21H2')) {
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Microsoft Server operating system-21H2'"
            $Updates = (Get-CimInstance -CimNamespace "root\SMS\Site_$($global:SiteCode)" -ClassName SMS_SoftwareUpdate `
                -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | 
                Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$($Arch)*") } )
        }

        if ($prod -eq 'Windows 11') {
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 11'"
            if ($ver -eq '21H2') { 
                $Updates = (Get-CimInstance -CimNamespace "root\SMS\Site_$($global:SiteCode)" `
                    -ClassName SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | 
                    Where-Object { 
                        ($_.IsSuperseded -eq $false) -and 
                        ($_.LocalizedDisplayName -like "*Windows 11 for $($Arch)*") 
                    } ) 
            }
            else { 
                $Updates = (Get-CimInstance -CimNamespace "root\SMS\Site_$($global:SiteCode)" `
                    -ClassName SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | 
                    Where-Object { 
                        ($_.IsSuperseded -eq $false) -and 
                        ($_.LocalizedDisplayName -like "*$($ver)*$($Arch)*") 
                    } ) 
            }
        }

        if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True) {
            if ($prod -eq 'Windows 10') { 
                $Updates = $Updates + (Get-CimInstance -CimNamespace "root\SMS\Site_$($global:SiteCode)" `
                    -ClassName SMS_SoftwareUpdate -ComputerName $global:SiteServer `
                    -Filter "LocalizedCategoryInstanceNames = 'Windows 10 Dynamic Update'" -ErrorAction Stop | 
                    Where-Object { 
                        ($_.IsSuperseded -eq $false) -and 
                        ($_.LocalizedDisplayName -like "*$($ver)*$($Arch)*") 
                    } ) 
            }
            if ($prod -eq 'Windows 11') { 
                $Updates = $Updates + (Get-CimInstance -CimNamespace "root\SMS\Site_$($global:SiteCode)" `
                    -ClassName SMS_SoftwareUpdate -ComputerName $global:SiteServer `
                    -Filter "LocalizedCategoryInstanceNames = 'Windows 11 Dynamic Update'" -ErrorAction Stop | 
                    Where-Object { 
                        ($_.IsSuperseded -eq $false) -and 
                        ($_.LocalizedDisplayName -like "*$prod*") -and 
                        ($_.LocalizedDisplayName -like "*$arch*") 
                    } ) 
            }
        }

        if ($null -eq $updates) {
            Update-Log -data 'No updates found. Product is likely not synchronized. Continuing with build...' `
            -class Warning
            Set-Location $global:workdir
            return
        }

        foreach ($update in $updates) {
            if ((($update.localizeddisplayname -notlike 'Feature update*') -and 
            ($update.localizeddisplayname -notlike 'Upgrade to Windows 11*' )) -and 
            ($update.localizeddisplayname -notlike '*Language Pack*') -and 
            ($update.localizeddisplayname -notlike '*editions),*')) {
                Update-Log -Data 'Checking the following update:' -Class Information
                Update-Log -data $update.localizeddisplayname -Class Information
                #write-host "Display Name"
                #write-host $update.LocalizedDisplayName
                #            if ($ver -eq  "20H2"){$ver = "2009"} #Another 20H2 naming work around
                Invoke-MSUpdateItemDownload -FilePath "$global:workdir\updates\$Prod\$ver\" `
                -UpdateName $update.LocalizedDisplayName
            }
        }

        Set-Location $global:workdir
    }
}
