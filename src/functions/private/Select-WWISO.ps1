<#
.SYNOPSIS
    Select an ISO file to import from.

.DESCRIPTION
    This function is used to select an ISO file to import from.

.NOTES
    Name:        Select-WWISO.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Select-WWISO
#>
function Select-WWISO {
    [CmdletBinding()]
    param(

    )

    process {
        $SourceISO = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Filter           = 'ISO (*.iso)|'
        }
        $null = $SourceISO.ShowDialog()
        $WPFImportISOTextBox.text = $SourceISO.FileName

        if ($SourceISO.FileName -notlike '*.iso') {
            Write-WimWitchLog -Data 'An ISO file not selected. Please select a valid file to continue.' -Class Warning
            return
        }
        $text = $WPFImportISOTextBox.text + ' selected as the ISO to import from'
        Write-WimWitchLog -Data $text -class Information
    }
}


