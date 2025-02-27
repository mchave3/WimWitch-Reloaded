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
        [Parameter()]
        [switch]$SkipPrompt
    )

    begin {
        Write-WimWitchLog -Data "Starting WimWitch-Reloaded upgrade process" -Class Information
    }

    process {
        try {
            Write-WimWitchLog -Data "Checking for WimWitch-Reloaded module updates..." -Class Information

            # Call the update module function to check for updates
            $updateParams = @{}
            if ($SkipPrompt) {
                Write-WimWitchLog -Data "SkipPrompt specified - passing through to Update-WimWitchModule" -Class Information -Verbose
                $updateParams.Add('SkipPrompt', $true)
            }

            $updateResult = Update-WimWitchModule @updateParams

            if (-not $updateResult) {
                Write-WimWitchLog -Data "No result returned from Update-WimWitchModule" -Class Warning
                return $null
            }

            # Log the detailed results for troubleshooting
            Write-WimWitchLog -Data "Update check result: $($updateResult.Action), Version: $($updateResult.Version)" -Class Information -Verbose
            if ($updateResult.Details) {
                Write-WimWitchLog -Data "Details: $($updateResult.Details)" -Class Information -Verbose
            }

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
                    if ($updateResult.Details) {
                        Write-WimWitchLog -Data "Error details: $($updateResult.Details)" -Class Error -Verbose
                    }
                    return $null
                }
                "Update" {
                    Write-WimWitchLog -Data "Update to version $($updateResult.Version) successful" -Class Information
                    Write-WimWitchLog -Data "Restart is required to complete the upgrade process" -Class Information
                    return "restart"
                }
                "Warning" {
                    Write-WimWitchLog -Data "Warning during update check: $($updateResult.Error)" -Class Warning
                    if ($updateResult.Details) {
                        Write-WimWitchLog -Data "Warning details: $($updateResult.Details)" -Class Warning -Verbose
                    }
                    return $null
                }
                default {
                    Write-WimWitchLog -Data "Unknown result from update check: $($updateResult.Action)" -Class Warning
                    return $null
                }
            }
        }
        catch {
            # Comprehensive error handling
            Write-WimWitchLog -Data "Error in Invoke-WimWitchUpgrade: $_" -Class Error
            Write-WimWitchLog -Data $_.Exception.Message -Class Error -Verbose
            Write-WimWitchLog -Data $_.ScriptStackTrace -Class Error -Verbose
            return $null
        }
    }

    end {
        Write-WimWitchLog -Data "Completed WimWitch-Reloaded upgrade process" -Class Information -Verbose
    }
}

