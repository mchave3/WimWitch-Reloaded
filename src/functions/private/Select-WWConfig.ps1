<#
.SYNOPSIS
    Select the configuration file to load.

.DESCRIPTION
    This function is used to select wich configuration file to load.

.NOTES
    Name:        Select-WWConfig.ps1
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
    Select-WWConfig
#>
function Select-WWConfig {
    [CmdletBinding()]
    param(

    )

    process {
        $SourceXML = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = "$Script:workdir\Configs"
            Filter           = 'XML (*.XML)|'
        }
        $null = $SourceXML.ShowDialog()
        $WPFSLLoadTextBox.text = $SourceXML.FileName
        Get-WWConfiguration -filename $WPFSLLoadTextBox.text
    }
}




