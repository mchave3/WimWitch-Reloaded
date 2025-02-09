<#
.SYNOPSIS
    Reset the MIS checkboxes.

.DESCRIPTION
    This function is used to reset the MIS checkboxes.

.NOTES
    Name:        Refresh-WWMISCheckBox.ps1
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
    Refresh-WWMISCheckBox
#>
function Refresh-WWMISCheckBox {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WWLog -data 'Refreshing MIS Values...' -class Information

        If ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
            $WPFJSONButton.IsEnabled = $True
            $WPFMISJSONTextBox.Text = 'True'
        }
        If ($WPFDriverCheckBox.IsChecked -eq $true) {
            $WPFDriverDir1Button.IsEnabled = $True
            $WPFDriverDir2Button.IsEnabled = $True
            $WPFDriverDir3Button.IsEnabled = $True
            $WPFDriverDir4Button.IsEnabled = $True
            $WPFDriverDir5Button.IsEnabled = $True
            $WPFMISDriverTextBox.Text = 'True'
        }
        If ($WPFUpdatesEnableCheckBox.IsChecked -eq $true) {
            $WPFMISUpdatesTextBox.Text = 'True'
        }
        If ($WPFAppxCheckBox.IsChecked -eq $true) {
            $WPFAppxButton.IsEnabled = $True
            $WPFMISAppxTextBox.Text = 'True'
        }
        If ($WPFCustomCBEnableApp.IsChecked -eq $true) { $WPFCustomBDefaultApp.IsEnabled = $True }
        If ($WPFCustomCBEnableStart.IsChecked -eq $true) { $WPFCustomBStartMenu.IsEnabled = $True }
        If ($WPFCustomCBEnableRegistry.IsChecked -eq $true) {
            $WPFCustomBRegistryAdd.IsEnabled = $True
            $WPFCustomBRegistryRemove.IsEnabled = $True
        }
    }
}

