<#
.SYNOPSIS
    Find and validate ConfigMgr installation.

.DESCRIPTION
    This function checks for the presence of ConfigMgr installation by looking
    for registry entries and validating the installation path.

.NOTES
    Name:        Find-ConfigManager.ps1
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
    Find-ConfigManager
#>
function Find-ConfigManager {
    [CmdletBinding()]
    param(

    )

    process {
        if ((Test-Path -Path HKLM:\SOFTWARE\Microsoft\SMS\Identification) -eq $true) {
            Update-Log -Data 'Site Information found in Registry' -Class Information
            try {
                $global:SiteCode = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\Identification -ErrorAction Stop |
                    Select-Object -ExpandProperty Site
                Update-Log -Data "Site Code: $global:SiteCode" -Class Information
            }
            catch {
                Update-Log -Data 'Could not get site code from registry' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
                return $false
            }

            try {
                $global:SiteServer = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\Identification -ErrorAction Stop |
                    Select-Object -ExpandProperty Server
                Update-Log -Data "Site Server: $global:SiteServer" -Class Information
            }
            catch {
                Update-Log -Data 'Could not get site server from registry' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
                return $false
            }

            try {
                $global:ProviderLocation = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\Identification -ErrorAction Stop |
                    Select-Object -ExpandProperty Location
                Update-Log -Data "Provider Location: $global:ProviderLocation" -Class Information
            }
            catch {
                Update-Log -Data 'Could not get provider location from registry' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
                return $false
            }

            try {
                $global:CMModulePath = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -ErrorAction Stop |
                    Select-Object -ExpandProperty PSModulePath
                Update-Log -Data "PowerShell Module Path: $global:CMModulePath" -Class Information
            }
            catch {
                Update-Log -Data 'Could not get PowerShell module path from registry' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
                return $false
            }

            try {
                $global:CMDrive = $global:SiteCode + ':'
                Update-Log -Data "ConfigMgr Drive: $global:CMDrive" -Class Information
            }
            catch {
                Update-Log -Data 'Could not create ConfigMgr drive path' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
                return $false
            }

            return $true
        }
        else {
            Update-Log -Data 'ConfigMgr not found on this system' -Class Warning
            return $false
        }
    }
}
