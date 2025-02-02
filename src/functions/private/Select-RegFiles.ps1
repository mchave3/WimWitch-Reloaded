<#
.SYNOPSIS
    Select registry files to import.

.DESCRIPTION
    This function opens a file dialog to allow the user to select one or more
    registry files (.reg) to import into the mounted Windows image. It validates
    the selected files and updates the UI accordingly.

.NOTES
    Name:        Select-RegFiles.ps1
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
    Select-RegFiles
#>
function Select-RegFiles {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Opening file selection dialog for registry files...' -Class Information
            
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
            $FileBrowser.Filter = "Registry Files (*.reg)|*.reg|All Files (*.*)|*.*"
            $FileBrowser.Title = "Select Registry Files"
            $FileBrowser.Multiselect = $true
            
            if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                foreach ($file in $FileBrowser.FileNames) {
                    if (Test-Path -Path $file) {
                        $WPFCustomLBRegistry.Items.Add($file)
                        Update-Log -Data "Added registry file: $file" -Class Information
                    }
                }
                
                # Enable apply button if files are selected
                if ($WPFCustomLBRegistry.Items.Count -gt 0) {
                    $WPFCustomBRegistry.IsEnabled = $true
                }
            }
            else {
                Update-Log -Data 'File selection cancelled by user' -Class Information
            }
        }
        catch {
            Update-Log -Data 'Failed to select registry files' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
