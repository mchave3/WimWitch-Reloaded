<#
.SYNOPSIS
    Remove ISO mount points.

.DESCRIPTION
    This function removes ISO mount points and cleans up associated resources.
    It handles both successful and failed dismount scenarios.

.NOTES
    Name:        Invoke-RemoveISOMount.ps1
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
    Invoke-RemoveISOMount -inputObject $mountPath
#>
function Invoke-RemoveISOMount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$inputObject
    )

    process {
        try {
            Update-Log -Data "Removing ISO mount point: $inputObject" -Class Information
            
            if (Test-Path -Path $inputObject) {
                # Get mounted image info
                $mountedImages = Get-WindowsImage -Mounted
                
                foreach ($image in $mountedImages) {
                    if ($image.Path -eq $inputObject) {
                        # Attempt to dismount
                        Dismount-WindowsImage -Path $image.Path -Discard
                        Update-Log -Data "Dismounted image at: $($image.Path)" -Class Information
                    }
                }
                
                # Remove mount directory
                Remove-Item -Path $inputObject -Force -Recurse
                Update-Log -Data "Removed mount directory: $inputObject" -Class Information
            }
            else {
                Update-Log -Data "Mount point not found: $inputObject" -Class Warning
            }
        }
        catch {
            Update-Log -Data "Failed to remove ISO mount point: $inputObject" -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
