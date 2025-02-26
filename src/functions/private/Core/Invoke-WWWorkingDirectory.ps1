<#
.SYNOPSIS
    

.DESCRIPTION
    

.NOTES
    Name:        Invoke-WWWorkingDirectory.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-25
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Invoke-WWWorkingDirectory
#>
function Invoke-WWWorkingDirectory {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            $subfolders = @(
            'CompletedWIMs'
            'Configs'
            'Drivers'
            'Jobs'
            'Logging'
            'Mount'
            'Staging'
            'Updates'
            'Imports'
            'Imports\WIM'
            'Imports\DotNet'
            'Autopilot'
            'Backup'
            )

            Set-Location -Path $script:workingDirectory
            Write-Output "WimWitch Reloaded working directory defined as: $script:workingDirectory"
            Write-Output 'Checking working directory for required folders...'
            foreach ($subfolder in $subfolders) {
            if ((Test-Path -Path "$subfolder") -eq $false) {
                Write-Output "Creating missing folder: $subfolder"
                New-Item -Path $subfolder -ItemType Directory -ErrorAction Stop | Out-Null
                Write-Output "Created folder: $subfolder"
            }
            else {
                Write-Output "Folder already exists: $subfolder"
            }
            }
            Write-Output 'Preflight check complete. Working directory is ready.'
            Write-Output 'Starting WimWitch Reloaded...'
        }
        catch {
            Write-Error "Failed to setup working directory: $_"
            throw
        }
    }
}