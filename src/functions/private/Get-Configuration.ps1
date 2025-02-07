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
        [Parameter(Mandatory = $true)]
        [string]$filename
    )

    process {
        Update-Log -data "Importing config from $filename" -Class Information
        try {
            $settings = Import-Clixml -Path $filename -ErrorAction Stop
            Update-Log -data 'Config file read...' -Class Information
            $WPFSourceWIMSelectWIMTextBox.text = $settings.SourcePath
            $WPFSourceWimIndexTextBox.text = $settings.SourceIndex
            $WPFSourceWIMImgDesTextBox.text = $settings.SourceEdition
            $WPFUpdatesEnableCheckBox.IsChecked = $settings.UpdatesEnabled
            $WPFJSONEnableCheckBox.IsChecked = $settings.AutopilotEnabled
            $WPFJSONTextBox.text = $settings.AutopilotPath
            $WPFDriverCheckBox.IsChecked = $settings.DriversEnabled
            $WPFDriverDir1TextBox.text = $settings.DriverPath1
            $WPFDriverDir2TextBox.text = $settings.DriverPath2
            $WPFDriverDir3TextBox.text = $settings.DriverPath3
            $WPFDriverDir4TextBox.text = $settings.DriverPath4
            $WPFDriverDir5TextBox.text = $settings.DriverPath5
            $WPFAppxCheckBox.IsChecked = $settings.AppxIsEnabled
            $WPFAppxTextBox.text = $settings.AppxSelected -split ' '
            $WPFMISWimNameTextBox.text = $settings.WIMName
            $WPFMISWimFolderTextBox.text = $settings.WIMPath
            $WPFMISMountTextBox.text = $settings.MountPath
            $Script:SelectedAppx = $settings.AppxSelected -split ' '
            $WPFMISDotNetCheckBox.IsChecked = $settings.DotNetEnabled
            $WPFMISOneDriveCheckBox.IsChecked = $settings.OneDriveEnabled
            $WPFCustomCBLangPacks.IsChecked = $settings.LPsEnabled
            $WPFCustomCBLEP.IsChecked = $settings.LXPsEnabled
            $WPFCustomCBFOD.IsChecked = $settings.FODsEnabled
    
            $WPFMISCBPauseMount.IsChecked = $settings.PauseAfterMount
            $WPFMISCBPauseDismount.IsChecked = $settings.PauseBeforeDM
            $WPFCustomCBRunScript.IsChecked = $settings.RunScript
            $WPFCustomCBScriptTiming.SelectedItem = $settings.ScriptTiming
            $WPFCustomTBFile.Text = $settings.ScriptFile
            $WPFCustomTBParameters.Text = $settings.ScriptParams
            $WPFCMCBImageType.SelectedItem = $settings.CMImageType
            $WPFCMTBPackageID.Text = $settings.CMPackageID
            $WPFCMTBImageName.Text = $settings.CMImageName
            $WPFCMTBImageVer.Text = $settings.CMVersion
            $WPFCMTBDescription.Text = $settings.CMDescription
            $WPFCMCBBinDirRep.IsChecked = $settings.CMBinDifRep
            $WPFCMTBSitecode.Text = $settings.CMSiteCode
            $WPFCMTBSiteServer.Text = $settings.CMSiteServer
            $WPFCMCBDPDPG.SelectedItem = $settings.CMDPGroup
            $WPFUSCBSelectCatalogSource.SelectedItem = $settings.UpdateSource
            $WPFMISCBCheckForUpdates.IsChecked = $settings.UpdateMIS
    
            $WPFCMCBImageVerAuto.IsChecked = $settings.AutoFillVersion
            $WPFCMCBDescriptionAuto.IsChecked = $settings.AutoFillDesc
    
            $WPFCustomCBEnableApp.IsChecked = $settings.DefaultAppCB
            $WPFCustomTBDefaultApp.Text = $settings.DefaultAppPath
            $WPFCustomCBEnableStart.IsChecked = $settings.StartMenuCB
            $WPFCustomTBStartMenu.Text = $settings.StartMenuPath
            $WPFCustomCBEnableRegistry.IsChecked = $settings.RegFilesCB
            $WPFUpdatesCBEnableOptional.IsChecked = $settings.SUOptional
            $WPFUpdatesCBEnableDynamic.IsChecked = $settings.SUDynamic
    
            $WPFMISCBDynamicUpdates.IsChecked = $settings.ApplyDynamicCB
            $WPFMISCBBootWIM.IsChecked = $settings.UpdateBootCB
            $WPFMISCBNoWIM.IsChecked = $settings.DoNotCreateWIMCB
            $WPFMISCBISO.IsChecked = $settings.CreateISO
            $WPFMISTBISOFileName.Text = $settings.ISOFileName
            $WPFMISTBFilePath.Text = $settings.ISOFilePath
            $WPFMISCBUpgradePackage.IsChecked = $settings.UpgradePackageCB
            $WPFMISTBUpgradePackage.Text = $settings.UpgradePackPath
            $WPFUpdatesOptionalEnableCheckBox.IsChecked = $settings.IncludeOptionCB
    
            $WPFSourceWimTBVersionNum.text = $settings.SourceVersion
    
            $LEPs = $settings.LPListBox
            $LXPs = $settings.LXPListBox
            $FODs = $settings.FODListBox
            $DPs = $settings.CMDPList
            $REGs = $settings.RegFilesLB
    
    
    
            Update-Log -data 'Configration set' -class Information
    
            Update-Log -data 'Clearing list boxes...' -Class Information
            $WPFCustomLBLangPacks.Items.Clear()
            $WPFCustomLBLEP.Items.Clear()
            $WPFCustomLBFOD.Items.Clear()
            $WPFCMLBDPs.Items.Clear()
            $WPFCustomLBRegistry.Items.Clear()
    
    
            Update-Log -data 'Populating list boxes...' -class Information
            foreach ($LEP in $LEPs) { $WPFCustomLBLangPacks.Items.Add($LEP) | Out-Null }
            foreach ($LXP in $LXPs) { $WPFCustomLBLEP.Items.Add($LXP) | Out-Null }
            foreach ($FOD in $FODs) { $WPFCustomLBFOD.Items.Add($FOD) | Out-Null }
            foreach ($DP in $DPs) { $WPFCMLBDPs.Items.Add($DP) | Out-Null }
            foreach ($REG in $REGs) { $WPFCustomLBRegistry.Items.Add($REG) | Out-Null }
    
    
            Import-WimInfo -IndexNumber $WPFSourceWimIndexTextBox.text -SkipUserConfirmation
    
            if ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
    
                Invoke-ParseJSON -file $WPFJSONTextBox.text
            }
    
            if ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image') { Get-ImageInfo -PackID $settings.CMPackageID }
    
            Reset-MISCheckBox
    
        }
    
        catch
        { Update-Log -data "Could not import from $filename" -Class Error }
    
        Invoke-CheckboxCleanup
        Update-Log -data 'Config file loaded successfully' -Class Information
    }
}
