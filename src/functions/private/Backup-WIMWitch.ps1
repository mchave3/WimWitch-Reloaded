<#
.SYNOPSIS
    Backup the existing WIM Witch script before upgrading to a new version.

.DESCRIPTION
    This function is used to backup the existing WIM Witch script before upgrading to a new version.

.NOTES
    Name:        Backup-WIMWitch.ps1
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
    Backup-WIMWitch
#>
function Backup-WIMWitch {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WimWitchLog -data 'Backing up existing WIM Witch script...' -Class Information

        $scriptname = Split-Path $MyInvocation.PSCommandPath -Leaf #Find local script name
        Write-WimWitchLog -data 'The script to be backed up is: ' -Class Information
        Write-WimWitchLog -data $MyInvocation.PSCommandPath -Class Information
        try {
            Write-WimWitchLog -data 'Copy script to backup folder...' -Class Information
            Copy-Item -Path $scriptname -Destination $Script:workdir\backup -ErrorAction Stop
            Write-WimWitchLog -Data 'Successfully copied...' -Class Information
        } catch {
            Write-WimWitchLog -data "Couldn't copy the WIM Witch script. My guess is a permissions issue" -Class Error
            Write-WimWitchLog -Data 'Exiting out of an over abundance of caution' -Class Error
            exit
        }
        try {
            Write-WimWitchLog -data 'Renaming archived script...' -Class Information
            Rename-WWName -file $Script:workdir\backup\$scriptname -extension '.ps1'
            Write-WimWitchLog -data 'Backup successfully renamed for archiving' -class Information
        } catch {
            Write-WimWitchLog -Data "Backed-up script couldn't be renamed. This isn't a critical error" -Class Warning
            Write-WimWitchLog -Data "You may want to change it's name so it doesn't get overwritten." -Class Warning
            Write-WimWitchLog -Data 'Continuing with WIM Witch upgrade...' -Class Warning
        }
    }
}



