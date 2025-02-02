<#
.SYNOPSIS
    Configure ConfigMgr settings.

.DESCRIPTION
    This function configures the necessary settings for Configuration Manager integration,
    including paths and environment variables. It ensures proper connection to the
    ConfigMgr site and sets up the required environment.

.NOTES
    Name:        Set-ConfigMgr.ps1
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
    Set-ConfigMgr
#>
function Set-ConfigMgr {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Setting up ConfigMgr connection...' -Class Information

            # Get ConfigMgr installation path
            $ConfigMgrInstallPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\Setup").UI_Installation_Directory

            # Set environment variables
            $env:SMS_ADMIN_UI_PATH = $ConfigMgrInstallPath + "\bin\i386"
            $env:SMS_ADMIN_UI_PATH_X64 = $ConfigMgrInstallPath + "\bin\x64"
            
            # Import ConfigMgr module
            Import-CMModule
            
            # Set location to ConfigMgr drive
            if (Test-Path -Path "$($global:SiteCode):") {
                Set-Location "$($global:SiteCode):"
                Update-Log -Data 'Successfully connected to ConfigMgr' -Class Information
            }
            else {
                throw "ConfigMgr drive $($global:SiteCode): not found"
            }
        }
        catch {
            Update-Log -Data 'Failed to set up ConfigMgr connection' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
        finally {
            Set-Location $PSScriptRoot
        }
    }
}
