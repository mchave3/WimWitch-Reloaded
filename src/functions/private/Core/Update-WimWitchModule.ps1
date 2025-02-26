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
            #region Get Current Module Version
            # Get current module version - first check if loaded, then check if installed
            $currentModule = Get-Module -Name "WimWitch-Reloaded" |
                Sort-Object Version -Descending |
                Select-Object -First 1

            if (-not $currentModule) {
                # If not found in loaded modules, check available modules
                $currentModule = Get-Module -Name "WimWitch-Reloaded" -ListAvailable |
                    Sort-Object Version -Descending |
                    Select-Object -First 1
            }

            if (-not $currentModule) {
                Write-WimWitchLog -Data "Could not find WimWitch-Reloaded module installed." -Class Error
                return @{
                    Action = "Error"
                    Error = "Module not found"
                }
            }

            $currentVersion = $currentModule.Version
            Write-WimWitchLog -Data "Current WimWitch-Reloaded version: $currentVersion" -Class Information
            #endregion Get Current Module Version

            #region Check for Updates
            # Check online for newer version
            $onlineModule = Find-Module -Name "WimWitch-Reloaded" -ErrorAction Stop
            $onlineVersion = $onlineModule.Version

            # If no update needed, return early
            if (-not ($onlineVersion -gt $currentVersion)) {
                Write-WimWitchLog -Data "WimWitch-Reloaded is already at the latest version" -Class Information
                return @{
                    Action = "Current"
                    Version = $currentVersion
                }
            }
            #endregion Check for Updates

            #region Display Update Dialog
            Write-WimWitchLog -Data "New version available: $onlineVersion" -Class Information

            # Load XAML UI for update prompt
            $inputXML = Get-Content -Path "$PSScriptRoot\resources\UI\WimWitchUpdateDialog.xaml" -Raw

            $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window' -replace 'VersionNumber', $onlineVersion
            [xml]$xaml = $inputXML

            $reader = (New-Object System.Xml.XmlNodeReader $xaml)
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

            # Get named elements from XAML
            $xaml.SelectNodes('//*[@Name]') | ForEach-Object {
                try { Set-Variable -Name "WPF$($_.Name)" -Value $form.FindName($_.Name) -ErrorAction Stop }
                catch { throw }
            }

            # Replace placeholders in content
            $textBlocks = $form.FindName('Grid').Children | Where-Object { $_ -is [System.Windows.Controls.TextBlock] }
            foreach ($textBlock in $textBlocks) {
                $textBlock.Text = $textBlock.Text.Replace('$onlineVersion', $onlineVersion)
            }

            $script:updateModuleChoice = -1

            # Add event handlers for buttons
            $form.FindName('btnYes').Add_Click({
                $script:updateModuleChoice = 0
                $form.Close()
            })

            $form.FindName('btnNo').Add_Click({
                $script:updateModuleChoice = 1
                $form.Close()
            })

            # Show the dialog and wait for user response
            $form.ShowDialog() | Out-Null
            #endregion Display Update Dialog

            #region Process User Choice
            if ($script:updateModuleChoice -eq 0) {
                # User chose to update
                Write-WimWitchLog -Data "Updating WimWitch-Reloaded module..." -Class Information

                # Determine scope based on PowerShell version and admin rights
                if ($PSVersionTable.PSVersion.Major -ge 6) {
                    # PowerShell Core 7+ supports -Scope parameter
                    $scope = if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                        "AllUsers"
                    } else {
                        "CurrentUser"
                    }

                    if ($PSCmdlet.ShouldProcess("WimWitch-Reloaded", "Update module to version $onlineVersion")) {
                        Update-Module -Name "WimWitch-Reloaded" -Force -Scope $scope -ErrorAction Stop
                    }
                } else {
                    # PowerShell 5.1 and earlier don't support -Scope parameter
                    if ($PSCmdlet.ShouldProcess("WimWitch-Reloaded", "Update module to version $onlineVersion")) {
                        Update-Module -Name "WimWitch-Reloaded" -Force -ErrorAction Stop
                    }
                }

                Write-WimWitchLog -Data "WimWitch-Reloaded module has been updated to version $onlineVersion" -Class Information

                return @{
                    Action = "Update"
                    Version = $onlineVersion
                }
            } else {
                # User declined update
                return @{
                    Action = "Declined"
                    Version = $onlineVersion
                }
            }
            #endregion Process User Choice
        } catch {
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
