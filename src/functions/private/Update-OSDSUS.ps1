<#
.SYNOPSIS
    Update the OSDSUS module.

.DESCRIPTION
    This function is used to update the OSDSUS module.

.NOTES
    Name:        Update-OSDSUS.ps1
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
    Update-OSDSUS
#>
function Update-OSDSUS {
    [CmdletBinding()]
    param(

    )

    process {
        if ($WPFUpdatesOSDSUSVersion.Text -eq 'Not Installed') {
            Update-Log -Data 'Attempting to install and import OSDSUS' -Class Information
            try {
                Install-Module OSDUpdate -Force -ErrorAction Stop
                Update-Log -data 'OSDSUS module has been installed' -Class Information
                Import-Module -Name OSDUpdate -Force -ErrorAction Stop
                Update-Log -Data 'OSDSUS module has been imported' -Class Information
                Update-Log -Data '****************************************************************************' -Class Warning
                Update-Log -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Update-Log -Data '****************************************************************************' -Class Warning
                #$WPFUpdatesOSDBClosePowerShellTextBlock.visibility = "Visible"
                $WPFUpdatesOSDListBox.items.add('Please close all PowerShell windows, including WIM Witch, then relaunch app to continue')
                Return
            } catch {
                $WPFUpdatesOSDSUSVersion.Text = 'Inst Fail'
                Update-Log -Data "Couldn't install OSDSUS" -Class Error
                Update-Log -data $_.Exception.Message -class Error
                Return
            }
        }
    
        If ($WPFUpdatesOSDSUSVersion.Text -gt '1.0.0') {
            Update-Log -data 'Attempting to update OSDSUS' -class Information
            try {
                Uninstall-Module -Name osdsus -AllVersions -Force
                Install-Module -Name osdsus -Force
                Update-Log -Data 'Updated OSDSUS' -Class Information
                Update-Log -Data '****************************************************************************' -Class Warning
                Update-Log -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Update-Log -Data '****************************************************************************' -Class Warning
                #$WPFUpdatesOSDBClosePowerShellTextBlock.visibility = "Visible"
                $WPFUpdatesOSDListBox.items.add('Please close all PowerShell windows, including WIM Witch, then relaunch app to continue')
                get-OSDSUSInstallation
                return
            } catch {
                $WPFUpdatesOSDSUSCurrentVerTextBox.Text = 'OSDSUS Err'
                Return
            }
        }
    }
}
