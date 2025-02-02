<#
.SYNOPSIS
    Install WimWitch ConfigMgr console extension.

.DESCRIPTION
    This function installs the WimWitch extension for the Configuration Manager
    console. It handles the installation process and validates the results.

.NOTES
    Name:        Install-WWCMConsoleExtension.ps1
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
    Install-WWCMConsoleExtension
#>
function Install-WWCMConsoleExtension {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Starting WimWitch ConfigMgr console extension installation...' -Class Information
            
            # Get ConfigMgr console path
            $adminUIPath = $env:SMS_ADMIN_UI_PATH
            if (-not $adminUIPath) {
                throw "ConfigMgr console path not found"
            }
            
            # Create extension directory
            $extensionPath = Join-Path -Path $adminUIPath -ChildPath "XmlStorage\Extensions\WimWitch"
            if (-not (Test-Path -Path $extensionPath)) {
                New-Item -Path $extensionPath -ItemType Directory -Force | Out-Null
            }
            
            # Copy extension files
            $sourceFiles = @(
                "WimWitch.xml",
                "WimWitch.ps1"
            )
            
            foreach ($file in $sourceFiles) {
                $sourcePath = Join-Path -Path $PSScriptRoot -ChildPath $file
                $destPath = Join-Path -Path $extensionPath -ChildPath $file
                
                if (Test-Path -Path $sourcePath) {
                    Copy-Item -Path $sourcePath -Destination $destPath -Force
                    Update-Log -Data "Copied extension file: $file" -Class Information
                }
                else {
                    throw "Extension file not found: $sourcePath"
                }
            }
            
            Update-Log -Data 'WimWitch ConfigMgr console extension installed successfully' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to install WimWitch ConfigMgr console extension' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
