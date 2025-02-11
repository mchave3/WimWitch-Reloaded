<#
.SYNOPSIS
    Install a driver to a mounted WIM file.

.DESCRIPTION
    This function installs a driver to a mounted WIM file.

.NOTES
    Name:        Install-WWDriver.ps1
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
    Install-WWDriver -drivertoapply "C:\Drivers\Driver.inf"
#>
function Install-WWDriver {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $drivertoapply
    )

    process {
        try {
            Add-WindowsDriver -Path $WPFMISMountTextBox.Text -Driver $drivertoapply -ErrorAction Stop | Out-Null
            Write-WimWitchLog -Data "Applied $drivertoapply" -Class Information
        } catch {
            Write-WimWitchLog -Data "Couldn't apply $drivertoapply" -Class Warning
        }
    }
}




