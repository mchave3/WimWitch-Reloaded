<#
.SYNOPSIS
    Updates function names across the WimWitch-Reloaded project files based on a CSV mapping.

.DESCRIPTION
    This script updates function names throughout the WimWitch-Reloaded project by reading a CSV file containing old-to-new function name mappings.
    It processes all PowerShell and XAML files in the project, replacing function names in both file contents and filenames according to the mapping.

.NOTES
    Name:        Update-FunctionName.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-10
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Update-FunctionName.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$CsvPath = ".\function-mapping.csv"
)

Clear-Host

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

function Update-ProjectFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Mappings
    )

    $projectRoot = Split-Path -Parent $PSScriptRoot
    $sourceDir = Join-Path $projectRoot "src"

    # Get all PowerShell and XAML files recursively
    $files = Get-ChildItem -Path $sourceDir -Recurse -File -Include "*.ps1", "*.psm1", "*.psd1", "*.xaml"
    $totalFiles = $files.Count
    $currentFile = 0

    foreach ($file in $files) {
        $currentFile++
        Write-Progress -Activity "Processing files" -Status "Processing: $($file.Name)" -PercentComplete (($currentFile / $totalFiles) * 100)

        $originalName = $file.Name
        $newName = $originalName
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $contentChanged = $false
        $nameChanged = $false

        # Check each mapping for both filename and content replacements
        foreach ($old in $Mappings.Keys) {
            $new = $Mappings[$old]

            # Use regex replace to ensure exact match for function names
            if ($content -match "\b$old\b") {
                $content = $content -creplace "\b$old\b", $new
                $contentChanged = $true
            }

            # Update filename if it contains the old name
            if ($newName -like "*$old*") {
                $newName = $newName.Replace($old, $new)
                $nameChanged = $true
            }
        }

        # Apply changes if needed
        if ($contentChanged) {
            Write-WWLog -Message "Updating content in: $($file.FullName)" -Type 'Info'
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -Force
        }

        if ($nameChanged) {
            $newPath = Join-Path $file.Directory.FullName $newName
            Write-WWLog -Message "Renaming: $originalName -> $newName" -Type 'Info'
            Rename-Item -Path $file.FullName -NewName $newName -Force
        }
    }
    Write-Progress -Activity "Processing files" -Status "Completed" -Completed
}

# Main execution
try {
    Write-WWLog -Message "Starting function name update process" -Type 'Stage'

    # Validate and read CSV file
    if (-not (Test-Path $CsvPath)) {
        throw "CSV file not found: $CsvPath"
    }

    $mappings = @{}
    $csvContent = Import-Csv $CsvPath -Header 'OldName','NewName'

    # Validate CSV content
    $invalidRows = $csvContent | Where-Object {
        [string]::IsNullOrWhiteSpace($_.OldName) -or
        [string]::IsNullOrWhiteSpace($_.NewName)
    }

    if ($invalidRows) {
        throw "Invalid CSV content detected. All rows must have both OldName and NewName values."
    }

    $csvContent | ForEach-Object {
        $mappings[$_.OldName] = $_.NewName
    }

    if ($mappings.Count -eq 0) {
        throw "No valid mappings found in CSV file"
    }

    Write-WWLog -Message "Loaded $($mappings.Count) name mappings" -Type 'Info'

    # Process all files
    Update-ProjectFiles -Mappings $mappings

    Write-WWLog -Message "Function name update completed successfully" -Type 'Success'
}
catch {
    Write-WWLog -Message "Error: $_" -Type 'Error'
    Write-WWLog -Message "Stack trace: $($_.ScriptStackTrace)" -Type 'Error'
    exit 1
}