$functionPath = Join-Path $PSScriptRoot "src\functions"
$privatePath = Join-Path $functionPath "private"
$publicPath = Join-Path $functionPath "public"

# Get all .ps1 files from both directories
$privateFiles = Get-ChildItem -Path $privatePath -Filter "*.ps1" -File -Recurse
$publicFiles = Get-ChildItem -Path $publicPath -Filter "*.ps1" -File -Recurse

# Combine all files and get their names without extension
$allFunctions = @($privateFiles) + @($publicFiles) | ForEach-Object { 
    [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
}

# Save to functions.txt
$outputPath = Join-Path $PSScriptRoot "functions.txt"
$allFunctions | Sort-Object | Set-Content -Path $outputPath

Write-Host "Functions list has been saved to: $outputPath"
