﻿<#
.SYNOPSIS
    List local experience packs in the WPF GUI.

.DESCRIPTION
    This function is used to update the list of local experience packs in the WPF GUI.

.NOTES
    Name:        Select-WWLocalExperiencePack.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Select-WWLocalExperiencePack -winver '1909' -WinOS 'Pro'
#>
function Select-WWLocalExperiencePack {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$winver,
        [Parameter(Mandatory = $true)]
        [string]$WinOS
    )

    process {
        $LPSourceFolder = $Script:workdir + '\imports\lang\' + $WinOS + '\' + $winver + '\' + 'localexperiencepack' + '\'

        $items = (Get-ChildItem -Path $LPSourceFolder | Select-Object -Property Name | Out-GridView -Title 'Select Local Experience Packs' -PassThru)
        foreach ($item in $items) { $WPFCustomLBLEP.Items.Add($item.name) }
    }
}




