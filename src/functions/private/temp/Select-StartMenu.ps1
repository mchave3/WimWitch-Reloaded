<#
.SYNOPSIS
    Select start menu layout file.

.DESCRIPTION
    This function opens a file dialog to allow the user to select an XML file
    containing a custom start menu layout. It validates the selected file
    and updates the UI accordingly.

.NOTES
    Name:        Select-StartMenu.ps1
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
    Select-StartMenu
#>
function Select-StartMenu {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Opening file selection dialog for start menu layout...' -Class Information
            
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
            $FileBrowser.Filter = "XML Files (*.xml)|*.xml|All Files (*.*)|*.*"
            $FileBrowser.Title = "Select Start Menu Layout File"
            
            if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $WPFCustomStartMenuTextBox.Text = $FileBrowser.FileName
                Update-Log -Data "Selected start menu layout file: $($FileBrowser.FileName)" -Class Information
                
                # Enable apply button if file is selected
                if ($WPFCustomStartMenuTextBox.Text.Length -gt 0) {
                    $WPFCustomBStartMenu.IsEnabled = $true
                }
            }
            else {
                Update-Log -Data 'File selection cancelled by user' -Class Information
            }
        }
        catch {
            Update-Log -Data 'Failed to select start menu layout file' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
