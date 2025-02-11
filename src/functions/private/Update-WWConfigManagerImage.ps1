<#
.SYNOPSIS
    Updates an existing ConfigMgr image package.

.DESCRIPTION
    This function updates an existing ConfigMgr image package.

.NOTES
    Name:        Update-WWConfigManagerImage.ps1
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
    Update-WWConfigManagerImage
#>
function Update-WWConfigManagerImage {
    [CmdletBinding()]
    param(

    )

    process {
        #set-ConfigMgrConnection
        Set-Location $CMDrive
        $cim = Get-CimInstance -Namespace "root\SMS\Site_$($Script:SiteCode)" `
                -ClassName SMS_ImagePackage `
                -ComputerName $Script:SiteServer |
                Where-Object { $_.PackageID -eq $WPFCMTBPackageID.text }

        Write-WimWitchLog -Data 'Updating images on the Distribution Points...'
        Invoke-CimMethod -InputObject $cim -MethodName "RefreshPkgSource" | Out-Null

        Write-WimWitchLog -Data 'Refreshing image proprties from the WIM' -Class Information
        Invoke-CimMethod -InputObject $cim -MethodName "ReloadImageProperties" | Out-Null

        Update-WWConfigManagerImageProperty -PackageID $WPFCMTBPackageID.Text
        Save-WWSettings -CM -filename $WPFCMTBPackageID.Text

        Set-Location $Script:workdir
    }
}



