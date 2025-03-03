# Determine root path with fallback mechanism
$rootPath = if ($PSScriptRoot) {
    Split-Path $PSScriptRoot -Parent
} else {
    # Fallback to current directory's parent when running directly in console
    Split-Path (Get-Location) -Parent
}

$functionPath = Join-Path $rootPath "src\functions"

# Verify path exists
if (-not (Test-Path $functionPath)) {
    Write-Error "Functions path not found: $functionPath"
    exit 1
}

# Get all .ps1 files
$files = Get-ChildItem -Path $functionPath -Filter "*.ps1" -Recurse
$totalFiles = $files.Count

if ($totalFiles -eq 0) {
    Write-Warning "No .ps1 files found in $functionPath"
    exit 0
}

$counter = 0

Write-Host "Starting removal of trailing newlines from $totalFiles .ps1 files..." -ForegroundColor Cyan

foreach ($file in $files) {
    $counter++
    $percentage = ($counter / $totalFiles) * 100

    # Update progress bar
    Write-Progress -Activity "Removing trailing newlines" `
                   -Status "Processing: $($file.Name) ($counter / $totalFiles)" `
                   -PercentComplete $percentage

    # Read file content
    $content = Get-Content $file.FullName -Raw

    # Remove multiple trailing newlines (keep just one)
    $trimmedContent = $content -replace '(\r?\n)+$', '$1'

    # Check if any changes were made
    if ($content -ne $trimmedContent) {
        # Write the trimmed content back to the file
        Set-Content -Path $file.FullName -Value $trimmedContent -NoNewline -Encoding utf8BOM
        Add-Content -Path $file.FullName -Value "" -Encoding utf8BOM # Add exactly one newline at the end
        Write-Host "[$counter/$totalFiles] Trimmed: $($file.FullName)" -ForegroundColor Green
    } else {
        Write-Host "[$counter/$totalFiles] Already formatted: $($file.FullName)" -ForegroundColor Gray
    }
}

# End of processing
Write-Progress -Activity "Trailing newlines removal completed" -Completed
Write-Host "All files have been successfully processed! Trailing newlines removed." -ForegroundColor Cyan