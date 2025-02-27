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
        [Parameter()]
        [switch]$SkipPrompt
    )

    begin {
        Write-WimWitchLog -Data "Starting WimWitch-Reloaded update check" -Class Information
    }

    process {
        try {
            # Check if PowerShell is running in admin mode
            $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            $isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

            $scope = if ($isAdmin) { "AllUsers" } else { "CurrentUser" }
            Write-WimWitchLog -Data "PowerShell running with admin rights: $isAdmin. Using scope: $scope" -Class Information -Verbose

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
                $errorMsg = "Unable to find current WimWitch-Reloaded version"
                Write-WimWitchLog -Data $errorMsg -Class Error
                return @{
                    Action = "Error"
                    Error = $errorMsg
                    Details = "Module not found in either ListAvailable or loaded modules"
                }
            }

            [version]$currentVersion = $currentModule.Version
            Write-WimWitchLog -Data "Current WimWitch-Reloaded version: $currentVersion" -Class Information

            # Check for online version
            try {
                Write-WimWitchLog -Data "Searching for WimWitch-Reloaded in PowerShell Gallery..." -Class Information -Verbose
                $onlineModule = Find-Module -Name 'WimWitch-Reloaded' -ErrorAction Stop
                [version]$onlineVersion = $onlineModule.Version
                Write-WimWitchLog -Data "Latest online version: $onlineVersion" -Class Information
            }
            catch {
                $errorMsg = "Unable to check for online version: $_"
                Write-WimWitchLog -Data $errorMsg -Class Warning
                return @{
                    Action = "Error"
                    Error = $errorMsg
                    Details = $_.Exception.Message
                }
            }

            # Compare versions
            if ($onlineVersion -le $currentVersion) {
                Write-WimWitchLog -Data "You are already running the latest version ($currentVersion)" -Class Information
                return @{
                    Action = "Current"
                    Version = $currentVersion
                    Details = "No update needed"
                }
            }

            # If skip prompt is set, proceed with update without showing dialog
            if ($SkipPrompt) {
                $script:updateModuleChoice = 0
                Write-WimWitchLog -Data "SkipPrompt specified - proceeding with update automatically" -Class Information -Verbose
            }
            else {
                try {
                    $inputXML = Get-Content -Path "$PSScriptRoot\resources\UI\WimWitchUpdateDialog.xaml" -Raw -ErrorAction Stop
                    $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window' -replace 'VersionNumber', $onlineVersion
                    [xml]$XAML = $inputXML

                    $reader = (New-Object System.Xml.XmlNodeReader $XAML)
                    try {
                        $form = [Windows.Markup.XamlReader]::Load($reader)
                    }
                    catch {
                        $errorMsg = "Error loading XAML: $_"
                        Write-WimWitchLog -Data $errorMsg -Class Error
                        return @{
                            Action = "Error"
                            Error = $errorMsg
                            Details = $_.Exception.Message
                        }
                    }

                    $XAML.SelectNodes('//*[@Name]') | ForEach-Object {
                        try {
                            Set-Variable -Name "WPF$($_.Name)" -Value $form.FindName($_.Name) -ErrorAction Stop
                        }
                        catch {
                            $errorMsg = "Error finding UI element $($_.Name): $_"
                            Write-WimWitchLog -Data $errorMsg -Class Warning
                        }
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
                    Write-WimWitchLog -Data "Showing update confirmation dialog for version $onlineVersion" -Class Information -Verbose
                    $form.ShowDialog() | Out-Null
                }
                catch {
                    $errorMsg = "Error displaying update dialog: $_"
                    Write-WimWitchLog -Data $errorMsg -Class Error
                    return @{
                        Action = "Error"
                        Error = $errorMsg
                        Details = $_.Exception.Message
                    }
                }
            }

            # Process User Choice
            if ($script:updateModuleChoice -eq 0) {
                # User chose to update
                Write-WimWitchLog -Data "Starting update to WimWitch-Reloaded $onlineVersion..." -Class Information

                try {
                    if ($PSCmdlet.ShouldProcess("WimWitch-Reloaded", "Update to version $onlineVersion")) {
                        Write-WimWitchLog -Data "Updating module with scope: $scope" -Class Information -Verbose

                        if ($script:powershellGetVersion.Version.Major -eq 1) {
                            Update-Module -Name WimWitch-Reloaded -Force -ErrorAction Stop
                        }
                        else {
                            Update-Module -Name WimWitch-Reloaded -Scope $scope -Force -ErrorAction Stop
                        }

                        # Verify installation was successful
                        $updatedModule = Get-Module -Name 'WimWitch-Reloaded' -ListAvailable |
                            Sort-Object -Property Version -Descending |
                            Select-Object -First 1

                        if ($updatedModule -and $updatedModule.Version -ge $onlineVersion) {
                            Write-WimWitchLog -Data "Module successfully updated to version $($updatedModule.Version)" -Class Information
                            return @{
                                Action = "Update"
                                Version = $updatedModule.Version
                                Details = "Updated from $currentVersion to $($updatedModule.Version)"
                            }
                        }
                        else {
                            $warningMsg = "Module update may not have completed successfully. Expected version $onlineVersion, found $($updatedModule.Version)"
                            Write-WimWitchLog -Data $warningMsg -Class Warning
                            return @{
                                Action = "Warning"
                                Error = $warningMsg
                                Version = $updatedModule.Version
                                Details = "Version mismatch after update"
                            }
                        }
                    }
                }
                catch {
                    $errorMsg = "Error during module update: $_"
                    Write-WimWitchLog -Data $errorMsg -Class Error
                    Write-WimWitchLog -Data $_.Exception.Message -Class Error -Verbose
                    return @{
                        Action = "Error"
                        Error = $errorMsg
                        Details = $_.Exception.Message
                    }
                }
            }
            else {
                # User declined update
                Write-WimWitchLog -Data "Update to version $onlineVersion declined by user" -Class Information
                return @{
                    Action = "Declined"
                    Version = $onlineVersion
                    Details = "User opted not to update from $currentVersion"
                }
            }
        }
        catch {
            # Error handling
            $errorMsg = "Unexpected error checking for updates: $_"
            Write-WimWitchLog -Data $errorMsg -Class Error
            Write-WimWitchLog -Data $_.Exception.Message -Class Error -Verbose
            Write-WimWitchLog -Data $_.ScriptStackTrace -Class Error -Verbose
            return @{
                Action = "Error"
                Error = $errorMsg
                Details = $_.Exception.Message
                StackTrace = $_.ScriptStackTrace
            }
        }
    }

    end {
        Write-WimWitchLog -Data "Completed WimWitch-Reloaded update check" -Class Information -Verbose
    }
}
