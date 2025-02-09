<#
.SYNOPSIS
    Display a text notification.

.DESCRIPTION
    This function is used to display a text notification.

.NOTES
    Name:        Invoke-TextNotification.ps1
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
    Invoke-TextNotification
#>
function Invoke-TextNotification {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WWLog -data '*********************************' -class Comment
        Write-WWLog -data '*********************************' -class Comment
    }
}
