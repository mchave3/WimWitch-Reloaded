﻿<#
.SYNOPSIS
    Select ConfigMgr distribution points.

.DESCRIPTION
    This function allows you to select ConfigMgr distribution points or distribution point groups.

.NOTES
    Name:        Select-WWDistributionPoint.ps1
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
    Select-WWDistributionPoint
#>
function Select-WWDistributionPoint {
    [CmdletBinding()]
    param(

    )

    process {
        #set-ConfigMgrConnection
        Set-Location $CMDrive

        if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Points') {

            $SelectedDPs = (Get-CMDistributionPoint -SiteCode $script:sitecode).NetworkOSPath | `
                Out-GridView -Title 'Select Distribution Points' -PassThru
            foreach ($SelectedDP in $SelectedDPs) { $WPFCMLBDPs.Items.Add($SelectedDP) }
        }
        if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Point Groups') {
            $SelectedDPs = (Get-CMDistributionPointGroup).Name | `
                Out-GridView -Title 'Select Distribution Point Groups' -PassThru
            foreach ($SelectedDP in $SelectedDPs) { $WPFCMLBDPs.Items.Add($SelectedDP) }
        }
        Set-Location $script:workingDirectory
    }
}

