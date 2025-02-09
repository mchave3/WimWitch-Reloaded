<#
.SYNOPSIS
    Select the folder to save the Autopilot JSON file.

.DESCRIPTION
    This function is used to select wich folder to save the Autopilot JSON file.

.NOTES
    Name:        Select-NewJSONDir.ps1
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
    Select-NewJSONDir
#>
function Select-NewJSONDir {
    [CmdletBinding()]
    param(

    )

    process {
        Add-Type -AssemblyName System.Windows.Forms
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $browser.Description = 'Select the folder to save JSON'
        $null = $browser.ShowDialog()
        $SaveDir = $browser.SelectedPath
        $WPFJSONTextBoxSavePath.text = $SaveDir
        $text = "Autopilot profile save path selected: $SaveDir"
        Write-WWLog -Data $text -Class Information
    }
}
