<#
.SYNOPSIS
    Update the Windows version combo box based on the selected OS.

.DESCRIPTION
    This function updates the Windows version combo box with appropriate versions based on the selected operating system
    (Windows Server, Windows 10, or Windows 11).

.NOTES
    Name:        Import-WWVersionCallback.ps1
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
    Import-WWVersionCallback
#>
function Import-WWVersionCallback {
    [CmdletBinding()]
    param(

    )

    process {
        $WPFImportOtherCBWinVer.Items.Clear()
        if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows Server') {
            Foreach ($Script:WinSrvVer in $Script:WinSrvVer) {
                $WPFImportOtherCBWinVer.Items.Add($Script:WinSrvVer)
            }
        }
        if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 10') {
            Foreach ($Script:Win10Ver in $Script:Win10Ver) {
                $WPFImportOtherCBWinVer.Items.Add($Script:Win10Ver)
            }
        }
        if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') {
            Foreach ($Script:Win11Ver in $Script:Win11Ver) {
                $WPFImportOtherCBWinVer.Items.Add($Script:Win11Ver)
            }
        }
    }
}




