<#
.SYNOPSIS
    Enable or disable ConfigMgr-related options in the UI.

.DESCRIPTION
    This function enables or disables ConfigMgr-related options in the UI based on the selected image type.

.NOTES
    Name:        Enable-ConfigMgrOption.ps1
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
    Enable-ConfigMgrOption
#>
function Enable-ConfigMgrOption {
    [CmdletBinding()]
    param(

    )

    process {
        #"Disabled","New Image","Update Existing Image"
        if ($WPFCMCBImageType.SelectedItem -eq 'New Image') {
            $WPFCMBAddDP.IsEnabled = $True
            $WPFCMBRemoveDP.IsEnabled = $True
            $WPFCMBSelectImage.IsEnabled = $False
            $WPFCMCBBinDirRep.IsEnabled = $True
            $WPFCMCBDPDPG.IsEnabled = $True
            $WPFCMLBDPs.IsEnabled = $True
            $WPFCMTBDescription.IsEnabled = $True
            $WPFCMTBImageName.IsEnabled = $True
            $WPFCMTBImageVer.IsEnabled = $True
            $WPFCMTBPackageID.IsEnabled = $False
            #        $WPFCMTBSitecode.IsEnabled = $True
            #        $WPFCMTBSiteServer.IsEnabled = $True
            $WPFCMTBWinBuildNum.IsEnabled = $False
            $WPFCMCBImageVerAuto.IsEnabled = $True
            $WPFCMCBDescriptionAuto.IsEnabled = $True
            $WPFCMCBDeploymentShare.IsEnabled = $True


            # $MEMCMsiteinfo = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification"
            # $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
            # $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'
            Update-Log -data 'ConfigMgr feature enabled. New Image selected' -class Information
            #    Update-Log -data $WPFCMTBSitecode.text -class Information
            #    Update-Log -data $WPFCMTBSiteServer.text -class Information
        }

        if ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image') {
            $WPFCMBAddDP.IsEnabled = $False
            $WPFCMBRemoveDP.IsEnabled = $False
            $WPFCMBSelectImage.IsEnabled = $True
            $WPFCMCBBinDirRep.IsEnabled = $True
            $WPFCMCBDPDPG.IsEnabled = $False
            $WPFCMLBDPs.IsEnabled = $False
            $WPFCMTBDescription.IsEnabled = $True
            $WPFCMTBImageName.IsEnabled = $False
            $WPFCMTBImageVer.IsEnabled = $True
            $WPFCMTBPackageID.IsEnabled = $True
            $WPFCMTBSitecode.IsEnabled = $True
            $WPFCMTBSiteServer.IsEnabled = $True
            $WPFCMTBWinBuildNum.IsEnabled = $False
            $WPFCMCBImageVerAuto.IsEnabled = $True
            $WPFCMCBDescriptionAuto.IsEnabled = $True
            $WPFCMCBDeploymentShare.IsEnabled = $True

            #  $MEMCMsiteinfo = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification"
            #  $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
            #  $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'
            Update-Log -data 'ConfigMgr feature enabled. Update an existing image selected' -class Information
            #   Update-Log -data $WPFCMTBSitecode.text -class Information
            #   Update-Log -data $WPFCMTBSiteServer.text -class Information
        }

        if ($WPFCMCBImageType.SelectedItem -eq 'Disabled') {
            $WPFCMBAddDP.IsEnabled = $False
            $WPFCMBRemoveDP.IsEnabled = $False
            $WPFCMBSelectImage.IsEnabled = $False
            $WPFCMCBBinDirRep.IsEnabled = $False
            $WPFCMCBDPDPG.IsEnabled = $False
            $WPFCMLBDPs.IsEnabled = $False
            $WPFCMTBDescription.IsEnabled = $False
            $WPFCMTBImageName.IsEnabled = $False
            $WPFCMTBImageVer.IsEnabled = $False
            $WPFCMTBPackageID.IsEnabled = $False
            #       $WPFCMTBSitecode.IsEnabled = $False
            #       $WPFCMTBSiteServer.IsEnabled = $False
            $WPFCMTBWinBuildNum.IsEnabled = $False
            $WPFCMCBImageVerAuto.IsEnabled = $False
            $WPFCMCBDescriptionAuto.IsEnabled = $False
            $WPFCMCBDeploymentShare.IsEnabled = $False
            Update-Log -data 'ConfigMgr feature disabled' -class Information

        }
    }
}
