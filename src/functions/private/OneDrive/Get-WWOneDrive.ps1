﻿<#
.SYNOPSIS
    Download the latest OneDrive agent installers.

.DESCRIPTION
    This function is used to download the latest OneDrive agent installers.

.NOTES
    Name:        Get-WWOneDrive.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

    Most of this function was stolen from David Segura @SeguraOSD

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Get-WWOneDrive
#>
function Get-WWOneDrive {
    [CmdletBinding()]
    param(

    )

    process {
        #https://go.microsoft.com/fwlink/p/?LinkID=844652 -Possible new link location.
        #https://go.microsoft.com/fwlink/?linkid=2181064 - x64 installer

        Write-WimWitchLog -Data 'Downloading latest 32-bit OneDrive agent installer...' -class Information
        $DownloadUrl = 'https://go.microsoft.com/fwlink/p/?LinkId=248256'
        $DownloadPath = "$script:workingDirectory\updates\OneDrive"
        $DownloadFile = 'OneDriveSetup.exe'

        if (!(Test-Path "$DownloadPath")) { New-Item -Path $DownloadPath -ItemType Directory -Force | Out-Null }
        Invoke-WebRequest -Uri $DownloadUrl -OutFile "$DownloadPath\$DownloadFile"
        if (Test-Path "$DownloadPath\$DownloadFile") {
            Write-WimWitchLog -Data 'OneDrive Download Complete' -Class Information
        } else {
            Write-WimWitchLog -Data 'OneDrive could not be downloaded' -Class Error
        }

        Write-WimWitchLog -Data 'Downloading latest 64-bit OneDrive agent installer...' -class Information
        $DownloadUrl = 'https://go.microsoft.com/fwlink/?linkid=2181064'
        $DownloadPath = "$script:workingDirectory\updates\OneDrive\x64"
        $DownloadFile = 'OneDriveSetup.exe'

        if (!(Test-Path "$DownloadPath")) { New-Item -Path $DownloadPath -ItemType Directory -Force | Out-Null }
        Invoke-WebRequest -Uri $DownloadUrl -OutFile "$DownloadPath\$DownloadFile"
        if (Test-Path "$DownloadPath\$DownloadFile") {
            Write-WimWitchLog -Data 'OneDrive Download Complete' -Class Information
        } else {
            Write-WimWitchLog -Data 'OneDrive could not be downloaded' -Class Error
        }
    }
}

