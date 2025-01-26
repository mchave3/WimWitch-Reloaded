<#
.SYNOPSIS
.DESCRIPTION
    This function is used to select a WIM file and then select an index from that WIM file.
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
