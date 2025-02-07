<#
.SYNOPSIS
    Select the criteria for Language Packs, Local Experience Packs and Features on Demand.

.DESCRIPTION
    This function is used to select the criteria for Language Packs, Local Experience Packs and Features on Demand.

.NOTES
    Name:        Select-LPFODRequirement.ps1
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
    Select-LPFODRequirement
#>
function Select-LPFODRequirement {
    [CmdletBinding()]
    param(

    )

    process {
        $WinOS = Get-WindowsType
        #$WinVer = Get-WinVersionNumber
        $WinVer = $WPFSourceWimTBVersionNum.text

        if ($WinOS -eq 'Windows 10') {
            if (($Winver -eq '2009') -or ($winver -eq '20H2') -or ($winver -eq '21H1') -or 
                ($winver -eq '21H2') -or ($winver -eq '22H2')) { 
                $winver = '2004' 
            }
        }

        if ($type -eq 'LP') {
            if ((Test-Path -Path "$Script:workdir\imports\Lang\$WinOS\$Winver\LanguagePacks") -eq $false) {
                Update-Log -Data 'Source not found. Please import some language packs and try again' -Class Error
                return
            }
            Select-LanguagePack -winver $Winver -WinOS $WinOS
        }

        If ($type -eq 'LXP') {
            if ((Test-Path -Path "$Script:workdir\imports\Lang\$WinOS\$Winver\localexperiencepack") -eq $false) {
                Update-Log -Data 'Source not found. Please import some Local Experience Packs and try again' -Class Error
                return
            }
            Select-LocalExperiencePack -winver $Winver -WinOS $WinOS
        }

        if ($type -eq 'FOD') {
            if ((Test-Path -Path "$Script:workdir\imports\FODs\$WinOS\$Winver\") -eq $false) {
                Update-Log -Data 'Source not found. Please import some Demanding Features and try again' -Class Error
                return
            }
            Select-FeaturesOnDemand -winver $Winver -WinOS $WinOS
        }
    }
}
