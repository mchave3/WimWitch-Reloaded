<#
.SYNOPSIS
    Get the OSD Update version.

.DESCRIPTION
    This function is used to get the OSD Update version.

.NOTES
    Name:        Get-OSDBInstallation.ps1
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
    Get-OSDBInstallation
#>
function Get-OSDBInstallation {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WWLog -Data "Getting OSD Installation information" -Class Information
        try {
            Import-Module -Name OSDUpdate -ErrorAction Stop
        } catch {
            $WPFUpdatesOSDBVersion.Text = "Not Installed."
            Write-WWLog -Data "OSD Update is not installed." -Class Warning
            Return
        }
        try {
            $OSDBVersion = Get-Module -Name OSDUpdate -ErrorAction Stop
            $WPFUpdatesOSDBVersion.Text = $OSDBVersion.Version
            $text = $osdbversion.version
            Write-WWLog -data "Installed version of OSD Update is $text." -Class Information
            Return
        } catch {
            Write-WWLog -Data "Unable to fetch OSD Update version." -Class Error
            Return
        }
    }
}

