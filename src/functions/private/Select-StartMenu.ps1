<#
.SYNOPSIS
    Select start menu layout file.

.DESCRIPTION
    This function opens a file dialog to allow the user to select an XML file containing a custom start menu layout.
    It validates the selected file and updates the UI accordingly.

.NOTES
    Name:        Select-StartMenu.ps1
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
    Select-StartMenu
#>
function Select-StartMenu {
    [CmdletBinding()]
    param(

    )

    process {
        $OS = Get-WindowsType

        if ($OS -ne 'Windows 11') {
            $Sourcexml = New-Object System.Windows.Forms.OpenFileDialog -Property @{
                InitialDirectory = [Environment]::GetFolderPath('Desktop')
                Filter           = 'XML (*.xml)|'
            }
        }

        if ($OS -eq 'Windows 11') {
            $Sourcexml = New-Object System.Windows.Forms.OpenFileDialog -Property @{
                InitialDirectory = [Environment]::GetFolderPath('Desktop')
                Filter           = 'JSON (*.JSON)|'
            }
        }

        $null = $Sourcexml.ShowDialog()
        $WPFCustomTBStartMenu.text = $Sourcexml.FileName

        if ($OS -ne 'Windows 11') {
            if ($Sourcexml.FileName -notlike '*.xml') {
                Write-WWLog -Data 'A XML file not selected. Please select a valid file to continue.' -Class Warning
                return
            }
        }

        if ($OS -eq 'Windows 11') {
            if ($Sourcexml.FileName -notlike '*.json') {
                Write-WWLog -Data 'A JSON file not selected. Please select a valid file to continue.' -Class Warning
                return
            }
        }

        $text = $WPFCustomTBStartMenu.text + ' selected as the start menu file'
        Write-WWLog -Data $text -class Information
    }
}

