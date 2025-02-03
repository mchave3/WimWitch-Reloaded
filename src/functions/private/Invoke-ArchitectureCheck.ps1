<#
.SYNOPSIS
    Check the current PowerShell session architecture and relaunch as 64-bit if needed.

.DESCRIPTION
    This function checks if the current PowerShell session is 32-bit or 64-bit. If it is 32-bit, it will relaunch the session as 64-bit.

.NOTES
    Name:        Invoke-ArchitectureCheck.ps1
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
    Invoke-ArchitectureCheck
#>
function Invoke-ArchitectureCheck {
    [CmdletBinding()]
    param(

    )

    process {
        if ([Environment]::Is64BitProcess -ne [Environment]::Is64BitOperatingSystem) {
            Update-Log -Data 'This is 32-bit PowerShell session. Will relaunch as 64-bit...' -Class Warning
    
            #The following If statment was pilfered from Michael Niehaus
            if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
    
                if (($auto -eq $false) -and ($CM -eq 'None')) { & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" }
                if (($auto -eq $true) -and ($null -ne $autofile)) { & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -auto -autofile $autofile }
                if (($CM -eq 'Edit') -and ($null -ne $autofile)) { & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -CM Edit -autofile $autofile }
                if ($CM -eq 'New') { & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -CM New }
    
                Exit $lastexitcode
            }
        } else {
            Update-Log -Data 'This is a 64 bit PowerShell session' -Class Information
        }
    }
}
