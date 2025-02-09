<#
.SYNOPSIS
    Check if the specified path is suitable for mounting an image.

.DESCRIPTION
    This function checks if the specified path is suitable for mounting an image.

.NOTES
    Name:        Test-MountPath.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Test-MountPath -path 'C:\Mount'
    Test-MountPath -path 'C:\Mount' -clean $true
#>
function Test-MountPath {
    [CmdletBinding()]
    param(
        [parameter(mandatory = $true, HelpMessage = 'mount path')]
        $path,

        [parameter(mandatory = $false, HelpMessage = 'clear out the crapola')]
        [ValidateSet($true)]
        $clean
    )

    process {
        $IsMountPoint = $null
        $HasFiles = $null
        $currentmounts = Get-WindowsImage -Mounted

        foreach ($currentmount in $currentmounts) {
            if ($currentmount.path -eq $path) { $IsMountPoint = $true }
        }

        if ($null -eq $IsMountPoint) {
            if ( (Get-ChildItem $path | Measure-Object).Count -gt 0) {
                $HasFiles = $true
            }
        }

        if ($HasFiles -eq $true) {
            Write-WWLog -Data 'Folder is not empty' -Class Warning
            if ($clean -eq $true) {
                try {
                    Write-WWLog -Data 'Cleaning folder...' -Class Warning
                    Remove-Item -Path $path\* -Recurse -Force -ErrorAction Stop
                    Write-WWLog -Data "$path cleared" -Class Warning
                }

                catch {
                    Write-WWLog -Data "Couldn't delete contents of $path" -Class Error
                    Write-WWLog -Data 'Select a different folder to continue.' -Class Error
                    return
                }
            }
        }

        if ($IsMountPoint -eq $true) {
            Write-WWLog -Data "$path is currently a mount point" -Class Warning
            if (($IsMountPoint -eq $true) -and ($clean -eq $true)) {

                try {
                    Write-WWLog -Data 'Attempting to dismount image from mount point' -Class Warning
                    Dismount-WindowsImage -Path $path -Discard | Out-Null -ErrorAction Stop
                    $IsMountPoint = $null
                    Write-WWLog -Data 'Dismounting was successful' -Class Warning
                }

                catch {
                    Write-WWLog -Data "Couldn't completely dismount the folder. Ensure" -Class Error
                    Write-WWLog -data 'all connections to the path are closed, then try again' -Class Error
                    return
                }
            }
        }
        if (($null -eq $IsMountPoint) -and ($null -eq $HasFiles)) {
            Write-WWLog -Data "$path is suitable for mounting" -Class Information
        }
    }
}

