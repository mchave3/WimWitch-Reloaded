<#
.SYNOPSIS
    This function will check for updates to the WimWitch-Reloaded module and prompt the user
    to upgrade if a new version is available. This is a wrapper around the Update-WimWitchModule
    function that provides backward compatibility with the original upgrade mechanism.

.DESCRIPTION
    This function will check for updates to the WimWitch-Reloaded module and prompt the user
    to upgrade if a new version is available. This is a wrapper around the Update-WimWitchModule
    function that provides backward compatibility with the original upgrade mechanism.

.NOTES
    Name:        Invoke-WimWitchUpgrade.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR:
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Invoke-WimWitchUpgrade
#>
function Invoke-WimWitchUpgrade {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force
    )

    process {
        Write-WimWitchLog -Data "Checking for WimWitch-Reloaded module updates..." -Class Information
        
        # Call the new update module function
        $updateResult = Update-WimWitchModule -NoPrompt:$Force
        
        # Handle the result
        switch ($updateResult.Action) {
            "Updated" {
                Write-WimWitchLog -Data "WimWitch-Reloaded updated to version $($updateResult.Version)" -Class Information
                Write-WimWitchLog -Data "Please restart PowerShell to apply the changes" -Class Warning
                return $true
            }
            "Restart" {
                Write-WimWitchLog -Data "WimWitch-Reloaded updated to version $($updateResult.Version) - restarting..." -Class Information
                # The restart will be handled by the caller
                return "restart"
            }
            "Current" {
                Write-WimWitchLog -Data "WimWitch-Reloaded is already at the latest version ($($updateResult.Version))" -Class Information
                return $false
            }
            "Declined" {
                Write-WimWitchLog -Data "Update to version $($updateResult.Version) declined by user" -Class Information
                return $false
            }
            "Error" {
                Write-WimWitchLog -Data "Error during update check: $($updateResult.Error)" -Class Error
                return $false
            }
            default {
                Write-WimWitchLog -Data "Unknown result from update check" -Class Warning
                return $false
            }
        }
    }
}

