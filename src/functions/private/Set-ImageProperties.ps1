<#
.SYNOPSIS
    Set properties for a ConfigMgr image package.

.DESCRIPTION
    This function sets various properties for a ConfigMgr image package,
    including description, version, and other metadata.

.NOTES
    Name:        Set-ImageProperties.ps1
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
    Set-ImageProperties -PackageID "ABC00001"
#>
function Set-ImageProperties {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageID
    )

    process {
        Set-Location $CMDrive

        try {
            $ImagePackage = Get-CMOperatingSystemImage -Id $PackageID
            
            if ($WPFCMTBDescription.Text.Length -gt 0) {
                $ImagePackage.Description = $WPFCMTBDescription.Text
            }
            
            if ($WPFCMTBImageVer.Text.Length -gt 0) {
                $ImagePackage.ImageOSVersion = $WPFCMTBImageVer.Text
            }
            
            $ImagePackage.Put() | Out-Null
            
            Update-Log -Data 'Image properties updated successfully' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to update image properties' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
