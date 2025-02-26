<#
.SYNOPSIS
    This function will check for updates to the WimWitch-Reloaded module and update if needed.

.DESCRIPTION
    This function will check for updates to the WimWitch-Reloaded module and update if available.
    It also handles creating a backup before updating and provides a smooth upgrade experience.

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
    [OutputType([System.String])]
    param(

    )

    process {
        Write-WimWitchLog -Data "Checking for WimWitch-Reloaded module updates..." -Class Information

        # Call the update module function to check for updates
        $updateResult = Update-WimWitchModule

        # Handle the result
        switch ($updateResult.Action) {
            "Current" {
                Write-WimWitchLog -Data "WimWitch-Reloaded is already at the latest version ($($updateResult.Version))" -Class Information
                return $null
            }
            "Declined" {
                Write-WimWitchLog -Data "Update to version $($updateResult.Version) declined by user" -Class Information
                return $null
            }
            "Error" {
                Write-WimWitchLog -Data "Error during update check: $($updateResult.Error)" -Class Error
                return $null
            }
            "Update" {
                # Create backup before updating
                Write-WimWitchLog -Data "Creating backup before updating to version $($updateResult.Version)..." -Class Information
                $backupPath = Backup-WimWitch -Full

                if ($backupPath) {
                    Write-WimWitchLog -Data "Backup created successfully at: $backupPath" -Class Information

                    # Perform update - the Update-WimWitchModule will have set up everything for restarting
                    return "restart"
                } else {
                    Write-WimWitchLog -Data "Failed to create backup. Update cancelled." -Class Error
                    return $null
                }
            }
            default {
                Write-WimWitchLog -Data "Unknown result from update check" -Class Warning
                return $null
            }
        }
    }
}

