<#
.SYNOPSIS
.DESCRIPTION
    This function installs a driver to a mounted WIM file.
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
            Update-Log -Data "Applied $drivertoapply" -Class Information
        } catch {
            Update-Log -Data "Couldn't apply $drivertoapply" -Class Warning
        }
    }
}
