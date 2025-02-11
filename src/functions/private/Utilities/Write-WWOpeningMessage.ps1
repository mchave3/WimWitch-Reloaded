<#
.SYNOPSIS
    Display the opening text of the script.

.DESCRIPTION
    This function is used to display the opening text of the script.

.NOTES
    Name:        Write-WWOpeningMessage.ps1
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
    Write-WWOpeningMessage
#>
function Write-WWOpeningMessage {
    [CmdletBinding()]
    param(

    )

    process {
        Clear-Host
        Write-Output '##########################################################'
        Write-Output ' '
        Write-Output '             ***** Starting WIM Witch *****'
        Write-Output "                      version $WWScriptVer"
        Write-Output ' '
        Write-Output '##########################################################'
        Write-Output ' '
    }
}




