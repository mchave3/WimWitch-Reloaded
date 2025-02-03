<#
.SYNOPSIS
    Select ISO staging directory.

.DESCRIPTION
    This function opens a folder browser dialog to allow the user to select
    a directory for ISO staging. It validates the selected directory and
    updates the UI accordingly.

.NOTES
    Name:        Select-ISODirectory.ps1
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
    Select-ISODirectory
#>
function Select-ISODirectory {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Opening folder selection dialog for ISO staging...' -Class Information
            
            Add-Type -AssemblyName System.Windows.Forms
            $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
            $FolderBrowser.Description = "Select ISO Staging Directory"
            
            if ($FolderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $WPFMISISOSelection.Text = $FolderBrowser.SelectedPath
                Update-Log -Data "Selected ISO staging directory: $($FolderBrowser.SelectedPath)" -Class Information
                
                # Enable related controls if directory is selected
                if ($WPFMISISOSelection.Text.Length -gt 0) {
                    $WPFMISISOSelectButton.IsEnabled = $true
                }
            }
            else {
                Update-Log -Data 'Directory selection cancelled by user' -Class Information
            }
        }
        catch {
            Update-Log -Data 'Failed to select ISO staging directory' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
