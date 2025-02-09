<#
.SYNOPSIS
    Install a driver to a mounted WIM file.

.DESCRIPTION
    This function installs a driver to a mounted WIM file.

.NOTES
    Name:        Install-Driver.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-27
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Install-Driver -drivertoapply "C:\Drivers\Driver.inf"
#>
function Install-Driver {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $drivertoapply
    )

    process {
        try {
            Add-WindowsDriver -Path $WPFMISMountTextBox.Text -Driver $drivertoapply -ErrorAction Stop | Out-Null
            Write-WWLog -Data "Applied $drivertoapply" -Class Information
        } catch {
            Write-WWLog -Data "Couldn't apply $drivertoapply" -Class Warning
        }
    }
}

