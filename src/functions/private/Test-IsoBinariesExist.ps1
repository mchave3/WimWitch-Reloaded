<#
.SYNOPSIS
    Test if required ISO creation binaries exist.

.DESCRIPTION
    This function tests if the required ISO creation binaries exist in the imports folder.

.NOTES
    Name:        Test-IsoBinariesExist.ps1
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
    Test-IsoBinariesExist
#>
function Test-IsoBinariesExist {
    [CmdletBinding()]
    param(

    )

    process {
        $buildnum = Get-WinVersionNumber
        $OSType = get-Windowstype

        $ISOFiles = $Script:workdir + '\imports\iso\' + $OSType + '\' + $buildnum + '\'

        Test-Path -Path $ISOFiles\*
        if ((Test-Path -Path $ISOFiles\*) -eq $false) {
            $text = 'ISO Binaries are not present for ' + $OSType + ' ' + $buildnum
            Update-Log -Data $text -Class Warning
            Update-Log -data 'Import ISO Binaries from an ISO or disable ISO/Upgrade Package creation' -Class Warning
            return $false
        }
    }
}
