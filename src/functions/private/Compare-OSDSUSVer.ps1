<#
.SYNOPSIS
    Compare the OSDSUS module version to the current version of the module.

.DESCRIPTION
    This function is used to compare the OSDSUS module version to the current version of the module.

.NOTES
    Name:        Compare-OSDSUSVer.ps1
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
    Compare-OSDSUSVer
#>
function Compare-OSDSUSVer {
    [CmdletBinding()]
    param(

    )

    process {
        Update-Log -data 'Comparing OSDSUS module versions' -Class Information
        if ($WPFUpdatesOSDSUSVersion.Text -eq 'Not Installed') {
            Return
        }
        If ($WPFUpdatesOSDSUSVersion.Text -eq $WPFUpdatesOSDSUSCurrentVerTextBox.Text) {
            Update-Log -Data 'OSDSUS is up to date' -class Information
            Return
        }
        #$WPFUpdatesOSDBOutOfDateTextBlock.Visibility = "Visible"
        $WPFUpdatesOSDListBox.items.add('A software update module is out of date. Please click the Install / Update button to update it.') | Out-Null
        Update-Log -Data 'OSDSUS appears to be out of date. Run the upgrade Function from within WIM Witch to resolve' -class Warning
        Return
    }
}
