﻿<#
.SYNOPSIS
    Get the most current OSDSUS version available.

.DESCRIPTION
    This function is used to get the most current version of OSDSUS available on the PowerShell Gallery.

.NOTES
    Name:        Get-WWOSDSUSCurrentVersion.ps1
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
    Get-WWOSDSUSCurrentVersion
#>
function Get-WWOSDSUSCurrentVersion {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WimWitchLog -Data 'Checking for the most current OSDSUS version available' -Class Information
        try {
            $OSDSUSCurrentVer = Find-Module -Name OSDSUS -ErrorAction Stop
            $WPFUpdatesOSDSUSCurrentVerTextBox.Text = $OSDSUSCurrentVer.version
            $text = $OSDSUSCurrentVer.version
            Write-WimWitchLog -data "$text is the most current version" -class Information
            Return
        } catch {
            $WPFUpdatesOSDSUSCurrentVerTextBox.Text = 'Network Error'
            Return
        }
    }
}

