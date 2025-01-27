<#
.SYNOPSIS
    Remove Appx packages from the WIM.

.DESCRIPTION
    This function is used to remove Appx packages from the WIM.

.NOTES
    Name:        Remove-Appx.ps1
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
    Remove-Appx -array $exappxs
#>
function Remove-Appx {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$array
    )

    process {
        $exappxs = $array
        Update-Log -data 'Starting AppX removal' -class Information
        foreach ($exappx in $exappxs) {
            try {
                Remove-AppxProvisionedPackage -Path $WPFMISMountTextBox.Text -PackageName $exappx -ErrorAction Stop | Out-Null
                Update-Log -data "Removing $exappx" -Class Information
            } catch {
                Update-Log -Data "Failed to remove $exappx" -Class Error
                Update-Log -Data $_.Exception.Message -Class Error
            }
        }
        return
    }
}
