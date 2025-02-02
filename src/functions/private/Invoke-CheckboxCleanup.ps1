<#
.SYNOPSIS
    Clean up checkbox states.

.DESCRIPTION
    This function resets checkbox states in the UI to their default values.
    It helps maintain a clean state between operations.

.NOTES
    Name:        Invoke-CheckboxCleanup.ps1
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
    Invoke-CheckboxCleanup
#>
function Invoke-CheckboxCleanup {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Cleaning up checkbox states...' -Class Information
            
            # Reset update checkboxes
            $WPFUSCBEnableUpdates.IsChecked = $false
            $WPFUSCBCheckDynamic.IsChecked = $false
            
            # Reset driver checkboxes
            $WPFDriverCheckBox.IsChecked = $false
            $WPFDriverOfflineCheckBox.IsChecked = $false
            
            # Reset feature checkboxes
            $WPFFeatureCheckBox.IsChecked = $false
            $WPFMISEnableAppxCheckBox.IsChecked = $false
            
            # Reset language checkboxes
            $WPFLPCheckBox.IsChecked = $false
            $WPFLPRemoveCheckBox.IsChecked = $false
            
            Update-Log -Data 'Checkbox states reset successfully' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to clean up checkbox states' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
