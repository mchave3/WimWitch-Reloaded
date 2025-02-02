<#
.SYNOPSIS
    Create a new Windows ISO file.

.DESCRIPTION
    This function creates a new Windows ISO file from the modified WIM file and
    staged content. It handles the ISO creation process using oscdimg and manages
    any errors that occur during the process.

.NOTES
    Name:        New-WindowsISO.ps1
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
    New-WindowsISO
#>
function New-WindowsISO {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Starting ISO creation process...' -Class Information
            
            # Get required paths
            $stagePath = $WPFMISISOSelection.Text
            $isoPath = $WPFMISISOPath.Text
            $bootData = "$($env:SystemRoot)\boot\etfsboot.com"
            $efiBootData = "$($env:SystemRoot)\boot\efisys.bin"
            
            # Validate paths
            if (-not (Test-Path -Path $stagePath)) {
                throw "Stage path not found: $stagePath"
            }
            
            if (-not (Test-Path -Path $bootData)) {
                throw "Boot data file not found: $bootData"
            }
            
            if (-not (Test-Path -Path $efiBootData)) {
                throw "EFI boot data file not found: $efiBootData"
            }
            
            # Create ISO
            $oscdimgPath = "$env:SystemRoot\system32\oscdimg.exe"
            $isoArgs = @(
                '-m'
                '-o'
                '-u2'
                '-udfver102'
                '-bootdata:2#p0,e,b"{0}"#pEF,e,b"{1}"' -f $bootData, $efiBootData
                $stagePath
                $isoPath
            )
            
            $process = Start-Process -FilePath $oscdimgPath -ArgumentList $isoArgs -NoNewWindow -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Update-Log -Data "ISO file created successfully at: $isoPath" -Class Information
            }
            else {
                throw "oscdimg failed with exit code: $($process.ExitCode)"
            }
        }
        catch {
            Update-Log -Data 'Failed to create ISO file' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
