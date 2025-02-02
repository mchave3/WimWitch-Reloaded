<#
.SYNOPSIS
    Copy ISO media files to the staging area.

.DESCRIPTION
    This function copies ISO media files to the staging area, preparing them
    for ISO creation. It handles different Windows versions and their specific requirements.

.NOTES
    Name:        Copy-StageIsoMedia.ps1
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
    Copy-StageIsoMedia
#>
function Copy-StageIsoMedia {
    [CmdletBinding()]
    param(

    )

    process {
        $OS = Get-WindowsType
        $buildnum = Get-WinVersionNumber
        $ISOMedia = $global:workdir + '\staging\media'

        Update-Log -Data 'Copying ISO files to staging folder...' -Class Information

        if ((Test-Path -Path $ISOMedia) -eq $true) {
            Update-Log -Data 'Removing existing ISO files from staging...' -Class Information
            Remove-Item -Path $ISOMedia -Recurse -Force
        }

        if ($OS -eq 'Windows 10') {
            $MediaPath = $global:workdir + '\imports\iso\windows 10\' + $buildnum
        }
        if ($OS -eq 'Windows Server') {
            $MediaPath = $global:workdir + '\imports\iso\Windows Server\' + $buildnum
        }
        if ($OS -eq 'Windows 11') {
            $MediaPath = $global:workdir + '\imports\iso\Windows 11\' + $buildnum
        }

        try {
            Update-Log -Data 'Copying media files...' -Class Information
            Copy-Item -Path $MediaPath -Destination $ISOMedia -Recurse
            Update-Log -Data 'Media files copied successfully' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to copy media files' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
            return
        }

        # Copy boot files
        try {
            Update-Log -Data 'Copying boot files...' -Class Information
            $bootfiles = $global:workdir + '\staging\bootfiles\*'
            Copy-Item -Path $bootfiles -Destination $ISOMedia -Recurse -Force
            Update-Log -Data 'Boot files copied successfully' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to copy boot files' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
