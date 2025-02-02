<#
.SYNOPSIS
    Enable or disable ConfigMgr-related options in the UI.

.DESCRIPTION
    This function manages the enabled/disabled state of ConfigMgr-related
    UI elements based on the selected image type.

.NOTES
    Name:        Enable-ConfigMgrOptions.ps1
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
    Enable-ConfigMgrOptions
#>
function Enable-ConfigMgrOptions {
    [CmdletBinding()]
    param(

    )

    process {
        if ($WPFCMCBImageType.SelectedItem -eq 'New Image') {
            $WPFCMBAddDP.IsEnabled = $True
            $WPFCMBRemoveDP.IsEnabled = $False
            $WPFCMBAddDPGroup.IsEnabled = $True
            $WPFCMBRemoveDPGroup.IsEnabled = $False
            $WPFCMTBDescription.IsEnabled = $True
            $WPFCMTBPackageName.IsEnabled = $True
            $WPFCMCBFolderType.IsEnabled = $True
            $WPFCMTBImageName.IsEnabled = $True
            $WPFCMCBInstallWIM.IsEnabled = $True
            $WPFCMCBCustomWIM.IsEnabled = $True
            $WPFCMCBImageType.IsEnabled = $True
            $WPFCMTBImageVer.IsEnabled = $True
            $WPFCMBSelectImage.IsEnabled = $False
            $WPFCMTBWinBuildNum.IsEnabled = $True
            $WPFCMTBWinVerNum.IsEnabled = $True
        }

        if ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image') {
            $WPFCMBAddDP.IsEnabled = $True
            $WPFCMBRemoveDP.IsEnabled = $True
            $WPFCMBAddDPGroup.IsEnabled = $True
            $WPFCMBRemoveDPGroup.IsEnabled = $True
            $WPFCMTBDescription.IsEnabled = $True
            $WPFCMTBPackageName.IsEnabled = $False
            $WPFCMCBFolderType.IsEnabled = $False
            $WPFCMTBImageName.IsEnabled = $False
            $WPFCMCBInstallWIM.IsEnabled = $False
            $WPFCMCBCustomWIM.IsEnabled = $False
            $WPFCMCBImageType.IsEnabled = $True
            $WPFCMTBImageVer.IsEnabled = $True
            $WPFCMBSelectImage.IsEnabled = $True
            $WPFCMTBWinBuildNum.IsEnabled = $False
            $WPFCMTBWinVerNum.IsEnabled = $False
        }

        if ($WPFCMCBImageType.SelectedItem -eq 'Disabled') {
            $WPFCMBAddDP.IsEnabled = $False
            $WPFCMBRemoveDP.IsEnabled = $False
            $WPFCMBAddDPGroup.IsEnabled = $False
            $WPFCMBRemoveDPGroup.IsEnabled = $False
            $WPFCMTBDescription.IsEnabled = $False
            $WPFCMTBPackageName.IsEnabled = $False
            $WPFCMCBFolderType.IsEnabled = $False
            $WPFCMTBImageName.IsEnabled = $False
            $WPFCMCBInstallWIM.IsEnabled = $False
            $WPFCMCBCustomWIM.IsEnabled = $False
            $WPFCMCBImageType.IsEnabled = $True
            $WPFCMTBImageVer.IsEnabled = $False
            $WPFCMBSelectImage.IsEnabled = $False
            $WPFCMTBWinBuildNum.IsEnabled = $False
            $WPFCMTBWinVerNum.IsEnabled = $False
        }
    }
}
