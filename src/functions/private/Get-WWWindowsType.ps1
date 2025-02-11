<#
.SYNOPSIS
    Determines the Windows type from the image description.

.DESCRIPTION
    This function analyzes the image description to determine if it's Windows 10, Windows 11, or Windows Server.

.NOTES
    Name:        Get-WWWindowsType.ps1
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
    $OSType = Get-WWWindowsType
#>
function Get-WWWindowsType {
    [CmdletBinding()]
    [OutputType([string])]
    param(

    )

    process {
        if ($WPFSourceWIMImgDesTextBox.Text -like '*Windows 10*') {
            return 'Windows 10'
        }
        elseif ($WPFSourceWIMImgDesTextBox.Text -like '*Windows 11*') {
            return 'Windows 11'
        }
        elseif ($WPFSourceWIMImgDesTextBox.Text -like '*Windows Server*') {
            return 'Windows Server'
        }
        else {
            Write-WimWitchLog -Data "Could not determine Windows type from description: $($WPFSourceWIMImgDesTextBox.Text)" -Class Warning
            return $null
        }
    }
}


