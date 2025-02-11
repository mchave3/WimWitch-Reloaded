<#
.SYNOPSIS
    Function to see if the folder WIM Witch was started in is an installation folder. If not, prompt for installation

.DESCRIPTION
    This function checks the working directory for required folders and creates them if they are missing.

.NOTES
    Name:        Test-WWWorkingDirectory.ps1
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
    Test-WWWorkingDirectory
#>
function Test-WWWorkingDirectory {
    [CmdletBinding()]
    param(

    )

    process {
        $subfolders = @(
            'CompletedWIMs'
            'Configs'
            'drivers'
            'jobs'
            'logging'
            'Mount'
            'Staging'
            'updates'
            'imports'
            'imports\WIM'
            'imports\DotNet'
            'Autopilot'
            'backup'
        )

        $count = $null
        Set-Location -Path $Script:workdir
        Write-Output "WimWitch Reloaded working directory selected: $Script:workdir"
        Write-Output 'Checking working directory for required folders...'
        foreach ($subfolder in $subfolders) {
            if ((Test-Path -Path .\$subfolder) -eq $true) { $count = $count + 1 }
        }

        if ($null -eq $count) {
            Write-Output 'Creating missing folders...'
            foreach ($subfolder in $subfolders) {
                if ((Test-Path -Path "$subfolder") -eq $false) {
                    New-Item -Path $subfolder -ItemType Directory | Out-Null
                    Write-Output "Created folder: $subfolder"
                }
            }
        }
        if ($null -ne $count) {
            Write-Output 'Creating missing folders...'
            foreach ($subfolder in $subfolders) {
                if ((Test-Path -Path "$subfolder") -eq $false) {
                    New-Item -Path $subfolder -ItemType Directory | Out-Null
                    Write-Output "Created folder: $subfolder"
                }
            }
            Write-Output 'Preflight complete. Starting WIM Witch'
        }
    }
}


