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
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(

    )

    process {
        Set-Location $CMDrive
        $cim = Get-CimInstance -Namespace "root\SMS\Site_$($script:SiteCode)" `
                -ClassName SMS_ImagePackage `
                -ComputerName $script:SiteServer |
                Where-Object { $_.PackageID -eq $WPFCMTBPackageID.text }

        if ($PSCmdlet.ShouldProcess("Distribution Points", "Update images")) {
            Write-WimWitchLog -Data 'Updating images on the Distribution Points...'
            Invoke-CimMethod -InputObject $cim -MethodName "RefreshPkgSource" | Out-Null
        }

        if ($PSCmdlet.ShouldProcess("Image properties", "Refresh from WIM")) {
            Write-WimWitchLog -Data 'Refreshing image proprties from the WIM' -Class Information
            Invoke-CimMethod -InputObject $cim -MethodName "ReloadImageProperties" | Out-Null
        }

        if ($PSCmdlet.ShouldProcess("Image properties", "Update package properties")) {
            Update-WWConfigManagerImageProperty -PackageID $WPFCMTBPackageID.Text
            Save-WWSetting -CM -filename $WPFCMTBPackageID.Text
        }

        Set-Location $script:workingDirectory
    }
}

