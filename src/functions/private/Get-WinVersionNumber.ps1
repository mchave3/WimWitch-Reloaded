<#
.SYNOPSIS
    Get the Windows version number from the image description.

.DESCRIPTION
    This function extracts the Windows version number from the image description
    by checking against known version patterns for Windows 10, 11, and Server.

.NOTES
    Name:        Get-WinVersionNumber.ps1
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
    Get-WinVersionNumber
#>
function Get-WinVersionNumber {
    [CmdletBinding()]
    param(

    )

    process {
        $buildnum = $null

        # Latest Windows 10 version checks
        switch -Regex ($WPFSourceWimVerTextBox.text) {
            '10\.0\.19045' { $buildnum = '22H2' }
            '10\.0\.19044' { $buildnum = '21H2' }
            '10\.0\.19043' { $buildnum = '21H1' }
            '10\.0\.19042' { $buildnum = '20H2' }
            '10\.0\.19041' { $buildnum = '2004' }
            '10\.0\.18363' { $buildnum = '1909' }
            '10\.0\.18362' { $buildnum = '1903' }
            '10\.0\.17763' { $buildnum = '1809' }
        }

        # Latest Windows 11 version checks
        switch -Regex ($WPFSourceWimVerTextBox.text) {
            '10\.0\.22631' { $buildnum = '23H2' }
            '10\.0\.22621' { $buildnum = '22H2' }
            '10\.0\.22000' { $buildnum = '21H2' }
        }

        # Latest Windows Server version checks
        switch -Regex ($WPFSourceWimVerTextBox.text) {
            '10\.0\.20348' { $buildnum = '2022' }
            '10\.0\.17763' { $buildnum = '2019' }
        }

        return $buildnum
    }
}
