<#
.SYNOPSIS
    Return the Windows version based on the WIM version.

.DESCRIPTION
    This function will return the Windows version based on the WIM version.

.NOTES
    Name:        Set-Version.ps1
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
    Set-Version -wimversion '10.0.22621.2428'
#>
function Set-Version {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$wimversion
    )

    begin {
        $version = $null
    }

    process {
        $versionMap = @{
            '10.0.14393' = '1607'
            '10.0.16299' = '1709'
            '10.0.17134' = '1803'
            '10.0.17763' = '1809'
            '10.0.18362' = '1909'
            '10.0.19041' = '2004'
            '10.0.20348' = '21H2'
            '10.0.22000' = '21H2'
            '10.0.22621' = '22H2'
            '10.0.22631' = '23H2'
        }

        foreach ($key in $versionMap.Keys) {
            if ($wimversion -like "$key*") {
                $version = $versionMap[$key]
            }
        }
        if ($null -eq $version) {
            $version = 'Unknown'
        }
        return $version
    }
}
