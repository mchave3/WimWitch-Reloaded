<#
.SYNOPSIS
    Defines the working directory path for WimWitch-Reloaded operations.

.DESCRIPTION
    This script contains the private variable definition for the working directory path
    used throughout the WimWitch-Reloaded application. The working directory is a crucial
    path where temporary files, logs, and processing operations occur during the Windows
    image manipulation process.

.NOTES
    Name:        workingDirectory.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-26
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded
#>

$script:workingDirectory = $env:ProgramData + '\WimWitch-Reloaded'