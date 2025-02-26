<#
.SYNOPSIS
    Update the options in the Updates tab based on selections.

.DESCRIPTION
    This function manages the enabled/disabled state of various controls in the Updates tab based on the selected catalog source and other options.

.NOTES
    Name:        Update-WWTabOption.ps1
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
    Update-WWTabOption
#>
function Update-WWTabOption {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(

    )

    process {
        if ($PSCmdlet.ShouldProcess("Tab options", "Update based on catalog source")) {
            if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'None' ) {

                $WPFUpdateOSDBUpdateButton.IsEnabled = $false
                $WPFUpdatesDownloadNewButton.IsEnabled = $false
                $WPFUpdatesW10Main.IsEnabled = $false
                $WPFUpdatesS2019.IsEnabled = $false
                $WPFUpdatesS2016.IsEnabled = $false

                $WPFMISCBCheckForUpdates.IsEnabled = $false
                $WPFMISCBCheckForUpdates.IsChecked = $false
            }
            if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'OSDSUS') {
                $WPFUpdateOSDBUpdateButton.IsEnabled = $true
                $WPFUpdatesDownloadNewButton.IsEnabled = $true
                $WPFUpdatesW10Main.IsEnabled = $true
                $WPFUpdatesS2019.IsEnabled = $true
                $WPFUpdatesS2016.IsEnabled = $true

                $WPFMISCBCheckForUpdates.IsEnabled = $false
                $WPFMISCBCheckForUpdates.IsChecked = $false
                Write-WimWitchLog -data 'OSDSUS selected as update catalog' -class Information
                Invoke-WWOSDCheck

            }
            if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'ConfigMgr') {
                $WPFUpdateOSDBUpdateButton.IsEnabled = $false
                $WPFUpdatesDownloadNewButton.IsEnabled = $true
                $WPFUpdatesW10Main.IsEnabled = $true
                $WPFUpdatesS2019.IsEnabled = $true
                $WPFUpdatesS2016.IsEnabled = $true
                $WPFMISCBCheckForUpdates.IsEnabled = $true
                #   $MEMCMsiteinfo = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification"
                #   $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
                #   $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'
                Write-WimWitchLog -data 'ConfigMgr is selected as the update catalog' -Class Information
            }
        }
    }
}

