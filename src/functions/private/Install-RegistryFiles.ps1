<#
.SYNOPSIS
    Apply registry files to the mounted image.

.DESCRIPTION
    This function applies registry modifications to the mounted Windows image
    by loading offline registry hives and importing registry files.

.NOTES
    Name:        Install-RegistryFiles.ps1
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
    Install-RegistryFiles
#>
function Install-RegistryFiles {
    [CmdletBinding()]
    param(

    )

    process {
        Update-Log -Data 'Mounting the offline registry hives...' -Class Information

        $regfiles = $WPFCustomLBRegistry.Items

        $DefaultUser = $WPFMISMountTextBox.Text + '\Users\Default\NTUSER.DAT'
        $Software = $WPFMISMountTextBox.Text + '\Windows\System32\Config\SOFTWARE'
        $System = $WPFMISMountTextBox.Text + '\Windows\System32\Config\SYSTEM'

        try {
            reg load HKLM\MountDefault $DefaultUser | Out-Null
            reg load HKLM\MountSoftware $Software | Out-Null
            reg load HKLM\MountSystem $System | Out-Null
            Update-Log -data 'Registry hives mounted successfully' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to mount registry hives' -Class Error
            Update-Log -data $_.Exception.Message -Class Error
            return
        }

        foreach ($regfile in $regfiles) {
            $text = 'Importing ' + $regfile
            Update-Log -Data $text -Class Information

            try {
                $regfile = $regfile -replace 'HKEY_LOCAL_MACHINE\\', 'HKLM\Mount'
                $regfile = $regfile -replace 'HKEY_CURRENT_USER\\', 'HKLM\MountDefault\\'
                Start-Process reg -ArgumentList "import $regfile" -Wait -WindowStyle Hidden
                Update-Log -Data 'Registry file imported successfully' -Class Information
            }
            catch {
                Update-Log -Data 'Failed to import registry file' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
            }
        }

        try {
            reg unload HKLM\MountDefault | Out-Null
            reg unload HKLM\MountSoftware | Out-Null
            reg unload HKLM\MountSystem | Out-Null
            Update-Log -Data 'Registry hives unmounted successfully' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to unmount registry hives' -Class Error
            Update-Log -data $_.Exception.Message -Class Error
        }
    }
}
