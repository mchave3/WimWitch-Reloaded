<#
.SYNOPSIS
    Select default application associations file.

.DESCRIPTION
    This function opens a file dialog to allow the user to select an XML file
    containing default application associations. It validates the selected file
    and updates the UI accordingly.

.NOTES
    Name:        Select-DefaultApplicationAssociations.ps1
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
    Select-DefaultApplicationAssociations
#>
function Select-DefaultApplicationAssociations {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Opening file selection dialog for default app associations...' -Class Information
            
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
            $FileBrowser.Filter = "XML Files (*.xml)|*.xml|All Files (*.*)|*.*"
            $FileBrowser.Title = "Select Default App Associations File"
            
            if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $WPFCustomDefaultAppTextBox.Text = $FileBrowser.FileName
                Update-Log -Data "Selected default app associations file: $($FileBrowser.FileName)" -Class Information
            }
            else {
                Update-Log -Data 'File selection cancelled by user' -Class Information
            }
        }
        catch {
            Update-Log -Data 'Failed to select default application associations file' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
