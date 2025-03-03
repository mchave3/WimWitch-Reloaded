<#
.SYNOPSIS
    Select the directory where the ISO will be saved.

.DESCRIPTION
    This function allows the user to select the directory where the ISO will be saved.

.NOTES
    Name:        Select-WWISODirectory.ps1
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
    Select-WWISODirectory
#>
function Select-WWISODirectory {
    [CmdletBinding()]
    param(

    )

    process {
        Add-Type -AssemblyName System.Windows.Forms
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $browser.Description = 'Select the folder to save the ISO'
        $null = $browser.ShowDialog()
        $MountDir = $browser.SelectedPath
        $WPFMISTBFilePath.text = $MountDir
        #Test-WWMountPath -path $WPFMISMountTextBox.text
        Write-WimWitchLog -Data 'ISO directory selected' -Class Information
    }
}

