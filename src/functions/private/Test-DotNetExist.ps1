<#
.SYNOPSIS
    Check if the .Net binaries are present in the import folder for the current build of Windows.

.DESCRIPTION
    This function checks if the .Net binaries are present in the import folder for the current build of Windows.

.NOTES
    Name:        Test-DotNetExist.ps1
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
    Test-DotNetExist
#>
function Test-DotNetExist {
    [CmdletBinding()]
    param(

    )

    process {
        $OSType = Get-WindowsType
        #$buildnum = Get-WinVersionNumber
        $buildnum = $WPFSourceWimTBVersionNum.text

        if ($OSType -eq 'Windows 10') {
            if ($buildnum -eq '20H2') { $Buildnum = '2009' }
            $DotNetFiles = "$Script:workdir\imports\DotNet\$buildnum"
        }
        if (($OSType -eq 'Windows 11') -or ($OSType -eq 'Windows Server')) { $DotNetFiles = "$Script:workdir\imports\DotNet\$OSType\$buildnum" }


        Test-Path -Path $DotNetFiles\*
        if ((Test-Path -Path $DotNetFiles\*) -eq $false) {
            $text = '.Net 3.5 Binaries are not present for ' + $buildnum
            Write-WWLog -Data $text -Class Warning
            Write-WWLog -data 'Import .Net from an ISO or disable injection to continue' -Class Warning
            return $false
        }
    }
}

