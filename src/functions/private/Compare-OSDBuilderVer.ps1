<#
.SYNOPSIS
    Compare the OSD Builder version to the current version of the module.

.DESCRIPTION
    This function is used to compare the OSD Builder version to the current version of the module.

.NOTES
    Name:        Compare-OSDBuilderVer.ps1
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
    Compare-OSDBuilderVer
#>
function Compare-OSDBuilderVer {
    [CmdletBinding()]
    param(

    )

    process {
        Update-Log -data 'Comparing OSD Update module versions' -Class Information
        if ($WPFUpdatesOSDBVersion.Text -eq 'Not Installed') {
            Return
        }
        If ($WPFUpdatesOSDBVersion.Text -eq $WPFUpdatesOSDBCurrentVerTextBox.Text) {
            Update-Log -Data 'OSD Update is up to date' -class Information
            Return
        }
        #$WPFUpdatesOSDBOutOfDateTextBlock.Visibility = "Visible"
        $WPFUpdatesOSDListBox.items.add('A software update module is out of date. Please click the Install / Update button to update it.')
        Update-Log -Data 'OSD Update appears to be out of date. Run the upgrade Function from within WIM Witch to resolve' -class Warning
        Return
    }
}
