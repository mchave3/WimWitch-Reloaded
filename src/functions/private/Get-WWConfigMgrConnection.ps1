<#
.SYNOPSIS
    Manually set the ConfigMgr site information in the GUI.

.DESCRIPTION
    This function is used to set the ConfigMgr site information in the GUI.

.NOTES
    Name:        Get-WWConfigMgrConnection.ps1
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
    Get-WWConfigMgrConnection
#>
function Get-WWConfigMgrConnection {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            # $MEMCMsiteinfo = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification" -ErrorAction Stop

            # $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
            # $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'

            #$WPFCMTBSiteServer.text = "nt-tpmemcm.notorious.local"
            #$WPFCMTBSitecode.text = "NTP"

            $Script:SiteCode = $WPFCMTBSitecode.text
            $Script:SiteServer = $WPFCMTBSiteServer.Text
            $Script:CMDrive = $WPFCMTBSitecode.text + ':'

            Write-WWLog -Data 'ConfigMgr detected and properties set' -Class Information
            Write-WWLog -Data 'ConfigMgr feature enabled' -Class Information
            $sitecodetext = 'Site Code - ' + $WPFCMTBSitecode.text
            Write-WWLog -Data $sitecodetext -Class Information
            $siteservertext = 'Site Server - ' + $WPFCMTBSiteServer.text
            Write-WWLog -Data $siteservertext -Class Information

            $CMConfig = @{
                SiteCode   = $WPFCMTBSitecode.text
                SiteServer = $WPFCMTBSiteServer.text
            }
            Write-WWLog -data 'Saving ConfigMgr site information...'
            $CMConfig | Export-Clixml -Path $Script:workdir\ConfigMgr\SiteInfo.xml -ErrorAction Stop

            if ($CM -eq 'New') {
                $WPFCMCBImageType.SelectedIndex = 1
                Enable-ConfigMgrOption
            }
        }

        catch {
            Write-WWLog -Data 'ConfigMgr not detected' -Class Information
            $WPFCMTBSiteServer.text = 'Not Detected'
            $WPFCMTBSitecode.text = 'Not Detected'
        }
    }
}

