<#
.SYNOPSIS
    Calculate code metrics for WimWitch-Reloaded project

.DESCRIPTION
    This script analyzes the WimWitch-Reloaded project source code and provides metrics
    such as total number of files and lines of code. It processes PowerShell scripts,
    modules, manifest files and XAML files in the project directory.

.NOTES
    Name:        Get-WimWitchCodeMetrics.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-10
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Get-WimWitchCodeMetrics
#>

Clear-Host

function Show-BuildBanner {
    $banner = @"
===========================================================
                WimWitch-Reloaded Code Metrics
                $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
===========================================================
"@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-WWLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success', 'Stage')]
        [string]$Type = 'Info'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $prefix = switch ($Type) {
        'Info'    { "[INFO]   " }
        'Warning' { "[WARN]   " }
        'Error'   { "[ERROR]  " }
        'Success' { "[SUCCESS]" }
        'Stage'   { "[STAGE]  " }
    }

    $color = switch ($Type) {
        'Info'    { 'White' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Success' { 'Green' }
        'Stage'   { 'Cyan' }
    }

    Write-Host "[$timestamp] $prefix $Message" -ForegroundColor $color
}

# Directory structure
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $projectRoot "src"

# Initialize counters
$totalLines = 0
$totalFiles = 0
$fileTypes = @('*.ps1', '*.psm1', '*.psd1', '*.xaml')

# Get all files
$files = Get-ChildItem -Path $sourceDir -Include $fileTypes -Recurse
$filesCount = $files.Count

Write-WWLog "Starting line count for $filesCount files..." -Type Stage

# Process each file
$currentFile = 0
foreach ($file in $files) {
    $currentFile++

    # Calculate progress percentage
    $percentComplete = [math]::Round(($currentFile / $filesCount) * 100)

    # Update progress bar
    Write-Progress -Activity "Counting lines in files" `
                  -Status "Processing $($file.Name) ($currentFile of $filesCount)" `
                  -PercentComplete $percentComplete

    # Count lines in current file
    $lines = (Get-Content $file.FullName | Measure-Object -Line).Lines
    $totalLines += $lines
    $totalFiles++

    # Log detailed information
    Write-WWLog "$($file.Name): $lines lines" -Type Info
}

# Complete the progress bar
Write-Progress -Activity "Counting lines in files" -Completed

# Display summary
Write-WWLog "Line count summary:" -Type Stage
Write-WWLog "Total files processed: $totalFiles" -Type Success
Write-WWLog "Total lines of code: $totalLines" -Type Success