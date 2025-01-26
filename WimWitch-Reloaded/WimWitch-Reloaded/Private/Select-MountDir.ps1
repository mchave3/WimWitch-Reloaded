<#
.SYNOPSIS
.DESCRIPTION
    This function opens a folder browser dialog to select the mount folder.
#>
function Select-MountDir {
    [CmdletBinding()]
    param(

    )

    process {
        Add-Type -AssemblyName System.Windows.Forms
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $browser.Description = 'Select the mount folder'
        $null = $browser.ShowDialog()
        $MountDir = $browser.SelectedPath
        $WPFMISMountTextBox.text = $MountDir
        Test-MountPath -path $WPFMISMountTextBox.text
        Update-Log -Data 'Mount directory selected' -Class Information
    }
}
