<#
.SYNOPSIS
    Select default application associations file.

.DESCRIPTION
    This function opens a file dialog to allow the user to select an XML file containing default application associations.
    It validates the selected file and updates the UI accordingly.

.NOTES
    Name:        Select-WWDefaultApplicationAssociation.ps1
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
    Select-WWDefaultApplicationAssociation
#>
function Select-WWDefaultApplicationAssociation {
    [CmdletBinding()]
    param(

    )

    process {
        $Sourcexml = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Filter           = 'XML (*.xml)|'
        }
        $null = $Sourcexml.ShowDialog()
        $WPFCustomTBDefaultApp.text = $Sourcexml.FileName

        if ($Sourcexml.FileName -notlike '*.xml') {
            Write-WimWitchLog -Data 'A XML file not selected. Please select a valid file to continue.' -Class Warning
            return
        }
        $text = $WPFCustomTBDefaultApp.text + ' selected as the default application XML'
        Write-WimWitchLog -Data $text -class Information
    }
}



