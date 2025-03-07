﻿<#
.SYNOPSIS
    Copy staged installation media to the CM package folder.

.DESCRIPTION
    This function copies Windows upgrade package files to the specified destination. It handles file copying and validates the process.

.NOTES
    Name:        Copy-WWUpgradePackage.ps1
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
    Copy-WWUpgradePackage
#>
function Copy-WWUpgradePackage {
    [CmdletBinding()]
    param(

    )

    process {
        #copy staging folder to destination with force parameter
        try {
            Write-WimWitchLog -data 'Copying updated media to Upgrade Package folder...' -Class Information
            Copy-Item -Path $script:workingDirectory\staging\media\* -Destination $WPFMISTBUpgradePackage.text -Force -Recurse -ErrorAction Stop
            Write-WimWitchLog -Data 'Updated media has been copied' -Class Information
        } catch {
            Write-WimWitchLog -Data "Couldn't copy the updated media to the upgrade package folder" -Class Error
            Write-WimWitchLog -data $_.Exception.Message -class Error
        }
    }
}

