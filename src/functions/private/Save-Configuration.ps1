<#
.SYNOPSIS
    Save the current WimWitch configuration to a file.

.DESCRIPTION
    This function is used to save the current WimWitch configuration to a file.

.NOTES
    Name:        Save-Configuration.ps1
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
    Save-Configuration
    Save-Configuration -filename "config.xml"
    Save-Configuration -CM
    Save-Configuration -filename "config.xml" -CM
#>
function Save-Configuration {
    [CmdletBinding()]
    param(
        [parameter(mandatory = $false, HelpMessage = 'config file')]
        [string]$filename,

        [parameter(mandatory = $false, HelpMessage = 'enable CM files')]
        [switch]$CM
    )

    process {
        $CurrentConfig = @{
            SourcePath       = $WPFSourceWIMSelectWIMTextBox.text
            SourceIndex      = $WPFSourceWimIndexTextBox.text
            SourceEdition    = $WPFSourceWIMImgDesTextBox.text
            UpdatesEnabled   = $WPFUpdatesEnableCheckBox.IsChecked
            AutopilotEnabled = $WPFJSONEnableCheckBox.IsChecked
            AutopilotPath    = $WPFJSONTextBox.text
            DriversEnabled   = $WPFDriverCheckBox.IsChecked
            DriverPath1      = $WPFDriverDir1TextBox.text
            DriverPath2      = $WPFDriverDir2TextBox.text
            DriverPath3      = $WPFDriverDir3TextBox.text
            DriverPath4      = $WPFDriverDir4TextBox.text
            DriverPath5      = $WPFDriverDir5TextBox.text
            AppxIsEnabled    = $WPFAppxCheckBox.IsChecked
            AppxSelected     = $WPFAppxTextBox.Text
            WIMName          = $WPFMISWimNameTextBox.text
            WIMPath          = $WPFMISWimFolderTextBox.text
            MountPath        = $WPFMISMountTextBox.text
            DotNetEnabled    = $WPFMISDotNetCheckBox.IsChecked
            OneDriveEnabled  = $WPFMISOneDriveCheckBox.IsChecked
            LPsEnabled       = $WPFCustomCBLangPacks.IsChecked
            LXPsEnabled      = $WPFCustomCBLEP.IsChecked
            FODsEnabled      = $WPFCustomCBFOD.IsChecked
            LPListBox        = $WPFCustomLBLangPacks.items
            LXPListBox       = $WPFCustomLBLEP.Items
            FODListBox       = $WPFCustomLBFOD.Items
            PauseAfterMount  = $WPFMISCBPauseMount.IsChecked
            PauseBeforeDM    = $WPFMISCBPauseDismount.IsChecked
            RunScript        = $WPFCustomCBRunScript.IsChecked
            ScriptTiming     = $WPFCustomCBScriptTiming.SelectedItem
            ScriptFile       = $WPFCustomTBFile.Text
            ScriptParams     = $WPFCustomTBParameters.Text
            CMImageType      = $WPFCMCBImageType.SelectedItem
            CMPackageID      = $WPFCMTBPackageID.Text
            CMImageName      = $WPFCMTBImageName.Text
            CMVersion        = $WPFCMTBImageVer.Text
            CMDescription    = $WPFCMTBDescription.Text
            CMBinDifRep      = $WPFCMCBBinDirRep.IsChecked
            CMSiteCode       = $WPFCMTBSitecode.Text
            CMSiteServer     = $WPFCMTBSiteServer.Text
            CMDPGroup        = $WPFCMCBDPDPG.SelectedItem
            CMDPList         = $WPFCMLBDPs.Items
            UpdateSource     = $WPFUSCBSelectCatalogSource.SelectedItem
            UpdateMIS        = $WPFMISCBCheckForUpdates.IsChecked
            AutoFillVersion  = $WPFCMCBImageVerAuto.IsChecked
            AutoFillDesc     = $WPFCMCBDescriptionAuto.IsChecked
            DefaultAppCB     = $WPFCustomCBEnableApp.IsChecked
            DefaultAppPath   = $WPFCustomTBDefaultApp.Text
            StartMenuCB      = $WPFCustomCBEnableStart.IsChecked
            StartMenuPath    = $WPFCustomTBStartMenu.Text
            RegFilesCB       = $WPFCustomCBEnableRegistry.IsChecked
            RegFilesLB       = $WPFCustomLBRegistry.Items
            SUOptional       = $WPFUpdatesCBEnableOptional.IsChecked
            SUDynamic        = $WPFUpdatesCBEnableDynamic.IsChecked
    
            ApplyDynamicCB   = $WPFMISCBDynamicUpdates.IsChecked
            UpdateBootCB     = $WPFMISCBBootWIM.IsChecked
            DoNotCreateWIMCB = $WPFMISCBNoWIM.IsChecked
            CreateISO        = $WPFMISCBISO.IsChecked
            ISOFileName      = $WPFMISTBISOFileName.Text
            ISOFilePath      = $WPFMISTBFilePath.Text
            UpgradePackageCB = $WPFMISCBUpgradePackage.IsChecked
            UpgradePackPath  = $WPFMISTBUpgradePackage.Text
            IncludeOptionCB  = $WPFUpdatesOptionalEnableCheckBox.IsChecked
    
            SourceVersion    = $WPFSourceWimTBVersionNum.text
        }
    
        if ($CM -eq $False) {
    
            Update-Log -data "Saving configuration file $filename" -Class Information
    
            try {
                $CurrentConfig | Export-Clixml -Path $Script:workdir\Configs\$filename -ErrorAction Stop
                Update-Log -data 'file saved' -Class Information
            } catch {
                Update-Log -data "Couldn't save file" -Class Error
            }
        } else {
            Update-Log -data "Saving ConfigMgr Image info for Package $filename" -Class Information
    
            $CurrentConfig.CMPackageID = $filename
            $CurrentConfig.CMImageType = 'Update Existing Image'
    
            $CurrentConfig.CMImageType
    
            if ((Test-Path -Path $Script:workdir\ConfigMgr\PackageInfo) -eq $False) {
                Update-Log -Data 'Creating ConfigMgr Package Info folder...' -Class Information
    
                try {
                    New-Item -ItemType Directory -Path $Script:workdir\ConfigMgr\PackageInfo -ErrorAction Stop
                } catch {
                    Update-Log -Data "Couldn't create the folder. Likely a permission issue" -Class Error
                }
            }
            try {
                $CurrentConfig | Export-Clixml -Path $Script:workdir\ConfigMgr\PackageInfo\$filename -Force -ErrorAction Stop
                Update-Log -data 'file saved' -Class Information
            } catch {
                Update-Log -data "Couldn't save file" -Class Error
            }
        }
    }
}
