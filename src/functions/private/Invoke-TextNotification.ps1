<#
.SYNOPSIS
    Display a text notification.

.DESCRIPTION
    This function displays a text notification in the UI. It can be used to
    show important messages, warnings, or information to the user.

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
        try {
            $WPFNotificationText.Text = "Processing... Please wait."
            Update-Log -Data 'Text notification displayed' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to display text notification' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
