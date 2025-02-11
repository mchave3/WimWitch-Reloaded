<#
.SYNOPSIS
    Function to select the driver source folder.

.DESCRIPTION
    This function is used to select the driver source folder.

.NOTES
    Name:        Select-WWDriverSource.ps1
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
    Select-WWDriverSource -DriverTextBoxNumber $DriverTextBox1
#>
function Select-WWDriverSource {
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
        Write-WimWitchLog -Data "Driver path selected: $DriverDir" -Class Information
    }
}




