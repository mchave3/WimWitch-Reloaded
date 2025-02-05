<#
.SYNOPSIS
    Remove unwanted image indexes from the WIM.

.DESCRIPTION
    This function is used to remove unwanted image indexes from the WIM.

.NOTES
    Name:        remove-OSIndex.ps1
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
    Remove-OSIndex
#>
function Remove-OSIndex {
    [CmdletBinding()]
    param(

    )

    process {
        Update-Log -Data 'Attempting to remove unwanted image indexes' -Class Information
        $wimname = Get-Item -Path $Script:workdir\Staging\*.wim
    
        Update-Log -Data "Found Image $wimname" -Class Information
        $IndexesAll = Get-WindowsImage -ImagePath $wimname | ForEach-Object { $_.ImageName }
        $IndexSelected = $WPFSourceWIMImgDesTextBox.Text
        foreach ($Index in $IndexesAll) {
            Update-Log -data "$Index is being evaluated"
            If ($Index -eq $IndexSelected) {
                Update-Log -Data "$Index is the index we want to keep. Skipping." -Class Information | Out-Null
            } else {
                Update-Log -data "Deleting $Index from WIM" -Class Information
                Remove-WindowsImage -ImagePath $wimname -Name $Index -InformationAction SilentlyContinue | Out-Null
    
            }
        }
    }
}
