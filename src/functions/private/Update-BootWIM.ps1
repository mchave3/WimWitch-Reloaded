<#
.SYNOPSIS
    Update the boot.wim file in the staging area.

.DESCRIPTION
    This function updates the boot.wim file in the staging area by mounting it,
    applying updates, and managing the mounting/unmounting process.

.NOTES
    Name:        Update-BootWIM.ps1
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
    Update-BootWIM
#>
function Update-BootWIM {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Creating mount point in staging folder...' -Class Information
            
            if ((Test-Path -Path ($global:workdir + '\staging\mount')) -eq $false) {
                New-Item -Path ($global:workdir + '\staging\mount') -ItemType Directory -Force | Out-Null
            }

            $bootmountdir = $global:workdir + '\staging\mount'
            $bootwim = $global:workdir + '\staging\media\sources\boot.wim'

            # Mount and update boot.wim index 1
            try {
                Update-Log -data 'Mounting boot.wim index 1...' -Class Information
                Mount-WindowsImage -Path $bootmountdir -ImagePath $bootwim -Index 1 | Out-Null
                Update-Log -Data 'boot.wim index 1 mounted successfully' -Class Information
            }
            catch {
                Update-Log -Data 'Failed to mount boot.wim index 1' -Class Error
                Update-Log -Data $_.Exception.Message -Class Error
                return
            }

            # Apply updates to index 1
            try {
                Update-Log -Data 'Applying updates to boot.wim index 1...' -Class Information
                $bootupdate = Get-ChildItem -Path ($global:workdir + '\staging\updates') -Filter '*.msu'
                foreach ($update in $bootupdate) {
                    $text = 'Applying ' + $update.name
                    Update-Log -data $text -Class Information
                    Add-WindowsPackage -PackagePath $update.fullname -Path $bootmountdir | Out-Null
                }
            }
            catch {
                Update-Log -Data 'Failed to apply updates to boot.wim index 1' -Class Error
                Update-Log -Data $_.Exception.Message -Class Error
            }

            # Dismount index 1
            try {
                Update-Log -Data 'Dismounting boot.wim index 1...' -Class Information
                Dismount-WindowsImage -Path $bootmountdir -Save | Out-Null
                Update-Log -Data 'boot.wim index 1 dismounted successfully' -Class Information
            }
            catch {
                Update-Log -Data 'Failed to dismount boot.wim index 1' -Class Error
                Update-Log -Data $_.Exception.Message -Class Error
                return
            }

            # Mount and update boot.wim index 2
            try {
                Update-Log -data 'Mounting boot.wim index 2...' -Class Information
                Mount-WindowsImage -Path $bootmountdir -ImagePath $bootwim -Index 2 | Out-Null
                Update-Log -Data 'boot.wim index 2 mounted successfully' -Class Information
            }
            catch {
                Update-Log -Data 'Failed to mount boot.wim index 2' -Class Error
                Update-Log -Data $_.Exception.Message -Class Error
                return
            }

            # Apply updates to index 2
            try {
                Update-Log -Data 'Applying updates to boot.wim index 2...' -Class Information
                foreach ($update in $bootupdate) {
                    $text = 'Applying ' + $update.name
                    Update-Log -data $text -Class Information
                    Add-WindowsPackage -PackagePath $update.fullname -Path $bootmountdir | Out-Null
                }
            }
            catch {
                Update-Log -Data 'Failed to apply updates to boot.wim index 2' -Class Error
                Update-Log -Data $_.Exception.Message -Class Error
            }

            # Dismount index 2
            try {
                Update-Log -Data 'Dismounting boot.wim index 2...' -Class Information
                Dismount-WindowsImage -Path $bootmountdir -Save | Out-Null
                Update-Log -Data 'boot.wim index 2 dismounted successfully' -Class Information
            }
            catch {
                Update-Log -Data 'Failed to dismount boot.wim index 2' -Class Error
                Update-Log -Data $_.Exception.Message -Class Error
            }
        }
        catch {
            Update-Log -Data 'Failed to update boot.wim' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
