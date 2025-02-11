<#
.SYNOPSIS
    Function to select the mount folder.

.DESCRIPTION
    This function opens a folder browser dialog to select the mount folder.

.NOTES
    Name:        Select-WWMountDirectory.ps1
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
    Select-WWMountDirectory
#>
function Select-WWMountDirectory {
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
        Test-WWMountPath -path $WPFMISMountTextBox.text
        Write-WimWitchLog -Data 'Mount directory selected' -Class Information
    }
}


