<#
.SYNOPSIS
    Checks the installed PowerShellGet module version.

.DESCRIPTION
    This script checks the installed PowerShellGet module version on the system.
    It determines if the PowerShellGet module version is compatible with the requirements
    of WimWitch-Reloaded tool. The script is used internally by the application
    to ensure proper functionality in the user's environment.

.NOTES
    Name:        powershellGetVersion.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-27
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded
#>

$script:powershellGetVersion = Get-Module -Name PowerShellGet -ListAvailable |
    Sort-Object -Property Version -Descending |
    Select-Object -First 1