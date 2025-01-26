<#
.SYNOPSIS
.DESCRIPTION
    This function is used to select the target directory for the WIM file.
#>
function Select-TargetDir {
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
        Update-Log -Data 'Target directory selected' -Class Information
    }
}
