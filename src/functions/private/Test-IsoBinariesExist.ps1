<#
.SYNOPSIS
    Test if required ISO creation binaries exist.

.DESCRIPTION
    This function checks if the required binaries for ISO creation (oscdimg.exe)
    exist in the system. It validates the presence and accessibility of these
    tools.

.NOTES
    Name:        Test-IsoBinariesExist.ps1
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
    Test-IsoBinariesExist
#>
function Test-IsoBinariesExist {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Checking for required ISO creation binaries...' -Class Information
            
            $oscdimgPath = "$env:SystemRoot\system32\oscdimg.exe"
            $bootDataPath = "$env:SystemRoot\boot\etfsboot.com"
            $efiBootDataPath = "$env:SystemRoot\boot\efisys.bin"
            
            $missingFiles = @()
            
            if (-not (Test-Path -Path $oscdimgPath)) {
                $missingFiles += "oscdimg.exe"
            }
            
            if (-not (Test-Path -Path $bootDataPath)) {
                $missingFiles += "etfsboot.com"
            }
            
            if (-not (Test-Path -Path $efiBootDataPath)) {
                $missingFiles += "efisys.bin"
            }
            
            if ($missingFiles.Count -gt 0) {
                throw "Missing required files: $($missingFiles -join ', ')"
            }
            
            Update-Log -Data 'All required ISO creation binaries found' -Class Information
            return $true
        }
        catch {
            Update-Log -Data 'Missing required ISO creation binaries' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
            return $false
        }
    }
}
