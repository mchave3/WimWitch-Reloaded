<#
.SYNOPSIS
    Display a random dad joke.

.DESCRIPTION
    This function displays a random dad joke in the log. It's a fun easter egg that adds some humor to the image building process.

.NOTES
    Name:        Invoke-DadJoke.ps1
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
    Invoke-DadJoke
#>
function Invoke-DadJoke {
    [CmdletBinding()]
    param(

    )

    process {
        $header = @{accept = 'Application/json' }
        $joke = Invoke-RestMethod -Uri 'https://icanhazdadjoke.com' -Method Get -Headers $header
        return $joke.joke
    }
}

