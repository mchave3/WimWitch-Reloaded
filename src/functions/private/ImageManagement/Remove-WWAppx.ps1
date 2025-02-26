<#
.SYNOPSIS
    Remove Appx packages from the WIM.

.DESCRIPTION
    This function is used to remove Appx packages from the WIM.

.NOTES
    Name:        Remove-WWAppx.ps1
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
    Remove-WWAppx -array $exappxs
#>
function Remove-WWAppx {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [array]$array
    )

    process {
        $exappxs = $array
        Write-WimWitchLog -data 'Starting AppX removal' -class Information
        foreach ($exappx in $exappxs) {
            if ($PSCmdlet.ShouldProcess($exappx, "Remove AppX Package")) {
                try {
                    Remove-AppxProvisionedPackage -Path $WPFMISMountTextBox.Text -PackageName $exappx -ErrorAction Stop | Out-Null
                    Write-WimWitchLog -data "Removing $exappx" -Class Information
                } catch {
                    Write-WimWitchLog -Data "Failed to remove $exappx" -Class Error
                    Write-WimWitchLog -Data $_.Exception.Message -Class Error
                }
            }
        }
        return
    }
}

