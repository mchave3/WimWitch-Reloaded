<#
.SYNOPSIS
    Import the ConfigMgr PowerShell module.

.DESCRIPTION
    This function is used to import the ConfigMgr PowerShell module.

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
    [OutputType([bool])]
    param(

    )

    process {
        try {
            $path = (($env:SMS_ADMIN_UI_PATH -replace 'i386', '') + 'ConfigurationManager.psd1')

            #           $path = "C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1"
            Import-Module $path -ErrorAction Stop
            Write-WWLog -Data 'ConfigMgr PowerShell module imported' -Class Information
            return $true
        }

        catch {
            Write-WWLog -Data 'Could not import CM PowerShell module.' -Class Warning
            return $false
        }
    }
}

