<#
.SYNOPSIS
    Display a closing message to the user.

.DESCRIPTION
    This function is used to display a closing message to the user.

.NOTES
    Name:        Write-WWClosingMessage.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-27
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Write-WWClosingMessage
#>
function Write-WWClosingMessage {
    [CmdletBinding()]
    param(

    )

    process {
        Write-Host ' '
        Write-Host '##########################################################'
        Write-Host ' '
        Write-Host 'Thank you for using WimWitch Reloaded.'
        Write-Host ' '
        Write-Host '##########################################################'
    }
}

