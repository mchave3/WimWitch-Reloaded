<#
.SYNOPSIS
    Update the options in the Updates tab based on selections.

.DESCRIPTION
    This function manages the enabled/disabled state of various controls
    in the Updates tab based on the selected catalog source and other options.

.NOTES
    Name:        Invoke-UpdateTabOptions.ps1
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
    Invoke-UpdateTabOptions
#>
function Invoke-UpdateTabOptions {
    [CmdletBinding()]
    param(

    )

    process {
        if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'None') {
            $WPFUpdateOSDBUpdateButton.IsEnabled = $false
            $WPFUpdatesW10CatButton.IsEnabled = $false
            $WPFUpdatesS2019CatButton.IsEnabled = $false
            $WPFUpdatesW11CatButton.IsEnabled = $false
            $WPFUpdatesClearSelectionButton.IsEnabled = $false
            $WPFUpdatesDownloadNewSelectionButton.IsEnabled = $false
            $WPFUpdatesDownloadNewSelectionButton.IsEnabled = $false
            $WPFUpdatesSelectAllButton.IsEnabled = $false
            $WPFUpdateOSDBUpdateButton.IsEnabled = $false
            $WPFUpdatesW10CatButton.IsEnabled = $false
            $WPFUpdatesS2019CatButton.IsEnabled = $false
            $WPFUpdatesW11CatButton.IsEnabled = $false
            $WPFUpdatesDownloadNewSelectionButton.IsEnabled = $false
            $WPFUpdatesSelectAllButton.IsEnabled = $false
            $WPFUpdatesClearSelectionButton.IsEnabled = $false
        }

        if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'OSDSUS') {
            $WPFUpdateOSDBUpdateButton.IsEnabled = $false
            $WPFUpdatesW10CatButton.IsEnabled = $true
            $WPFUpdatesS2019CatButton.IsEnabled = $true
            $WPFUpdatesW11CatButton.IsEnabled = $true
            $WPFUpdatesDownloadNewSelectionButton.IsEnabled = $true
            $WPFUpdatesSelectAllButton.IsEnabled = $true
            $WPFUpdatesClearSelectionButton.IsEnabled = $true
        }

        if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'ConfigMgr') {
            $WPFUpdateOSDBUpdateButton.IsEnabled = $false
            $WPFUpdatesW10CatButton.IsEnabled = $true
            $WPFUpdatesS2019CatButton.IsEnabled = $true
            $WPFUpdatesW11CatButton.IsEnabled = $true
            $WPFUpdatesDownloadNewSelectionButton.IsEnabled = $true
            $WPFUpdatesSelectAllButton.IsEnabled = $true
            $WPFUpdatesClearSelectionButton.IsEnabled = $true
        }

        if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'OSDBuilder') {
            $WPFUpdateOSDBUpdateButton.IsEnabled = $true
            $WPFUpdatesW10CatButton.IsEnabled = $false
            $WPFUpdatesS2019CatButton.IsEnabled = $false
            $WPFUpdatesW11CatButton.IsEnabled = $false
            $WPFUpdatesDownloadNewSelectionButton.IsEnabled = $false
            $WPFUpdatesSelectAllButton.IsEnabled = $false
            $WPFUpdatesClearSelectionButton.IsEnabled = $false
        }
    }
}
