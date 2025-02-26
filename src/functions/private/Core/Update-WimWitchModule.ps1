<#
.SYNOPSIS
    Updates the WimWitch-Reloaded PowerShell module to the latest version.

.DESCRIPTION
    This function checks for updates to the WimWitch-Reloaded module from the PowerShell Gallery and 
    offers to update the module if a newer version is available. It properly handles the module update
    process, ensuring all dependencies are maintained.

.NOTES
    Name:        Update-WimWitchModule.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Update-WimWitchModule
#>
function Update-WimWitchModule {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$NoPrompt
    )

    begin {
        Write-WimWitchLog -Data "Checking for WimWitch-Reloaded module updates..." -Class Information
    }

    process {
        try {
            # Get current module version
            $currentModule = Get-Module -Name "WimWitch-Reloaded" -ListAvailable | 
                Sort-Object Version -Descending | 
                Select-Object -First 1
            
            if (-not $currentModule) {
                Write-WimWitchLog -Data "Could not find WimWitch-Reloaded module installed." -Class Error
                return $false
            }
            
            $currentVersion = $currentModule.Version
            Write-WimWitchLog -Data "Current WimWitch-Reloaded version: $currentVersion" -Class Information

            # Check online for newer version
            $onlineModule = Find-Module -Name "WimWitch-Reloaded" -ErrorAction Stop
            $onlineVersion = $onlineModule.Version

            if ($onlineVersion -gt $currentVersion) {
                Write-WimWitchLog -Data "New version available: $onlineVersion" -Class Information
                
                $updateConfirmed = $false
                if ($NoPrompt) {
                    $updateConfirmed = $true
                } else {
                    # Ask user if they want to update
                    $title = "WimWitch-Reloaded Update"
                    $message = "A new version of WimWitch-Reloaded is available ($onlineVersion). Would you like to update?"
                    
                    if ($Host.UI.PromptForChoice) {
                        $options = @(
                            [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Update the module")
                            [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Skip this update")
                        )
                        $result = $Host.UI.PromptForChoice($title, $message, $options, 0)
                        $updateConfirmed = ($result -eq 0)
                    } else {
                        # Fallback for environments without PromptForChoice
                        $response = Read-Host -Prompt "$message (Y/N)"
                        $updateConfirmed = $response -like "Y*"
                    }
                }

                if ($updateConfirmed -or $Force) {
                    Write-WimWitchLog -Data "Updating WimWitch-Reloaded module..." -Class Information
                    
                    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
                    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
                    $isAdmin = $currentUser.IsInRole($adminRole)
                    
                    # Perform update with appropriate scope
                    $scope = if ($isAdmin) { "AllUsers" } else { "CurrentUser" }
                    
                    # Check if module is imported and remove it first if needed
                    if (Get-Module -Name "WimWitch-Reloaded") {
                        Write-WimWitchLog -Data "Removing current module from session before updating..." -Class Information
                        Remove-Module -Name "WimWitch-Reloaded" -Force -ErrorAction SilentlyContinue
                    }
                    
                    # Update the module
                    Update-Module -Name "WimWitch-Reloaded" -Force -Scope $scope -ErrorAction Stop
                    
                    Write-WimWitchLog -Data "WimWitch-Reloaded module has been updated to version $onlineVersion" -Class Information
                    Write-WimWitchLog -Data "Please restart PowerShell to use the updated module" -Class Warning
                    
                    # If running in GUI mode, notify about restart
                    if ($script:isGUIMode) {
                        $restart = $Host.UI.PromptForChoice(
                            "Module Updated", 
                            "WimWitch-Reloaded has been updated. The application must be restarted to use the new version. Restart now?",
                            @("&Yes", "&No"),
                            0
                        )
                        
                        if ($restart -eq 0) {
                            Write-WimWitchLog -Data "Restarting WimWitch-Reloaded..." -Class Information
                            return @{
                                Action = "Restart"
                                Version = $onlineVersion
                            }
                        }
                    }
                    
                    return @{
                        Action = "Updated"
                        Version = $onlineVersion
                    }
                } else {
                    Write-WimWitchLog -Data "Module update was declined by user" -Class Warning
                    return @{
                        Action = "Declined"
                        Version = $onlineVersion
                    }
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
