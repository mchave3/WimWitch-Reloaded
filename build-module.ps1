# Script de build du module
$sourceDir = Join-Path $PSScriptRoot "src\functions"
$outputDir = Join-Path $PSScriptRoot "scripts"
$moduleName = "WimWitchModule"

# Créer le dossier de sortie s'il n'existe pas
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Créer le fichier du module
$moduleFile = Join-Path $outputDir "$moduleName.psm1"
$manifestFile = Join-Path $outputDir "$moduleName.psd1"

# Initialiser le contenu du module
$moduleContent = @"
# Module WimWitch
# Généré automatiquement

"@

# Ajouter les fonctions publiques
Get-ChildItem -Path (Join-Path $sourceDir "public") -Recurse -File -Filter "*.ps1" | ForEach-Object {
    $moduleContent += "`n# Source: $($_.FullName)`n"
    $moduleContent += (Get-Content $_.FullName -Raw)
    $moduleContent += "`n"
}

# Ajouter les fonctions privées
Get-ChildItem -Path (Join-Path $sourceDir "private") -Recurse -File -Filter "*.ps1" | ForEach-Object {
    $moduleContent += "`n# Source: $($_.FullName)`n"
    $moduleContent += (Get-Content $_.FullName -Raw)
    $moduleContent += "`n"
}

# Écrire le contenu dans le fichier du module
$moduleContent | Out-File -FilePath $moduleFile -Encoding UTF8

# Créer le manifeste du module
$manifestParams = @{
    Path = $manifestFile
    RootModule = "$moduleName.psm1"
    ModuleVersion = "1.0.0"
    Author = "WimWitch Team"
    Description = "Module WimWitch compilé"
    PowerShellVersion = "5.1"
}

New-ModuleManifest @manifestParams

Write-Host "Module créé avec succès dans : $outputDir"
