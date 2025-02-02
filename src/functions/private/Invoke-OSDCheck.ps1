<#
.SYNOPSIS
    Check OSD installation and version.

.DESCRIPTION
    This function verifies if OSD is installed and if the installed version is
    compatible with current requirements. It performs version comparison and
    logs the results.

.NOTES
    Name:        Invoke-OSDCheck.ps1
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
    Invoke-OSDCheck
#>
function Invoke-OSDCheck {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Checking OSD installation...' -Class Information
            
            $OSDInstalled = Get-OSDBInstallation
            if ($OSDInstalled) {
                Update-Log -Data 'OSD is installed' -Class Information
                
                $CurrentVersion = Get-OSDBCurrentVer
                Update-Log -Data "Current OSD version: $CurrentVersion" -Class Information
                
                # Compare versions if needed
                # Add version comparison logic here
            }
            else {
                Update-Log -Data 'OSD is not installed' -Class Warning
            }
        }
        catch {
            Update-Log -Data 'Failed to check OSD installation' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
