<#
.SYNOPSIS
    Execute Windows updates on the mounted image.

.DESCRIPTION
    This function will execute Windows updates on the mounted image.

.NOTES
    Name:        Invoke-WWMISUpdate.ps1
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
    Invoke-WWMISUpdate
#>
function Invoke-WWMISUpdate {
    [CmdletBinding()]
    param(

    )

    process {
        $OS = Get-WWWindowsType
        $ver = Get-WWWindowsVersionNumber

        if ($ver -eq '2009') { $ver = '20H2' }

        Invoke-WWConfigManagerUpdateSupersedence -prod $OS -Ver $ver
        Invoke-WWConfigManagerUpdateCatalog -prod $OS -ver $ver

        #fucking 2009 to 20h2
    }
}



