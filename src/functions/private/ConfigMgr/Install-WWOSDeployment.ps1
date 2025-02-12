<#
.SYNOPSIS
    Update the OSD Update module.

.DESCRIPTION
    This function is used to update the OSD Update module.

.NOTES
    Name:        Install-WWOSDeployment.ps1
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
    Install-WWOSDeployment
#>
function Install-WWOSDeployment {
    [CmdletBinding()]
    param(

    )

    process {
        if ($WPFUpdatesOSDBVersion.Text -eq 'Not Installed') {
            Write-WimWitchLog -Data 'Attempting to install and import OSD Update' -Class Information
            try {
                Install-Module OSDUpdate -Force -ErrorAction Stop
                #Write-Host "Installed module"
                Write-WimWitchLog -data 'OSD Update module has been installed' -Class Information
                Import-Module -Name OSDUpdate -Force -ErrorAction Stop
                #Write-Host "Imported module"
                Write-WimWitchLog -Data 'OSD Update module has been imported' -Class Information
                Write-WimWitchLog -Data '****************************************************************************' -Class Warning
                Write-WimWitchLog -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Write-WimWitchLog -Data '****************************************************************************' -Class Warning
                #$WPFUpdatesOSDBClosePowerShellTextBlock.visibility = "Visible"
                $WPFUpdatesOSDListBox.items.add('Please close all PowerShell windows, including WIM Witch, then relaunch app to continue')
                Return
            } catch {
                $WPFUpdatesOSDBVersion.Text = 'Inst Fail'
                Write-WimWitchLog -Data "Couldn't install OSD Update" -Class Error
                Write-WimWitchLog -data $_.Exception.Message -class Error
                Return
            }
        }

        If ($WPFUpdatesOSDBVersion.Text -gt '1.0.0') {
            Write-WimWitchLog -data 'Attempting to update OSD Update' -class Information
            try {
                Update-ModuleOSDUpdate -ErrorAction Stop
                Write-WimWitchLog -Data 'Updated OSD Update' -Class Information
                Write-WimWitchLog -Data '****************************************************************************' -Class Warning
                Write-WimWitchLog -Data 'Please close WIM Witch and all PowerShell windows, then rerun to continue...' -Class Warning
                Write-WimWitchLog -Data '****************************************************************************' -Class Warning
                #$WPFUpdatesOSDBClosePowerShellTextBlock.visibility = "Visible"
                $WPFUpdatesOSDListBox.items.add('Please close all PowerShell windows, including WIM Witch, then relaunch app to continue')

                Get-WWOSDeploymentInstallation
                return
            } catch {
                $WPFUpdatesOSDBCurrentVerTextBox.Text = 'OSDB Err'
                Return
            }
        }
    }
}




