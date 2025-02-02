<#
.SYNOPSIS
    Display a random dad joke.

.DESCRIPTION
    This function displays a random dad joke in the log. It's a fun easter egg
    that adds some humor to the image building process.

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
        try {
            $jokes = @(
                "Why don't programmers like nature? It has too many bugs.",
                "Why did the Windows update cross the road? To get to the blue screen!",
                "What do you call a computer that sings? A Dell!",
                "Why was six afraid of seven? Because 7 8 9!",
                "What do you call a bear with no teeth? A gummy bear!",
                "What do you call a fake noodle? An impasta!",
                "Why don't eggs tell jokes? They'd crack up!",
                "What did the grape say when it got stepped on? Nothing, it just let out a little wine!",
                "What do you call a computer floating in the ocean? A Dell rolling in the deep!",
                "Why did the scarecrow win an award? Because he was outstanding in his field!"
            )
            
            $randomJoke = Get-Random -InputObject $jokes
            Update-Log -Data "Dad Joke Time: $randomJoke" -Class Information
        }
        catch {
            Update-Log -Data 'Failed to tell dad joke' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
