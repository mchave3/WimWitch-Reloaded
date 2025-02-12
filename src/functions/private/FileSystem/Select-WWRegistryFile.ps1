<#
.SYNOPSIS
    Select registry files to import.

.DESCRIPTION
    This function opens a file dialog to allow the user to select one or more registry files (.reg) to import into
    the mounted Windows image. It validates the selected files and updates the UI accordingly.

.NOTES
    Name:        Select-WWRegistryFile.ps1
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
    Select-WWRegistryFile
#>
function Select-WWRegistryFile {
    [CmdletBinding()]
    param(

    )

    process {
        $Regfiles = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Multiselect      = $true # Multiple files can be chosen
            Filter           = 'REG (*.reg)|'
        }
        $null = $Regfiles.ShowDialog()

        $filepaths = $regfiles.FileNames
        Write-WimWitchLog -data 'Importing REG files...' -class information
        foreach ($filepath in $filepaths) {
            if ($filepath -notlike '*.reg') {
                Write-WimWitchLog -Data $filepath -Class Warning
                Write-WimWitchLog -Data 'Ignoring this file as it is not a .REG file....' -Class Warning
                return
            }
            Write-WimWitchLog -Data $filepath -Class Information
            $WPFCustomLBRegistry.Items.Add($filepath)
        }
        Write-WimWitchLog -data 'REG file importation complete' -class information

        #Fix this shit, then you can release her.
    }
}




