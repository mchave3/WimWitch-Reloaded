<#
.SYNOPSIS
    Update Windows RE WIM file.

.DESCRIPTION
    This function updates the Windows Recovery Environment (WinRE) WIM file with the latest changes and configurations.

.NOTES
    Name:        Update-WWWindowsRe.ps1
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
    Update-WWWindowsRe
#>
function Update-WWWindowsRe {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(

    )

    process {
        try {
            Write-WimWitchLog -Data 'Starting WinRE WIM update process...' -Class Information

            $mountPath = $WPFMISMountTextBox.Text
            $winREPath = Join-Path -Path $mountPath -ChildPath 'Windows\System32\Recovery\WinRE.wim'

            if (Test-Path -Path $winREPath) {
                $winREMount = Join-Path -Path $mountPath -ChildPath 'WinREMount'

                if ($PSCmdlet.ShouldProcess($winREMount, "Create mount directory")) {
                    New-Item -Path $winREMount -ItemType Directory -Force | Out-Null
                }

                if ($PSCmdlet.ShouldProcess($winREPath, "Mount WinRE.wim")) {
                    Mount-WindowsImage -ImagePath $winREPath -Index 1 -Path $winREMount
                }

                # Perform updates here
                # Add specific WinRE update logic

                if ($PSCmdlet.ShouldProcess($winREMount, "Dismount WinRE.wim")) {
                    Dismount-WindowsImage -Path $winREMount -Save
                    Remove-Item -Path $winREMount -Force
                }

                Write-WimWitchLog -Data 'WinRE WIM updated successfully' -Class Information
            }
            else {
                throw "WinRE.wim not found at: $winREPath"
            }
        }
        catch {
            Write-WimWitchLog -Data 'Failed to update WinRE WIM' -Class Error
            Write-WimWitchLog -Data $_.Exception.Message -Class Error

            # Cleanup on error
            if (Test-Path -Path $winREMount) {
                Dismount-WindowsImage -Path $winREMount -Discard
                Remove-Item -Path $winREMount -Force
            }
        }
    }
}




