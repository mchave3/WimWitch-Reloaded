﻿<#
.SYNOPSIS
    Initializes the required folder structure and logging for WIMWitch.

.DESCRIPTION
    This function creates and manages the essential folders and log file for WIMWitch operations:
    - Logging folder and WIMWitch.log file
    - Updates folder for storing Windows updates
    - Staging folder for temporary files
    - Mount folder for mounting WIM files
    - CompletedWIMs folder for output files
    - Configs folder for XML configurations

.NOTES
    Name:        Initialize-WimWitchEnvironment.ps1
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
    Initialize-WimWitchEnvironment
#>
function Initialize-WimWitchEnvironment {
    [CmdletBinding()]
    param(

    )

    process {
        # Initialize or reset the log file
        if (!(Test-Path -Path "$script:workingDirectory\logging\WIMWitch.Log" -PathType Leaf)) {
            New-Item -ItemType Directory -Force -Path "$script:workingDirectory\Logging" | Out-Null
            New-Item -Path "$script:workingDirectory\logging" -Name 'WIMWitch.log' -ItemType 'file' -Value '***Logging Started***' | Out-Null
        } Else {
            Remove-Item -Path "$script:workingDirectory\logging\WIMWitch.log"
            New-Item -Path "$script:workingDirectory\logging" -Name 'WIMWitch.log' -ItemType 'file' -Value '***Logging Started***' | Out-Null
        }

        # Create and verify required folders
        $requiredFolders = @(
            @{Path = "updates"; Description = "Updates"},
            @{Path = "Staging"; Description = "Staging"},
            @{Path = "Mount"; Description = "Mount"},
            @{Path = "CompletedWIMs"; Description = "CompletedWIMs"},
            @{Path = "Configs"; Description = "Configs"}
        )

        foreach ($folder in $requiredFolders) {
            $FileExist = Test-Path -Path "$script:workingDirectory\$($folder.Path)"
            if (-not $FileExist) {
                Write-WimWitchLog -Data "$($folder.Description) folder does not exist. Creating..." -Class Warning
                New-Item -ItemType Directory -Force -Path "$script:workingDirectory\$($folder.Path)" | Out-Null
                Write-WimWitchLog -Data "$($folder.Description) folder created" -Class Information
            } else {
                Write-WimWitchLog -Data "$($folder.Description) folder exists" -Class Information
            }
        }
    }
}

