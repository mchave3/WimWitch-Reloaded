<#
.SYNOPSIS
    Get the OSDSUS installation information.

.DESCRIPTION
    This function is used to get the OSDSUS installation information.

.NOTES
    Name:        Get-WWOSDSUSInstallation.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-27
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Get-WWOSDSUSInstallation
#>
function Get-WWOSDSUSInstallation {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WimWitchLog -Data "Getting OSDSUS Installation information" -Class Information
        try {
            Import-Module -Name OSDSUS -ErrorAction Stop
        } catch {
            $WPFUpdatesOSDSUSVersion.Text = "Not Installed"

            Write-WimWitchLog -Data "OSDSUS is not installed." -Class Warning
            Return
        }
        try {
            $OSDSUSVersion = Get-Module -Name OSDSUS -ErrorAction Stop
            $WPFUpdatesOSDSUSVersion.Text = $OSDSUSVersion.Version
            $text = $osdsusversion.version
            Write-WimWitchLog -data "Installed version of OSDSUS is $text." -Class Information
            Return
        } catch {
            Write-WimWitchLog -Data "Unable to fetch OSDSUS version." -Class Error
            Return
        }
    }
}

