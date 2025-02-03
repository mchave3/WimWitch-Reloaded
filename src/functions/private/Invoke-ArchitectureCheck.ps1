<#
.SYNOPSIS
    Check system and image architecture compatibility.

.DESCRIPTION
    This function verifies the compatibility between the system architecture
    and the target image architecture. It ensures that operations are only
    performed on supported configurations.

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
        try {
            Update-Log -Data 'Checking system and image architecture compatibility...' -Class Information
            
            # Get system architecture
            $systemArch = [System.Environment]::Is64BitOperatingSystem
            
            # Get image architecture from WIM
            $wimPath = $WPFSourceWIMSelectWIMTextBox.Text
            $wimInfo = Get-WindowsImage -ImagePath $wimPath -Index 1
            
            if ($wimInfo.Architecture -eq 9) {
                $imageArch = "x64"
            }
            elseif ($wimInfo.Architecture -eq 0) {
                $imageArch = "x86"
            }
            else {
                $imageArch = "Unknown"
            }
            
            Update-Log -Data "System Architecture: $(if ($systemArch) { 'x64' } else { 'x86' })" -Class Information
            Update-Log -Data "Image Architecture: $imageArch" -Class Information
            
            # Check compatibility
            if (-not $systemArch -and $imageArch -eq "x64") {
                throw "Cannot process x64 images on x86 system"
            }
            
            Update-Log -Data 'Architecture check passed' -Class Information
            return $true
        }
        catch {
            Update-Log -Data 'Architecture compatibility check failed' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
            return $false
        }
    }
}
