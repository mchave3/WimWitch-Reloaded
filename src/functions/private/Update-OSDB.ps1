<#
.SYNOPSIS
    Update the OSD Update module.

.DESCRIPTION
    This function is used to update the OSD Update module.

.NOTES
    Name:        Update-OSDB.ps1
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
    Update-OSDB
#>
function Update-OSDB {
    [CmdletBinding()]
    param(

    )

    process {
        if ($WPFUpdatesOSDBVersion.Text -eq 'Not Installed') {
            Update-Log -Data 'Attempting to install and import OSD Update' -Class Information
            try {
                Install-Module OSDUpdate -Force -ErrorAction Stop
                #Write-Host "Installed module"
                Update-Log -data 'OSD Update module has been installed' -Class Information
                Import-Module -Name OSDUpdate -Force -ErrorAction Stop
                #Write-Host "Imported module"
                Update-Log -Data 'OSD Update module has been imported' -Class Information
                Update-Log -Data '****************************************************************************' -Class Warning
                Update-Log -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Update-Log -Data '****************************************************************************' -Class Warning
                #$WPFUpdatesOSDBClosePowerShellTextBlock.visibility = "Visible"
                $WPFUpdatesOSDListBox.items.add('Please close all PowerShell windows, including WIM Witch, then relaunch app to continue')
                Return
            } catch {
                $WPFUpdatesOSDBVersion.Text = 'Inst Fail'
                Update-Log -Data "Couldn't install OSD Update" -Class Error
                Update-Log -data $_.Exception.Message -class Error
                Return
            }
        }
    
        If ($WPFUpdatesOSDBVersion.Text -gt '1.0.0') {
            Update-Log -data 'Attempting to update OSD Update' -class Information
            try {
                Update-ModuleOSDUpdate -ErrorAction Stop
                Update-Log -Data 'Updated OSD Update' -Class Information
                Update-Log -Data '****************************************************************************' -Class Warning
                Update-Log -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Update-Log -Data '****************************************************************************' -Class Warning
                #$WPFUpdatesOSDBClosePowerShellTextBlock.visibility = "Visible"
                $WPFUpdatesOSDListBox.items.add('Please close all PowerShell windows, including WIM Witch, then relaunch app to continue')
    
                get-OSDBInstallation
                return
            } catch {
                $WPFUpdatesOSDBCurrentVerTextBox.Text = 'OSDB Err'
                Return
            }
        }
    }
}
