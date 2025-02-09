<#
.SYNOPSIS
    Update the OSD Update module.

.DESCRIPTION
    This function is used to update the OSD Update module.

.NOTES
    Name:        Install-OSDB.ps1
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
    Install-OSDB
#>
function Install-OSDB {
    [CmdletBinding()]
    param(

    )

    process {
        if ($WPFUpdatesOSDBVersion.Text -eq 'Not Installed') {
            Write-WWLog -Data 'Attempting to install and import OSD Update' -Class Information
            try {
                Install-Module OSDUpdate -Force -ErrorAction Stop
                #Write-Host "Installed module"
                Write-WWLog -data 'OSD Update module has been installed' -Class Information
                Import-Module -Name OSDUpdate -Force -ErrorAction Stop
                #Write-Host "Imported module"
                Write-WWLog -Data 'OSD Update module has been imported' -Class Information
                Write-WWLog -Data '****************************************************************************' -Class Warning
                Write-WWLog -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Write-WWLog -Data '****************************************************************************' -Class Warning
                #$WPFUpdatesOSDBClosePowerShellTextBlock.visibility = "Visible"
                $WPFUpdatesOSDListBox.items.add('Please close all PowerShell windows, including WIM Witch, then relaunch app to continue')
                Return
            } catch {
                $WPFUpdatesOSDBVersion.Text = 'Inst Fail'
                Write-WWLog -Data "Couldn't install OSD Update" -Class Error
                Write-WWLog -data $_.Exception.Message -class Error
                Return
            }
        }

        If ($WPFUpdatesOSDBVersion.Text -gt '1.0.0') {
            Write-WWLog -data 'Attempting to update OSD Update' -class Information
            try {
                Update-ModuleOSDUpdate -ErrorAction Stop
                Write-WWLog -Data 'Updated OSD Update' -Class Information
                Write-WWLog -Data '****************************************************************************' -Class Warning
                Write-WWLog -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Write-WWLog -Data '****************************************************************************' -Class Warning
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

