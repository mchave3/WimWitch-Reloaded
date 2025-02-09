<#
.SYNOPSIS
    Import the Windows Image Info metadata from the WIM file to populate the Source WIM Info fields in the Source tab.

.DESCRIPTION
    This function imports the Windows Image Info metadata from the WIM file to populate the Source WIM Info fields in the Source tab.

.NOTES
    Name:        Import-WimInfo.ps1
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
    Import-WimInfo -IndexNumber 1
#>
function Import-WimInfo {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [int]$IndexNumber,

        [Parameter()]
        [switch]$SkipUserConfirmation
    )

    process {
        Write-WWLog -Data 'Importing Source WIM Info' -Class Information
        try {
            $ImageInfo = Get-WindowsImage -ImagePath $WPFSourceWIMSelectWIMTextBox.text -Index $IndexNumber -ErrorAction Stop
        } catch {
            Write-WWLog -data $_.Exception.Message -class Error
            Write-WWLog -data 'The WIM file selected may be borked. Try a different one' -Class Warning
            return
        }
        $text = 'WIM file selected: ' + $SourceWIM.FileName
        Write-WWLog -data $text -Class Information
        $text = 'Edition selected: ' + $ImageInfo.ImageName

        Write-WWLog -data $text -Class Information
        $ImageIndex = $IndexNumber

        $WPFSourceWIMImgDesTextBox.text = $ImageInfo.ImageName
        $WPFSourceWimVerTextBox.Text = $ImageInfo.Version
        $WPFSourceWimSPBuildTextBox.text = $ImageInfo.SPBuild
        $WPFSourceWimLangTextBox.text = $ImageInfo.Languages
        $WPFSourceWimIndexTextBox.text = $ImageIndex
        if ($ImageInfo.Architecture -eq 9) {
            $WPFSourceWimArchTextBox.text = 'x64'
        } Else {
            $WPFSourceWimArchTextBox.text = 'x86'
        }
        if ($WPFSourceWIMImgDesTextBox.text -like 'Windows Server*') {
            $WPFJSONEnableCheckBox.IsChecked = $False
            $WPFAppxCheckBox.IsChecked = $False
            $WPFAppTab.IsEnabled = $False
            $WPFAutopilotTab.IsEnabled = $False
            $WPFMISAppxTextBox.text = 'False'
            $WPFMISJSONTextBox.text = 'False'
            $WPFMISOneDriveCheckBox.IsChecked = $False
            $WPFMISOneDriveCheckBox.IsEnabled = $False
        } Else {
            $WPFAppTab.IsEnabled = $True
            $WPFAutopilotTab.IsEnabled = $True
            $WPFMISOneDriveCheckBox.IsEnabled = $True
        }

        if ($SkipUserConfirmation -eq $False) {
            $WPFSourceWimTBVersionNum.text = Get-WinVersionNumber
        }
    }
}

