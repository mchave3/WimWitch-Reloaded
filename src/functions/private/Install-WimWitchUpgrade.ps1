<#
.SYNOPSIS
    This function will prompt the user to upgrade WIM Witch.

.DESCRIPTION
    This function will prompt the user to upgrade WIM Witch.
    If the user chooses to upgrade, the script will backup the current version of WIM Witch, save the current
    version of WIM Witch to the working directory, and exit WIM Witch.
    The user will need to restart WIM Witch to apply the upgrade. If the user chooses not to upgrade, the script
    will log the decision and continue to start WIM Witch.

.NOTES
    Name:        Install-WimWitchUpgrade.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Install-WimWitchUpgrade
#>
function Install-WimWitchUpgrade {
    [CmdletBinding()]
    param(

    )

    process {
        Write-Output 'Would you like to upgrade WIM Witch?'
        $yesno = Read-Host -Prompt '(Y/N)'
        Write-Output $yesno
        if (($yesno -ne 'Y') -and ($yesno -ne 'N')) {
            Write-Output 'Invalid entry, try again.'
            Install-WimWitchUpgrade
        }

        if ($yesno -eq 'y') {
            Backup-WIMWitch

            try {
                Save-Script -Name 'WIMWitch' -Path $Script:workdir -Force -ErrorAction Stop
                Write-Output 'New version has been applied. WIM Witch will now exit.'
                Write-Output 'Please restart WIM Witch'
                exit
            } catch {
                Write-Output "Couldn't upgrade. Try again when teh tubes are clear"
                return
            }

        }
        if ($yesno -eq 'n') {
            Write-Output "You'll want to upgrade at some point."
            Write-WimWitchLog -Data 'Upgrade to new version was declined' -Class Warning
            Write-WimWitchLog -Data 'Continuing to start WIM Witch...' -Class Warning
        }
    }
}




