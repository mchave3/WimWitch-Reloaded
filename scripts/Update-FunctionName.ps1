<#
.SYNOPSIS
    Updates function names in PowerShell scripts based on a CSV mapping file.

.DESCRIPTION
    This script updates function names across PowerShell scripts in a project directory
    using a CSV file that maps old function names to new ones. It includes backup
    functionality and validates both the CSV format and function names.

.NOTES
    Name:        Update-FunctionName.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-11
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Update-FunctionName.ps1
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateScript({
        if (-not (Test-Path $_)) {
            throw "CSV file not found: $_"
        }
        if (-not ($_ -match '\.csv$')) {
            throw "File must have a .csv extension"
        }
        return $true
    })]
    [string]$CsvPath = ".\function-mapping.csv",

    [Parameter(Mandatory = $false)]
    [ValidateScript({
        if (-not (Test-Path $_)) {
            throw "Source path not found: $_"
        }
        return $true
    })]
    [string]$SourcePath = (Join-Path (Split-Path -Parent $PSScriptRoot) "src"),

    [Parameter(Mandatory = $false)]
    [string]$BackupPath = (Join-Path $PSScriptRoot "backup")
)

Clear-Host

#region Functions
function Write-WWLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success', 'Stage')]
        [string]$Type = 'Info'
    )

    try {
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
    catch {
        Write-Error "Failed to write log message: $_"
    }
}

#region Backup Functions
function New-FileBackup {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    try {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $fileName = Split-Path $FilePath -Leaf
        $backupDir = Join-Path $BackupPath $timestamp
        $backupFile = Join-Path $backupDir $fileName

        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($FilePath, "Creating backup at $backupFile")) {
            Copy-Item -Path $FilePath -Destination $backupFile -Force
            Write-WWLog -Message "Created backup: $backupFile" -Type 'Info'
        }
    }
    catch {
        throw "Failed to create backup: $_"
    }
}
#endregion Backup Functions

#region CSV Validation
function Test-CsvContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CsvPath
    )

    try {
        $csvContent = Import-Csv $CsvPath -Header 'OldName','NewName'

        $validationErrors = @()
        $index = 1

        foreach ($row in $csvContent) {
            if ([string]::IsNullOrWhiteSpace($row.OldName)) {
                $validationErrors += "Row $index : Missing OldName"
            }
            if ([string]::IsNullOrWhiteSpace($row.NewName)) {
                $validationErrors += "Row $index : Missing NewName"
            }
            if ($row.OldName -match '[^\w\-]' -or $row.NewName -match '[^\w\-]') {
                $validationErrors += "Row $index : Names can only contain letters, numbers, and hyphens"
            }
            $index++
        }

        if ($validationErrors.Count -gt 0) {
            throw "CSV validation errors:`n$($validationErrors -join "`n")"
        }

        return $csvContent
    }
    catch {
        throw "CSV validation failed: $_"
    }
}
#endregion CSV Validation

#region Summary Function
function Show-ExecutionSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Stats
    )

    Write-Host "`n═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "           EXECUTION SUMMARY" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════`n" -ForegroundColor Cyan

    Write-Host "Statistics:" -ForegroundColor White
    Write-Host "  - Files Processed: " -NoNewline
    Write-Host $Stats.TotalFiles -ForegroundColor Yellow
    Write-Host "  - Files Modified: " -NoNewline
    Write-Host $Stats.ModifiedFiles -ForegroundColor Green
    Write-Host "  - Backups Created: " -NoNewline
    Write-Host $Stats.BackupsCreated -ForegroundColor Cyan
    Write-Host "  - Errors Encountered: " -NoNewline
    Write-Host $Stats.Errors -ForegroundColor Red

    if ($Stats.ExecutionTime) {
        Write-Host "`nPerformance:" -ForegroundColor White
        $minutes = [math]::Floor($Stats.ExecutionTime.TotalMinutes)
        $seconds = $Stats.ExecutionTime.Seconds
        Write-Host "  - Total Duration: " -NoNewline
        Write-Host ("{0:00}:{1:00} minutes" -f $minutes, $seconds) -ForegroundColor Yellow
    }

    Write-Host "`nPaths:" -ForegroundColor White
    Write-Host "  - Source: " -NoNewline
    Write-Host $Stats.SourcePath -ForegroundColor Yellow
    Write-Host "  - Backup: " -NoNewline
    Write-Host $Stats.BackupPath -ForegroundColor Yellow

    Write-Host "`n═══════════════════════════════════════`n" -ForegroundColor Cyan
}
#endregion Summary Function

function Update-ProjectFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Mappings
    )

    # Initialize statistics
    $script:stats = @{
        TotalFiles = 0
        ModifiedFiles = 0
        BackupsCreated = 0
        Errors = 0
        StartTime = Get-Date
        SourcePath = $SourcePath
        BackupPath = $BackupPath
    }

    # Get all PowerShell files recursively
    $files = Get-ChildItem -Path $SourcePath -Recurse -File -Include "*.ps1"
    $totalFiles = $files.Count
    $currentFile = 0
    $errorCount = 0
    $modifiedCount = 0

    #region Content Parser
    function Update-FunctionNameInContent {
        [CmdletBinding(SupportsShouldProcess)]
        param (
            [Parameter(Mandatory = $true)]
            [string]$Content,
            [Parameter(Mandatory = $true)]
            [string]$OldName,
            [Parameter(Mandatory = $true)]
            [string]$NewName
        )

        # Simple global replacement with word boundaries
        $regex = "\b$OldName\b"
        if ($PSCmdlet.ShouldProcess($OldName, "Replace with $NewName")) {
            return $Content -replace $regex, $NewName
        }
        return $Content
    }
    #endregion Content Parser

    #region File Processing
    foreach ($file in $files) {
        $script:stats.TotalFiles++
        $currentFile++
        Write-Progress -Activity "Processing files" -Status "File $currentFile of $totalFiles" -PercentComplete (($currentFile / $totalFiles) * 100)

        try {
            $originalName = $file.Name
            $newName = $originalName
            $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
            $contentChanged = $false
            $nameChanged = $false

            # Create backup before any modifications
            New-FileBackup -FilePath $file.FullName
            $backupCreated = $true

            foreach ($old in $Mappings.Keys) {
                $new = $Mappings[$old]

                # Process content with custom parser
                $newContent = Update-FunctionNameInContent -Content $content -OldName $old -NewName $new
                if ($newContent -ne $content) {
                    $content = $newContent
                    $contentChanged = $true
                }

                # Process filename
                if ($newName -like "*$old*") {
                    $newName = $newName.Replace($old, $new)
                    $nameChanged = $true
                }
            }

            # Apply changes if needed
            if ($contentChanged) {
                if ($PSCmdlet.ShouldProcess($file.FullName, "Update file content")) {
                    Write-WWLog -Message "Updating content in: $($file.FullName)" -Type 'Info'
                    Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -Force
                }
            }

            if ($nameChanged) {
                $newPath = Join-Path $file.Directory.FullName $newName
                if ($PSCmdlet.ShouldProcess($originalName, "Rename to $newName")) {
                    Write-WWLog -Message "Renaming: $originalName -> $newName" -Type 'Info'
                    Move-Item -Path $file.FullName -Destination $newPath -Force
                }
            }

            if ($contentChanged -or $nameChanged) {
                $script:stats.ModifiedFiles++
            }
            if ($backupCreated) {
                $script:stats.BackupsCreated++
            }
        }
        catch {
            $script:stats.Errors++
            Write-WWLog -Message "Error processing $($file.Name): $_" -Type 'Error'
            continue
        }
    }
    Write-Progress -Activity "Processing files" -Completed
    Write-WWLog -Message "Processing complete. Modified: $modifiedCount, Errors: $errorCount" -Type 'Info'
    return $script:stats
    #endregion File Processing
}
#endregion Functions

#region Main Execution
try {
    $startTime = Get-Date
    Write-WWLog -Message "Starting function name update process" -Type 'Stage'

    # Create backup directory if it doesn't exist
    if (-not (Test-Path $BackupPath)) {
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    }

    # Validate CSV content
    $csvContent = Test-CsvContent -CsvPath $CsvPath
    $mappings = @{}
    $csvContent | ForEach-Object {
        $mappings[$_.OldName] = $_.NewName
    }

    Write-WWLog -Message "Loaded $($mappings.Count) valid name mappings" -Type 'Info'
    Write-WWLog -Message "Source path: $SourcePath" -Type 'Info'
    Write-WWLog -Message "Backup path: $BackupPath" -Type 'Info'

    # Process files and get statistics
    $stats = Update-ProjectFile -Mappings $mappings

    # Calculate execution time
    $stats.ExecutionTime = (Get-Date) - $startTime

    # Show summary
    Show-ExecutionSummary -Stats $stats

    Write-WWLog -Message "Function name update completed successfully" -Type 'Success'
}
catch {
    Write-WWLog -Message "Critical error: $_" -Type 'Error'
    Write-WWLog -Message "Stack trace: $($_.ScriptStackTrace)" -Type 'Error'
    exit 1
}
#endregion Main Execution