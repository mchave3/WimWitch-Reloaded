<#
.SYNOPSIS
    Update the OSDSUS module.

.DESCRIPTION
    This function is used to update the OSDSUS module.

.NOTES
    Name:        Install-OSDSUS.ps1
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
    Install-OSDSUS
#>
function Install-OSDSUS {
    [CmdletBinding()]
    param(

    )

    process {
        if ($WPFUpdatesOSDSUSVersion.Text -eq 'Not Installed') {
            Write-WWLog -Data 'Attempting to install and import OSDSUS' -Class Information
            try {
                Install-Module OSDUpdate -Force -ErrorAction Stop
                Write-WWLog -data 'OSDSUS module has been installed' -Class Information
                Import-Module -Name OSDUpdate -Force -ErrorAction Stop
                Write-WWLog -Data 'OSDSUS module has been imported' -Class Information
                Write-WWLog -Data '****************************************************************************' -Class Warning
                Write-WWLog -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Write-WWLog -Data '****************************************************************************' -Class Warning
                #$WPFUpdatesOSDBClosePowerShellTextBlock.visibility = "Visible"
                $WPFUpdatesOSDListBox.items.add('Please close all PowerShell windows, including WIM Witch, then relaunch app to continue')
                Return
            } catch {
                $WPFUpdatesOSDSUSVersion.Text = 'Inst Fail'
                Write-WWLog -Data "Couldn't install OSDSUS" -Class Error
                Write-WWLog -data $_.Exception.Message -class Error
                Return
            }
        }

        If ($WPFUpdatesOSDSUSVersion.Text -gt '1.0.0') {
            Write-WWLog -data 'Attempting to update OSDSUS' -class Information
            try {
                Uninstall-Module -Name osdsus -AllVersions -Force
                Install-Module -Name osdsus -Force
                Write-WWLog -Data 'Updated OSDSUS' -Class Information
                Write-WWLog -Data '****************************************************************************' -Class Warning
                Write-WWLog -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Write-WWLog -Data '****************************************************************************' -Class Warning
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

