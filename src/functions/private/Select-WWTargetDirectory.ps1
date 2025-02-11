<#
.SYNOPSIS
    Select the target directory for the WIM file.

.DESCRIPTION
    This function is used to select the target directory for the WIM file.

.NOTES
    Name:        Select-WWTargetDirectory.ps1
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
    Select-WWTargetDirectory
#>
function Select-WWTargetDirectory {
    [CmdletBinding()]
    param(

    )

    process {
        Add-Type -AssemblyName System.Windows.Forms
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $browser.Description = 'Select the target folder'
        $null = $browser.ShowDialog()
        $TargetDir = $browser.SelectedPath
        $WPFMISWimFolderTextBox.text = $TargetDir
        Write-WimWitchLog -Data 'Target directory selected' -Class Information
    }
}



