<#
.SYNOPSIS
    Creates and manages the working directory structure for WimWitch operations.

.DESCRIPTION
    This function sets up and maintains the necessary directory structure for WimWitch processing.
    It creates required folders if they don't exist and ensures proper permissions are set.
    The working directory is essential for temporary file storage, mounting points, and
    processing operations during Windows image customization.

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

            # Check that $script:workingDirectory is defined
            if (-not $script:workingDirectory) {
                throw "Working directory is not defined"
            }

            # Check that the directory exists
            if (-not (Test-Path -Path $script:workingDirectory -PathType Container)) {
                New-Item -Path $script:workingDirectory -ItemType Directory -ErrorAction Stop | Out-Null
                Write-Output "Working directory created: $script:workingDirectory"
            }

            Set-Location -Path $script:workingDirectory
            Write-Output "WimWitch Reloaded working directory defined as: $script:workingDirectory"
            Write-Output 'Checking working directory for required folders...'

            foreach ($subfolder in $subfolders) {
                $folderPath = Join-Path -Path $script:workingDirectory -ChildPath $subfolder
                if (-not (Test-Path -Path $folderPath)) {
                    Write-Output "Creating missing folder: $subfolder"
                    New-Item -Path $folderPath -ItemType Directory -ErrorAction Stop | Out-Null
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
            Write-Host "`nAn error has occurred. Press any key to exit..." -ForegroundColor Red
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
    }
}