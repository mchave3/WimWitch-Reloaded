<#
.SYNOPSIS
    Detect and set ConfigMgr Site Code and Site Server.

.DESCRIPTION
    This function will check if ConfigMgr is installed on the machine and set the Site Code and Site Server accordingly.

.NOTES
    Name:        Find-WWConfigManager.ps1
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
    Find-WWConfigManager
#>
function Find-WWConfigManager {
    [CmdletBinding()]
    [OutputType([bool])]
    param(

    )

    process {
        If ((Test-Path -Path HKLM:\SOFTWARE\Microsoft\SMS\Identification) -eq $true) {
            Write-WimWitchLog -Data 'Site Information found in Registry' -Class Information
            try {
                $MEMCMsiteinfo = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification' -ErrorAction Stop
                $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
                $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'
                #$WPFCMTBSiteServer.text = "nt-tpmemcm.notorious.local"
                #$WPFCMTBSitecode.text = "NTP"
                $Script:SiteCode = $WPFCMTBSitecode.text
                $Script:SiteServer = $WPFCMTBSiteServer.Text
                $Script:CMDrive = $WPFCMTBSitecode.text + ':'
                Write-WimWitchLog -Data 'ConfigMgr detected and properties set' -Class Information
                Write-WimWitchLog -Data 'ConfigMgr feature enabled' -Class Information
                $sitecodetext = 'Site Code - ' + $WPFCMTBSitecode.text
                Write-WimWitchLog -Data $sitecodetext -Class Information
                $siteservertext = 'Site Server - ' + $WPFCMTBSiteServer.text
                Write-WimWitchLog -Data $siteservertext -Class Information
                if ($CM -eq 'New') {
                    $WPFCMCBImageType.SelectedIndex = 1
                    Enable-WWConfigManagerOption
                }
                return $true
            } catch {
                Write-WimWitchLog -Data 'ConfigMgr not detected' -Class Information
                $WPFCMTBSiteServer.text = 'Not Detected'
                $WPFCMTBSitecode.text = 'Not Detected'
                return $false
            }
        }
        if ((Test-Path -Path $Script:workdir\ConfigMgr\SiteInfo.XML) -eq $true) {
            Write-WimWitchLog -data 'ConfigMgr Site info XML found' -class Information
            $settings = Import-Clixml -Path $Script:workdir\ConfigMgr\SiteInfo.xml -ErrorAction Stop
            $WPFCMTBSitecode.text = $settings.SiteCode
            $WPFCMTBSiteServer.text = $settings.SiteServer
            Write-WimWitchLog -Data 'ConfigMgr detected and properties set' -Class Information
            Write-WimWitchLog -Data 'ConfigMgr feature enabled' -Class Information
            $sitecodetext = 'Site Code - ' + $WPFCMTBSitecode.text
            Write-WimWitchLog -Data $sitecodetext -Class Information
            $siteservertext = 'Site Server - ' + $WPFCMTBSiteServer.text
            Write-WimWitchLog -Data $siteservertext -Class Information
            $Script:SiteCode = $WPFCMTBSitecode.text
            $Script:SiteServer = $WPFCMTBSiteServer.Text
            $Script:CMDrive = $WPFCMTBSitecode.text + ':'
            return $true
        }
        Write-WimWitchLog -Data 'ConfigMgr not detected' -Class Information
        $WPFCMTBSiteServer.text = 'Not Detected'
        $WPFCMTBSitecode.text = 'Not Detected'
        Return $false
    }
}




