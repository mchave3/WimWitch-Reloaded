<#
.SYNOPSIS
.DESCRIPTION
    This function imports the Windows Image Info metadata from the WIM file to populate the Source WIM Info fields in the Source tab.
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
        Update-Log -Data 'Importing Source WIM Info' -Class Information
        try {
            $ImageInfo = Get-WindowsImage -ImagePath $WPFSourceWIMSelectWIMTextBox.text -Index $IndexNumber -ErrorAction Stop
        } catch {
            Update-Log -data $_.Exception.Message -class Error
            Update-Log -data 'The WIM file selected may be borked. Try a different one' -Class Warning
            return
        }
        $text = 'WIM file selected: ' + $SourceWIM.FileName
        Update-Log -data $text -Class Information
        $text = 'Edition selected: ' + $ImageInfo.ImageName

        Update-Log -data $text -Class Information
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
