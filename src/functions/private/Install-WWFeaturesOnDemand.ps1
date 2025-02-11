<#
.SYNOPSIS
    Apply selected Features On Demand to the mounted WIM.

.DESCRIPTION
    This function applies the selected Features On Demand (FODs) to the mounted Windows Image (WIM).
    It handles different Windows versions and their specific requirements.

.NOTES
    Name:        Install-WWFeaturesOnDemand.ps1
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
    Install-WWFeaturesOnDemand
#>
function Install-WWFeaturesOnDemand {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WimWitchLog -data 'Applying Features On Demand...' -Class Information

        $mountdir = $WPFMISMountTextBox.text

        $WinOS = Get-WWWindowsType
        $Winver = Get-WWWindowsVersionNumber

        if (($WinOS -eq 'Windows 10') -and (($winver -eq '20H2') -or ($winver -eq '21H1') -or
            ($winver -eq '2009') -or ($winver -eq '21H2') -or ($winver -eq '22H2'))) {
            $winver = '2004'
        }

        $FODsource = $Script:workdir + '\imports\FODs\' + $winOS + '\' + $Winver + '\'
        $items = $WPFCustomLBFOD.items

        foreach ($item in $items) {
            $text = 'Applying ' + $item
            Write-WimWitchLog -Data $text -Class Information

            try {
                Add-WindowsCapability -Path $mountdir -Name $item -Source $FODsource -ErrorAction Stop |
                    Out-Null
                Write-WimWitchLog -Data 'Injection Successful' -Class Information
            } catch {
                Write-WimWitchLog -data 'Failed to apply Feature On Demand' -Class Error
                Write-WimWitchLog -data $_.Exception.Message -Class Error
            }
        }
        Write-WimWitchLog -Data 'Feature on Demand injections complete' -Class Information
    }
}



