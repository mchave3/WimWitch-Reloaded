<#
.SYNOPSIS
    Check for updates against ConfigMgr.

.DESCRIPTION
    This function queries ConfigMgr for available updates based on the provided
    product and version parameters. It filters out certain types of updates
    and handles the update checking process.

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
        Set-Location $CMDrive
        $Arch = 'x64'

        if ($prod -eq 'Windows Server') {
            $updates = Get-CMSoftwareUpdate -Fast -Name "* Server $ver *$arch*" |
                Where-Object { ($_.IsSuperseded -eq $false) -and ($_.IsExpired -eq $false) }
        }

        if ($prod -eq 'Windows 10') {
            $updates = Get-CMSoftwareUpdate -Fast -Name "*Windows 10*$ver*$arch*" |
                Where-Object { ($_.IsSuperseded -eq $false) -and ($_.IsExpired -eq $false) }
        }

        if ($prod -eq 'Windows 11') {
            $updates = Get-CMSoftwareUpdate -Fast -Name "*Windows 11*$ver*$arch*" |
                Where-Object { ($_.IsSuperseded -eq $false) -and ($_.IsExpired -eq $false) }
        }

        foreach ($update in $updates) {
            if ((($update.localizeddisplayname -notlike 'Feature update*') -and 
                 ($update.localizeddisplayname -notlike 'Upgrade to Windows 11*')) -and 
                ($update.localizeddisplayname -notlike '*Language Pack*') -and 
                ($update.localizeddisplayname -notlike '*editions),*')) {
                
                Update-Log -Data 'Checking the following update:' -Class Information
                Update-Log -data $update.localizeddisplayname -Class Information
                
                $WPFUpdatesListBox.Items.Add($update.LocalizedDisplayName)
            }
        }
    }
}
