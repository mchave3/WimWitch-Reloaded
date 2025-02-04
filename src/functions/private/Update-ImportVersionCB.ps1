<#
.SYNOPSIS
    Update the Windows version combo box based on the selected OS.

.DESCRIPTION
    This function updates the Windows version combo box with appropriate versions based on the selected operating system
    (Windows Server, Windows 10, or Windows 11).

.NOTES
    Name:        Update-ImportVersionCB.ps1
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
    Update-ImportVersionCB
#>
function Update-ImportVersionCB {
    [CmdletBinding()]
    param(

    )

    process {
        $WPFImportOtherCBWinVer.Items.Clear()
        if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows Server') { 
            Foreach ($WinSrvVer in $WinSrvVer) { 
                $WPFImportOtherCBWinVer.Items.Add($WinSrvVer) 
            } 
        }
        if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 10') { 
            Foreach ($Win10Ver in $Win10ver) { 
                $WPFImportOtherCBWinVer.Items.Add($Win10Ver) 
            } 
        }
        if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') { 
            Foreach ($Win11Ver in $Win11ver) { 
                $WPFImportOtherCBWinVer.Items.Add($Win11Ver) 
            } 
        }
    }
}
