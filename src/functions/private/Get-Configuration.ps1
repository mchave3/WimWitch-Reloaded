<#
.SYNOPSIS
    Import the WimWitch configuration from a file.

.DESCRIPTION
    This function is used to import the WimWitch configuration from a file.

.NOTES
    Name:        Get-Configuration.ps1
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
    Get-Configuration -filename "C:\path\to\config.xml"
#>
function Get-Configuration {
    [CmdletBinding()]
    param(
        # Path to the configuration file to import
        [Parameter(Mandatory = $true)]
        [string]$filename
    )

    process {
        # Log the start of configuration import
        Update-Log -data "Importing config from $filename" -Class Information
        try {
            # Import the XML configuration file
            $settings = Import-Clixml -Path $filename -ErrorAction Stop
            Update-Log -data 'Config file read...' -Class Information

            # Set source WIM configuration
            $WPFSourceWIMSelectWIMTextBox.text = $settings.SourcePath
            $WPFSourceWimIndexTextBox.text = $settings.SourceIndex
            $WPFSourceWIMImgDesTextBox.text = $settings.SourceEdition

            # Configure update settings
            $WPFUpdatesEnableCheckBox.IsChecked = $settings.UpdatesEnabled
            # Set Autopilot configuration
            $WPFJSONEnableCheckBox.IsChecked = $settings.AutopilotEnabled
            $WPFJSONTextBox.text = $settings.AutopilotPath

            # Configure driver settings
            $WPFDriverCheckBox.IsChecked = $settings.DriversEnabled
            $WPFDriverDir1TextBox.text = $settings.DriverPath1
            $WPFDriverDir2TextBox.text = $settings.DriverPath2
            $WPFDriverDir3TextBox.text = $settings.DriverPath3
            $WPFDriverDir4TextBox.text = $settings.DriverPath4
            $WPFDriverDir5TextBox.text = $settings.DriverPath5

            # Configure AppX packages
            $WPFAppxCheckBox.IsChecked = $settings.AppxIsEnabled
            $WPFAppxTextBox.text = $settings.AppxSelected -split ' '
            $Script:SelectedAppx = $settings.AppxSelected -split ' '

            # Set WIM configuration
            $WPFMISWimNameTextBox.text = $settings.WIMName
            $WPFMISWimFolderTextBox.text = $settings.WIMPath
            $WPFMISMountTextBox.text = $settings.MountPath

            # Configure general features
            $WPFMISDotNetCheckBox.IsChecked = $settings.DotNetEnabled
            $WPFMISOneDriveCheckBox.IsChecked = $settings.OneDriveEnabled
            $WPFMISCBPauseMount.IsChecked = $settings.PauseAfterMount
            $WPFMISCBPauseDismount.IsChecked = $settings.PauseBeforeDM

            # Configure language and feature settings
            $WPFCustomCBLangPacks.IsChecked = $settings.LPsEnabled
            $WPFCustomCBLEP.IsChecked = $settings.LXPsEnabled
            $WPFCustomCBFOD.IsChecked = $settings.FODsEnabled

            # Configure script settings
            $WPFCustomCBRunScript.IsChecked = $settings.RunScript
            $WPFCustomCBScriptTiming.SelectedItem = $settings.ScriptTiming
            $WPFCustomTBFile.Text = $settings.ScriptFile
            $WPFCustomTBParameters.Text = $settings.ScriptParams

            # Configure ConfigMgr settings
            $WPFCMCBImageType.SelectedItem = $settings.CMImageType
            $WPFCMTBPackageID.Text = $settings.CMPackageID
            $WPFCMTBImageName.Text = $settings.CMImageName
            $WPFCMTBImageVer.Text = $settings.CMVersion
            $WPFCMTBDescription.Text = $settings.CMDescription
            $WPFCMCBBinDirRep.IsChecked = $settings.CMBinDifRep
            $WPFCMTBSitecode.Text = $settings.CMSiteCode
            $WPFCMTBSiteServer.Text = $settings.CMSiteServer
            $WPFCMCBDPDPG.SelectedItem = $settings.CMDPGroup
            $WPFCMCBImageVerAuto.IsChecked = $settings.AutoFillVersion
            $WPFCMCBDescriptionAuto.IsChecked = $settings.AutoFillDesc

            # Configure update settings
            $WPFUSCBSelectCatalogSource.SelectedItem = $settings.UpdateSource
            $WPFMISCBCheckForUpdates.IsChecked = $settings.UpdateMIS
            $WPFUpdatesCBEnableOptional.IsChecked = $settings.SUOptional
            $WPFUpdatesCBEnableDynamic.IsChecked = $settings.SUDynamic
            $WPFMISCBDynamicUpdates.IsChecked = $settings.ApplyDynamicCB
            $WPFUpdatesOptionalEnableCheckBox.IsChecked = $settings.IncludeOptionCB

            # Configure customization settings
            $WPFCustomCBEnableApp.IsChecked = $settings.DefaultAppCB
            $WPFCustomTBDefaultApp.Text = $settings.DefaultAppPath
            $WPFCustomCBEnableStart.IsChecked = $settings.StartMenuCB
            $WPFCustomTBStartMenu.Text = $settings.StartMenuPath
            $WPFCustomCBEnableRegistry.IsChecked = $settings.RegFilesCB

            # Configure output settings
            $WPFMISCBBootWIM.IsChecked = $settings.UpdateBootCB
            $WPFMISCBNoWIM.IsChecked = $settings.DoNotCreateWIMCB
            $WPFMISCBISO.IsChecked = $settings.CreateISO
            $WPFMISTBISOFileName.Text = $settings.ISOFileName
            $WPFMISTBFilePath.Text = $settings.ISOFilePath
            $WPFMISCBUpgradePackage.IsChecked = $settings.UpgradePackageCB
            $WPFMISTBUpgradePackage.Text = $settings.UpgradePackPath
            $WPFSourceWimTBVersionNum.text = $settings.SourceVersion

            # Store lists for later processing
            $LEPs = $settings.LPListBox
            $LXPs = $settings.LXPListBox
            $FODs = $settings.FODListBox
            $DPs = $settings.CMDPList
            $REGs = $settings.RegFilesLB
            Update-Log -data 'Configuration set' -class Information

            # Clear and repopulate list boxes
            Update-Log -data 'Clearing list boxes...' -Class Information
            $WPFCustomLBLangPacks.Items.Clear()
            $WPFCustomLBLEP.Items.Clear()
            $WPFCustomLBFOD.Items.Clear()
            $WPFCMLBDPs.Items.Clear()
            $WPFCustomLBRegistry.Items.Clear()

            # Populate list boxes with saved values
            Update-Log -data 'Populating list boxes...' -class Information
            foreach ($LEP in $LEPs) { $WPFCustomLBLangPacks.Items.Add($LEP) | Out-Null }
            foreach ($LXP in $LXPs) { $WPFCustomLBLEP.Items.Add($LXP) | Out-Null }
            foreach ($FOD in $FODs) { $WPFCustomLBFOD.Items.Add($FOD) | Out-Null }
            foreach ($DP in $DPs) { $WPFCMLBDPs.Items.Add($DP) | Out-Null }
            foreach ($REG in $REGs) { $WPFCustomLBRegistry.Items.Add($REG) | Out-Null }

            # Import WIM information and parse JSON if enabled
            Import-WimInfo -IndexNumber $WPFSourceWimIndexTextBox.text -SkipUserConfirmation

            if ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
                Invoke-ParseJSON -file $WPFJSONTextBox.text
            }

            # Handle ConfigMgr specific settings
            if ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image') {
                Get-ImageInfo -PackID $settings.CMPackageID
            }

            # Final cleanup and reset
            Reset-WWMISCheckBox
        }
        catch {
            Update-Log -data "Could not import from $filename" -Class Error
        }

        # Perform final cleanup and validation
        Invoke-CheckboxCleanup
        Update-Log -data 'Config file loaded successfully' -Class Information
    }
}

