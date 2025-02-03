<#
.SYNOPSIS
    Get information about an existing ConfigMgr image package.

.DESCRIPTION
    This function retrieves information about a ConfigMgr image package
    using its package ID.

.NOTES
    Name:        Get-ImageInfo.ps1
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
    Get-ImageInfo -PackID "ABC00001"
#>
function Get-ImageInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackID
    )

    process {
        Set-Location $CMDrive
        $ImageInfo = Get-CMOperatingSystemImage -Id $PackID
        return $ImageInfo
    }
}
