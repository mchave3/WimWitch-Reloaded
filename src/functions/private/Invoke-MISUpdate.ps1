<#
.SYNOPSIS
    Execute Windows updates on the mounted image.

.DESCRIPTION
    This function will execute Windows updates on the mounted image.

.NOTES
    Name:        Invoke-MISUpdate.ps1
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
    Invoke-MISUpdate
#>
function Invoke-MISUpdate {
    [CmdletBinding()]
    param(

    )

    process {
        $OS = get-Windowstype
        $ver = Get-WinVersionNumber

        if ($ver -eq '2009') { $ver = '20H2' }

        Invoke-MEMCMUpdateSupersedence -prod $OS -Ver $ver
        Invoke-MEMCMUpdatecatalog -prod $OS -ver $ver

        #fucking 2009 to 20h2
    }
}

