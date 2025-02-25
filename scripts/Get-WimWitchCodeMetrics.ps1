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

# Initialize timing for performance measurement
$startTime = Get-Date

# Banner display function
function Show-BuildBanner {
    $banner = @"
===========================================================
                WimWitch-Reloaded Code Metrics
                $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
===========================================================
"@
    Write-Host $banner -ForegroundColor Cyan
}

# Custom logging function with color-coded output
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

# Set up directory paths for analysis
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $projectRoot "src"

# Initialize metric tracking variables
$totalLines = 0
$totalNonEmptyLines = 0
$totalFiles = 0
$fileTypes = @('*.ps1', '*.psm1', '*.psd1', '*.xaml')

# Initialize statistics tracking for each file type
$fileTypeStats = @{}
foreach ($type in ('ps1', 'psm1', 'psd1', 'xaml')) {
    $fileTypeStats[$type] = @{
        Count = 0
        Lines = 0
        NonEmptyLines = 0
    }
}

# Display initial banner
Show-BuildBanner

# Collect all target files for analysis
try {
    $files = Get-ChildItem -Path $sourceDir -Include $fileTypes -Recurse -ErrorAction Stop
    $filesCount = $files.Count
    Write-WWLog "Starting line count for $filesCount files..." -Type Stage
}
catch {
    Write-WWLog "Error getting files: $($_.Exception.Message)" -Type Error
    exit 1
}

# Process each file and collect metrics
$currentFile = 0
foreach ($file in $files) {
    $currentFile++

    # Extract file extension for categorization
    if ($file.Extension -match '\.(.+)') {
        $extension = $matches[1].ToLower()
    } else {
        $extension = ""
    }

    # Update progress indicator
    $percentComplete = [math]::Round(($currentFile / $filesCount) * 100)
    Write-Progress -Activity "Counting lines in files" `
                  -Status "Processing $currentFile of $filesCount files" `
                  -PercentComplete $percentComplete

    try {
        # Analyze file content
        $content = Get-Content $file.FullName -ErrorAction Stop
        $totalLineCount = $content.Count
        $nonEmptyLineCount = ($content | Where-Object { $_ -match '\S' }).Count

        # Update global statistics
        $totalLines += $totalLineCount
        $totalNonEmptyLines += $nonEmptyLineCount
        $totalFiles++

        # Update file type specific statistics
        if ($extension -and $fileTypeStats.ContainsKey($extension)) {
            $fileTypeStats[$extension].Count++
            $fileTypeStats[$extension].Lines += $totalLineCount
            $fileTypeStats[$extension].NonEmptyLines += $nonEmptyLineCount
        } else {
            # Handle unexpected extension by adding it to our tracking
            if ($extension -and -not $fileTypeStats.ContainsKey($extension)) {
                $fileTypeStats[$extension] = @{
                    Count = 1
                    Lines = $totalLineCount
                    NonEmptyLines = $nonEmptyLineCount
                }
            }
        }
    }
    catch {
        Write-WWLog "Error processing file $($file.FullName): $($_.Exception.Message)" -Type Error
    }
}

# Finalize progress display
Write-Progress -Activity "Counting lines in files" -Completed

# Calculate final metrics
$endTime = Get-Date
$executionTime = $endTime - $startTime
$formattedTime = "{0:mm\:ss\.fff}" -f $executionTime

# Begin results display
Write-WWLog "Code Metrics Summary" -Type Stage

# Display formatted results header
$summaryBorder = "=" * 60
Write-Host $summaryBorder -ForegroundColor Cyan
Write-Host "  WimWitch-Reloaded Code Analysis Results" -ForegroundColor White
Write-Host $summaryBorder -ForegroundColor Cyan

# Display overall statistics
Write-Host "`n  [OVERALL] Statistics:" -ForegroundColor Cyan
Write-Host "    * Files processed:      $totalFiles"
Write-Host "    * Total lines:          $totalLines"
Write-Host "    * Non-empty lines:      $totalNonEmptyLines"
Write-Host "    * Empty lines:          $($totalLines - $totalNonEmptyLines)"
Write-Host "    * Code density:         $([math]::Round(($totalNonEmptyLines / $totalLines) * 100, 1))%"

# Display file type breakdown
Write-Host "`n  [DETAILS] Breakdown by File Type:" -ForegroundColor Cyan
$fileTypeFormat = "    {0,-6} {1,-6} {2,-12} {3,-15} {4,-10}"
Write-Host ($fileTypeFormat -f "Type", "Files", "Lines", "Non-empty", "Density")
Write-Host "    $("-" * 50)"

# Display statistics for each file type
foreach ($extension in $fileTypeStats.Keys | Sort-Object) {
    $stats = $fileTypeStats[$extension]
    if ($stats.Count -gt 0) {
        $density = [math]::Round(($stats.NonEmptyLines / [Math]::Max(1, $stats.Lines)) * 100, 1)
        $extDisplay = ".$extension"
        Write-Host ($fileTypeFormat -f $extDisplay, $stats.Count, $stats.Lines, $stats.NonEmptyLines, "$density%")
    }
}

# Display performance metrics
Write-Host "`n  [PERF] Performance Metrics:" -ForegroundColor Cyan
Write-Host "    * Execution time:      $formattedTime"
Write-Host "    * Processing rate:     $([math]::Round($totalFiles / $executionTime.TotalSeconds, 1)) files/second"

# Display final border and completion message
Write-Host "`n$summaryBorder" -ForegroundColor Cyan
Write-WWLog "Script completed successfully!" -Type Success
Write-WWLog "Execution time: $formattedTime" -Type Success