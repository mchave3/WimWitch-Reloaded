$rootPath = Split-Path $PSScriptRoot -Parent
$functionPath = Join-Path $rootPath "src\functions"

# Get all .ps1 files
$files = Get-ChildItem -Path $functionPath -Filter "*.ps1" -Recurse
$totalFiles = $files.Count
$counter = 0

Write-Host "Starting conversion of $totalFiles .ps1 files to UTF-8 BOM..." -ForegroundColor Cyan

foreach ($file in $files) {
    $counter++
    $percentage = ($counter / $totalFiles) * 100

    # Update progress bar
    Write-Progress -Activity "Converting files to UTF-8 BOM" `
                   -Status "Processing: $($file.Name) ($counter / $totalFiles)" `
                   -PercentComplete $percentage

    # Read file content
    $content = Get-Content $file.FullName -Raw

    # Rewrite file with UTF-8 BOM encoding
    Set-Content -Path $file.FullName -Value $content -Encoding utf8BOM

    # Log progress
    Write-Host "[$counter/$totalFiles] Converted: $($file.FullName)" -ForegroundColor Green
}

# End of conversion
Write-Progress -Activity "Conversion completed" -Completed
Write-Host "All files have been successfully converted to UTF-8 BOM!" -ForegroundColor Cyan