<#
.SYNOPSIS
    Test if required ISO creation binaries exist.

.DESCRIPTION
    This function tests if the required ISO creation binaries exist in the imports folder.

.NOTES
    Name:        Test-WWISOBinariesExist.ps1
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
    Test-WWISOBinariesExist
#>
function Test-WWISOBinariesExist {
    [CmdletBinding()]
    [OutputType([bool])]
    param(

    )

    process {
        $buildnum = Get-WWWindowsVersionNumber
        $OSType = Get-WWWindowsType

        $ISOFiles = $Script:workdir + '\imports\iso\' + $OSType + '\' + $buildnum + '\'

        Test-Path -Path $ISOFiles\*
        if ((Test-Path -Path $ISOFiles\*) -eq $false) {
            $text = 'ISO Binaries are not present for ' + $OSType + ' ' + $buildnum
            Write-WimWitchLog -Data $text -Class Warning
            Write-WimWitchLog -data 'Import ISO Binaries from an ISO or disable ISO/Upgrade Package creation' -Class Warning
            return $false
        }
    }
}



