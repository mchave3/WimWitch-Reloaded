<#
.SYNOPSIS
    Display a text notification.

.DESCRIPTION
    This function is used to display a text notification.

.NOTES
    Name:        Send-WWNotification.ps1
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
    Send-WWNotification
#>
function Send-WWNotification {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WimWitchLog -data '*********************************' -class Comment
        Write-WimWitchLog -data '*********************************' -class Comment
    }
}




