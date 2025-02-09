<#
.SYNOPSIS
    Run a PowerShell script with supplied parameters.

.DESCRIPTION
    This function executes a PowerShell script with the provided parameters and handles any errors that occur during execution.

.NOTES
    Name:        Invoke-WWScript.ps1
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
    Invoke-WWScript -File "C:\Scripts\MyScript.ps1" -Parameter "-Action Install -Force"
#>
function Invoke-WWScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$File,

        [Parameter(Mandatory = $true)]
        [string]$Parameter
    )

    process {
        $string = "$File $Parameter"
        try {
            Write-WWLog -Data 'Running script' -Class Information
            Invoke-Expression -Command $string -ErrorAction Stop
            Write-WWLog -data 'Script complete' -Class Information
        } catch {
            Write-WWLog -Data 'Script failed' -Class Error
        }
    }
}

