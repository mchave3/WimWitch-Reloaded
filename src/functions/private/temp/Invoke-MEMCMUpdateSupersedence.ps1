<#
.SYNOPSIS
    Check for update supersedence against ConfigMgr.

.DESCRIPTION
    This function checks for update supersedence in ConfigMgr based on the provided
    product and version parameters. It handles different Windows versions and
    manages the supersedence checking process.

.NOTES
    Name:        Invoke-MEMCMUpdateSupersedence.ps1
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
    Invoke-MEMCMUpdateSupersedence -prod "Windows 10" -Ver "21H2"
#>
function Invoke-MEMCMUpdateSupersedence {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$prod,
        
        [Parameter(Mandatory = $true)]
        [string]$Ver
    )

    process {
        Set-Location $CMDrive
        $Arch = 'x64'

        if ($prod -eq 'Windows Server') {
            $updates = Get-CMSoftwareUpdate -Fast -Name "* Server $Ver *$arch*" |
                Where-Object { ($_.IsSuperseded -eq $true) -or ($_.IsExpired -eq $true) }
        }

        if ($prod -eq 'Windows 10') {
            $updates = Get-CMSoftwareUpdate -Fast -Name "*Windows 10*$Ver*$arch*" |
                Where-Object { ($_.IsSuperseded -eq $true) -or ($_.IsExpired -eq $true) }
        }

        if ($prod -eq 'Windows 11') {
            $updates = Get-CMSoftwareUpdate -Fast -Name "*Windows 11*$Ver*$arch*" |
                Where-Object { ($_.IsSuperseded -eq $true) -or ($_.IsExpired -eq $true) }
        }

        foreach ($update in $updates) {
            if ((($update.localizeddisplayname -notlike 'Feature update*') -and 
                 ($update.localizeddisplayname -notlike 'Upgrade to Windows 11*')) -and 
                ($update.localizeddisplayname -notlike '*Language Pack*') -and 
                ($update.localizeddisplayname -notlike '*editions),*')) {
                
                Update-Log -Data 'The following update is superseded:' -Class Information
                Update-Log -data $update.localizeddisplayname -Class Information
                
                $WPFUpdatesSupersededList.Items.Add($update.LocalizedDisplayName)
            }
        }
    }
}
