<#
.SYNOPSIS
    Select a WIM file and then select an index from that WIM file.

.DESCRIPTION
    This function is used to select a WIM file and then select an index from that WIM file.

.NOTES
    Name:        Select-SourceWIM.ps1
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
    Select-SourceWIM
#>
function Select-SourceWIM {
    [CmdletBinding()]
    param(

    )

    process {
        $SourceWIM = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = "$global:workdir\imports\wim"
            Filter           = 'WIM (*.wim)|'
        }
        $null = $SourceWIM.ShowDialog()
        $WPFSourceWIMSelectWIMTextBox.text = $SourceWIM.FileName
    
        if ($SourceWIM.FileName -notlike '*.wim') {
            Update-Log -Data 'A WIM file not selected. Please select a valid file to continue.' -Class Warning
            return
        }
    
        #Select the index
        $ImageFull = @(Get-WindowsImage -ImagePath $WPFSourceWIMSelectWIMTextBox.text)
        $a = $ImageFull | Out-GridView -Title 'Choose an Image Index' -PassThru
        $IndexNumber = $a.ImageIndex
        if ($null -eq $indexnumber) {
            Update-Log -Data 'Index not selected. Reselect the WIM file to select an index' -Class Warning
            return
        }
    
        Import-WimInfo -IndexNumber $IndexNumber
    }
}
