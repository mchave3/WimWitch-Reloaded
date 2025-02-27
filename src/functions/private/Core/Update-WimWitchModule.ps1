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
    Version:     1.0.1
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
        [Parameter()]
        [switch]$SkipPrompt
    )

    process {
        try {
            # Check is PowerShell is running in admin mode
            $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            $isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

            if ($isAdmin) {
                $scope = "AllUsers"
            }
            else {
                $scope = "CurrentUser"
            }

            # Get current version
            $currentModule = Get-Module -Name 'WimWitch-Reloaded' -ListAvailable |
                Sort-Object -Property Version -Descending |
                Select-Object -First 1

            if (-not $currentModule) {
                $currentModule = Get-Module -Name 'WimWitch-Reloaded' |
                    Sort-Object -Property Version -Descending |
                    Select-Object -First 1
            }

            if (-not $currentModule) {
                Write-WimWitchLog -Data "Unable to find current WimWitch-Reloaded version" -Class Warning
                return @{
                    Action = "Error"
                    Error = "Unable to find current WimWitch-Reloaded version"
                }
            }
            
            [version]$currentVersion = $currentModule.Version

            Write-WimWitchLog -Data "Current WimWitch-Reloaded version: $currentVersion" -Class Information

            # Check for online version
            try {
                $onlineModule = Find-Module -Name 'WimWitch-Reloaded' -ErrorAction Stop
                [version]$onlineVersion = $onlineModule.Version
                Write-WimWitchLog -Data "Latest online version: $onlineVersion" -Class Information
            }
            catch {
                Write-WimWitchLog -Data "Unable to check for online version: $_" -Class Warning
                return @{
                    Action = "Error"
                    Error = "Unable to check for online version: $_"
                }
            }

            # Compare versions
            if ($onlineVersion -le $currentVersion) {
                Write-WimWitchLog -Data "You are already running the latest version." -Class Information
                return @{
                    Action = "Current"
                    Version = $currentVersion
                }
            }

            # If skip prompt is set, proceed with update without showing dialog
            if ($SkipPrompt) {
                $script:updateModuleChoice = 0
            }
            else {
                $inputXML = Get-Content -Path "$PSScriptRoot\resources\UI\WimWitchUpdateDialog.xaml" -Raw
                $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window' -replace 'VersionNumber', $onlineVersion
                [xml]$XAML = $inputXML

                $reader = (New-Object System.Xml.XmlNodeReader $XAML)
                try {
                    $form = [Windows.Markup.XamlReader]::Load($reader)
                } catch {
                    Write-Warning @"
Unable to parse XML, with error: $($Error[0])
Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes
(PowerShell cannot process them)
"@
                    throw
                }

                $XAML.SelectNodes('//*[@Name]') | ForEach-Object {
                    try { Set-Variable -Name "WPF$($_.Name)" -Value $form.FindName($_.Name) -ErrorAction Stop }
                    catch { throw }
                }

                $script:updateModuleChoice = -1

                # Add event handlers for buttons
                $btnYes = $form.FindName('btnYes')
                if ($btnYes) {
                    $btnYes.Add_Click({
                        $script:updateModuleChoice = 0
                        $form.Close()
                    })
                }

                $btnNo = $form.FindName('btnNo')
                if ($btnNo) {
                    $btnNo.Add_Click({
                        $script:updateModuleChoice = 1
                        $form.Close()
                    })
                }

                # Show the dialog and wait for user response
                $form.ShowDialog() | Out-Null
            }

            # Process User Choice
            if ($script:updateModuleChoice -eq 0) {
                # User chose to update
                Write-WimWitchLog -Data "Starting update to WimWitch-Reloaded $onlineVersion..." -Class Information

                try {
                    if ($script:powershellGetVersion.Version.Major -eq 1) {
                        if ($PSCmdlet.ShouldProcess("WimWitch-Reloaded", "Update to version $onlineVersion")) {
                            Update-Module -Name WimWitch-Reloaded -Force

                            return @{
                                Action = "Update"
                                Version = $onlineVersion
                            }
                        }
                    }
                    else {
                        if ($PSCmdlet.ShouldProcess("WimWitch-Reloaded", "Update to version $onlineVersion")) {
                            Update-Module -Name WimWitch-Reloaded -Scope $scope -Force

                            return @{
                                Action = "Update"
                                Version = $onlineVersion
                            }
                        }
                    }
                }
                catch {
                    Write-WimWitchLog -Data "Error during update: $_" -Class Error
                    return @{
                        Action = "Error"
                        Error = "Update failed: $_"
                    }
                }
            } 
            else {
                # User declined update
                Write-WimWitchLog -Data "Update to version $onlineVersion declined by user" -Class Information
                return @{
                    Action = "Declined"
                    Version = $onlineVersion
                }
            }
        }
        catch {
            # Error handling
            Write-WimWitchLog -Data "Error checking for updates: $_" -Class Error
            Write-WimWitchLog -Data $_.Exception.Message -Class Error
            return @{
                Action = "Error"
                Error = $_.Exception.Message
            }
        }
    }
}
