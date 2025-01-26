<#
.SYNOPSIS
.DESCRIPTION
    This function is used to select the driver source folder.
#>
function Select-DriverSource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]$DriverTextBoxNumber
    )

    process {
        Add-Type -AssemblyName System.Windows.Forms
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $browser.Description = 'Select the Driver Source folder'
        $null = $browser.ShowDialog()
        $DriverDir = $browser.SelectedPath
        $DriverTextBoxNumber.Text = $DriverDir
        Update-Log -Data "Driver path selected: $DriverDir" -Class Information
    }
}
