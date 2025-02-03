<#
.SYNOPSIS
    Import the ConfigMgr PowerShell module.

.DESCRIPTION
    This function imports the Configuration Manager PowerShell module using the
    ConfigMgr installation path. It handles module import errors and ensures
    proper module loading.

.NOTES
    Name:        Import-CMModule.ps1
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
    Import-CMModule
#>
function Import-CMModule {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Importing ConfigMgr module...' -Class Information

            # Get ConfigMgr Module path
            $ModulePath = $env:SMS_ADMIN_UI_PATH + "\..\ConfigurationManager.psd1"
            
            if (Test-Path -Path $ModulePath) {
                # Import the ConfigMgr module
                Import-Module $ModulePath -Force
                Update-Log -Data 'ConfigMgr module imported successfully' -Class Information
            }
            else {
                throw "ConfigMgr module not found at path: $ModulePath"
            }
        }
        catch {
            Update-Log -Data 'Failed to import ConfigMgr module' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
