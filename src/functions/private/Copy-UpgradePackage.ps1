<#
.SYNOPSIS
    Copy Windows upgrade package.

.DESCRIPTION
    This function copies Windows upgrade package files to the specified
    destination. It handles file copying and validates the process.

.NOTES
    Name:        Copy-UpgradePackage.ps1
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
    Copy-UpgradePackage
#>
function Copy-UpgradePackage {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Starting upgrade package copy process...' -Class Information
            
            $sourcePath = $WPFSourceWIMSelectWIMTextBox.Text
            $destPath = $WPFMISWimFolderTextBox.Text
            
            if (-not (Test-Path -Path $sourcePath)) {
                throw "Source path not found: $sourcePath"
            }
            
            if (-not (Test-Path -Path $destPath)) {
                New-Item -Path $destPath -ItemType Directory -Force | Out-Null
            }
            
            # Copy files
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            
            Update-Log -Data "Upgrade package copied successfully to: $destPath" -Class Information
        }
        catch {
            Update-Log -Data 'Failed to copy upgrade package' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
