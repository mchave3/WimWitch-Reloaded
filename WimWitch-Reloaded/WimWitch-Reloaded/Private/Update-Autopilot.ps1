<#
.SYNOPSIS
    Update the WindowsAutopilotIntune module.

.DESCRIPTION
    This function is used to update the WindowsAutopilotIntune module.

.NOTES
    Name:        Update-Autopilot.ps1
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
    Update-Autopilot
#>
function Update-Autopilot {
    [CmdletBinding()]
    param(

    )

    process {
        Update-Log -Data 'Uninstalling old WindowsAutopilotIntune module...' -Class Warning
        Uninstall-Module -Name WindowsAutopilotIntune -AllVersions
        Update-Log -Data 'Installing new WindowsAutopilotIntune module...' -Class Warning
        Install-Module -Name WindowsAutopilotIntune -Force
        $AutopilotUpdate = ([System.Windows.MessageBox]::Show('WIM Witch needs to close and PowerShell needs to be restarted. Click OK to close WIM Witch.', 'Updating complete.', 'OK', 'warning'))
        if ($AutopilotUpdate -eq 'OK') {
            $form.Close()
            exit
        }
    }
}
