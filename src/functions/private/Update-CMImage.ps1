<#
.SYNOPSIS
    Updates an existing ConfigMgr image package.

.DESCRIPTION
    This function updates an existing ConfigMgr image package.

.NOTES
    Name:        Update-CMImage.ps1
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
    Update-CMImage
#>
function Update-CMImage {
    [CmdletBinding()]
    param(

    )

    process {
        #set-ConfigMgrConnection
        Set-Location $CMDrive
        $wmi = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_ImagePackage -ComputerName $global:SiteServer) | Where-Object { $_.PackageID -eq $WPFCMTBPackageID.text }

        Update-Log -Data 'Updating images on the Distribution Points...'
        $WMI.RefreshPkgSource() | Out-Null

        Update-Log -Data 'Refreshing image proprties from the WIM' -Class Information
        $WMI.ReloadImageProperties() | Out-Null

        Set-ImageProperties -PackageID $WPFCMTBPackageID.Text
        Save-Configuration -CM -filename $WPFCMTBPackageID.Text

        Set-Location $global:workdir
    }
}
