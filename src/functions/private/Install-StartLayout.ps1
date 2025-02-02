<#
.SYNOPSIS
    Apply the start menu layout to the mounted image.

.DESCRIPTION
    This function applies a custom start menu layout to the mounted Windows image.
    It handles the file copying and registry modifications required for the layout.

.NOTES
    Name:        Install-StartLayout.ps1
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
    Install-StartLayout
#>
function Install-StartLayout {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            $startpath = $WPFMISMountTextBox.Text + '\users\default\appdata\local\microsoft\windows\shell'
            Update-Log -Data 'Copying the start menu file...' -Class Information
            
            if ((Test-Path -Path $startpath) -eq $false) {
                Update-Log -Data 'Creating shell folder path...' -Class Information
                New-Item -Path $startpath -ItemType Directory -Force | Out-Null
            }

            try {
                Copy-Item -Path $WPFCustomCBStartMenu.SelectedItem -Destination ($startpath + '\LayoutModification.xml') -Force
                Update-Log -Data 'Start menu layout copied successfully' -Class Information
            }
            catch {
                Update-Log -Data 'Failed to copy start menu layout' -Class Error
                Update-Log -Data $_.Exception.Message -Class Error
                return
            }

            Update-Log -Data 'Applying registry settings...' -Class Information
            try {
                $HKCUPath = $WPFMISMountTextBox.Text + '\Users\Default\NTUSER.DAT'
                $RegistryPath = 'HKLM\MountDefaultUser\Software\Policies\Microsoft\Windows\Explorer'
                
                reg load 'HKLM\MountDefaultUser' $HKCUPath | Out-Null
                reg add $RegistryPath /v LockedStartLayout /t REG_DWORD /d 1 /f | Out-Null
                reg add $RegistryPath /v StartLayoutFile /t REG_SZ /d '%LocalAppData%\Microsoft\Windows\Shell\LayoutModification.xml' /f | Out-Null
                reg unload 'HKLM\MountDefaultUser' | Out-Null
                
                Update-Log -Data 'Registry settings applied successfully' -Class Information
            }
            catch {
                Update-Log -Data 'Failed to apply registry settings' -Class Error
                Update-Log -Data $_.Exception.Message -Class Error
                return
            }
        }
        catch {
            Update-Log -Data 'Failed to install start layout' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
