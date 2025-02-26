<#
.SYNOPSIS
    Function to select a JSON file.

.DESCRIPTION
    This function will open a file dialog to select a JSON file.

.NOTES
    Name:        Select-WWJSONFile.ps1
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
    Select-WWJSONFile
#>
function Select-WWJSONFile {
    [CmdletBinding()]
    param(

    )

    process {
        $JSON = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Filter           = 'JSON (*.JSON)|'
        }
        $null = $JSON.ShowDialog()
        $WPFJSONTextBox.Text = $JSON.FileName

        $text = 'JSON file selected: ' + $JSON.FileName
        Write-WimWitchLog -Data $text -Class Information
        Convert-WWJSONToObject -file $JSON.FileName
    }
}

