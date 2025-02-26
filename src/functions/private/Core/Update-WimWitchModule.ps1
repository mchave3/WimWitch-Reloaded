<#
.SYNOPSIS
    Updates the WimWitch-Reloaded PowerShell module to the latest version.

.DESCRIPTION
    This function checks for updates to the WimWitch-Reloaded module from the PowerShell Gallery and
    offers to update the module if a newer version is available.

.NOTES
    Name:        Update-WimWitchModule.ps1
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
    Update-WimWitchModule
#>
function Update-WimWitchModule {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Collections.Hashtable])]
    param(

    )

    process {
        try {
            # Get current module version
            $currentModule = Get-Module -Name "WimWitch-Reloaded" -ListAvailable |
                Sort-Object Version -Descending |
                Select-Object -First 1

            if (-not $currentModule) {
                Write-WimWitchLog -Data "Could not find WimWitch-Reloaded module installed." -Class Error
                return @{
                    Action = "Error"
                    Error = "Module not found"
                }
            }

            $currentVersion = $currentModule.Version
            Write-WimWitchLog -Data "Current WimWitch-Reloaded version: $currentVersion" -Class Information

            # Check online for newer version
            $onlineModule = Find-Module -Name "WimWitch-Reloaded" -ErrorAction Stop
            $onlineVersion = $onlineModule.Version

            if ($onlineVersion -gt $currentVersion) {
                Write-WimWitchLog -Data "New version available: $onlineVersion" -Class Information

                # Ask user if they want to update
                $title = "WimWitch-Reloaded Update"
                $message = "A new version of WimWitch-Reloaded is available ($onlineVersion). Would you like to update?"

                $options = @(
                    [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Update the module")
                    [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Skip this update")
                )
                $result = $Host.UI.PromptForChoice($title, $message, $options, 0)

                if ($result -eq 0) {
                    Write-WimWitchLog -Data "Updating WimWitch-Reloaded module..." -Class Information

                    $scope = if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                        "AllUsers"
                    } else {
                        "CurrentUser"
                    }

                    # Remove current module if loaded
                    if (Get-Module -Name "WimWitch-Reloaded") {
                        Remove-Module -Name "WimWitch-Reloaded" -Force -ErrorAction SilentlyContinue
                    }

                    # Update the module
                    if ($PSCmdlet.ShouldProcess("WimWitch-Reloaded", "Update module to version $onlineVersion")) {
                        Update-Module -Name "WimWitch-Reloaded" -Force -Scope $scope -ErrorAction Stop
                    }

                    Write-WimWitchLog -Data "WimWitch-Reloaded module has been updated to version $onlineVersion" -Class Information

                    return @{
                        Action = "Update"
                        Version = $onlineVersion
                    }
                }

                return @{
                    Action = "Declined"
                    Version = $onlineVersion
                }
            } else {
                Write-WimWitchLog -Data "WimWitch-Reloaded is already at the latest version" -Class Information
                return @{
                    Action = "Current"
                    Version = $currentVersion
                }
            }
        } catch {
            Write-WimWitchLog -Data "Error checking for updates: $_" -Class Error
            Write-WimWitchLog -Data $_.Exception.Message -Class Error
            return @{
                Action = "Error"
                Error = $_.Exception.Message
            }
        }
    }
}
