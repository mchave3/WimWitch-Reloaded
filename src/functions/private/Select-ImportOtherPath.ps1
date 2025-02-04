<#
.SYNOPSIS
    Select a source folder for importing objects.

.DESCRIPTION
    This function opens a folder browser dialog to allow the user to select a source folder for importing 
    various objects (Language Packs, FODs, etc.).

.NOTES
    Name:        Select-ImportOtherPath.ps1
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
    Select-ImportOtherPath
#>
function Select-ImportOtherPath {
    [CmdletBinding()]
    param(

    )

    process {
        Add-Type -AssemblyName System.Windows.Forms
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $browser.Description = 'Source folder'
        $null = $browser.ShowDialog()
        $ImportPath = $browser.SelectedPath + '\'
        $WPFImportOtherTBPath.text = $ImportPath
    }
}
