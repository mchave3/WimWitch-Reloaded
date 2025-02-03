# Build script for WimWitch-Reloaded
[CmdletBinding()]
param (
    [switch]$Force
)

Clear-Host

function Write-Log {
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
    
    # Add file logging
    $logMessage = "[$timestamp] $prefix $Message"
    Add-Content -Path $logPath -Value $logMessage
    Write-Host $logMessage -ForegroundColor $color
}

# Configuration with hardcoded values
$moduleName = "WimWitch-Reloaded"
$moduleVersion = "1.0.0"
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $projectRoot "src\functions"
$outputDir = Join-Path $projectRoot "outputs"
$binariesDir = Join-Path $outputDir "binaries"

# Remove configuration loading section since we're using hardcoded values

# Validate source directory
if (!(Test-Path $sourceDir)) {
    Write-Log "Source directory not found: $sourceDir" -Type Error
    exit 1
}

# Validate required source folders
@('public', 'private') | ForEach-Object {
    $path = Join-Path $sourceDir $_
    if (!(Test-Path $path)) {
        Write-Log "Required folder not found: $path" -Type Error
        exit 1
    }
}

# Add file logging
$logPath = Join-Path $outputDir "build.log"

function Show-BuildBanner {
    $banner = @"
===========================================================
                WimWitch-Reloaded Build Script              
                $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')               
===========================================================
"@
    Write-Host $banner -ForegroundColor Cyan
}

# Start build process
Show-BuildBanner
Write-Log "Starting build process for $moduleName" -Type Stage

# 1. Environment preparation
Write-Log "Preparing build environment" -Type Stage

# Clean or create output folder
if (Test-Path $outputDir) {
    Write-Log "Cleaning existing outputs folder..."
    Get-ChildItem -Path $outputDir -Recurse | Remove-Item -Force -Recurse
} else {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Enhanced folder creation with error handling
function New-ModuleDirectory {
    param (
        [string]$Path,
        [string]$Description
    )
    
    try {
        if (!(Test-Path $Path)) {
            $null = New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop
            Write-Log "Created $Description directory: $Path" -Type Info
        }
    }
    catch {
        Write-Log "Failed to create $Description directory: $Path" -Type Error
        Write-Log "Error: $_" -Type Error
        exit 1
    }
}

# Create required directories with error handling
New-ModuleDirectory -Path $outputDir -Description "output"
New-ModuleDirectory -Path $moduleOutput -Description "module"
New-ModuleDirectory -Path $binariesDir -Description "binaries"

# 2. Module build
Write-Log "Building module" -Type Stage

# Generate module content
$moduleContent = @"
# Module $moduleName
# Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

"@

# Validate PS1 files before module build
Write-Log "Validating PS1 files" -Type Stage
$invalidFiles = @()

foreach ($folder in $requiredFolders) {
    $folderPath = Join-Path $sourceDir $folder
    $ps1Files = Get-ChildItem -Path $folderPath -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
    
    if (!$ps1Files) {
        Write-Log "No PS1 files found in $folder folder" -Type Warning
        continue
    }
    
    foreach ($file in $ps1Files) {
        try {
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $file.FullName -Raw), [ref]$null)
        }
        catch {
            $invalidFiles += $file.FullName
            Write-Log "Invalid PS1 file: $($file.FullName)" -Type Error
            Write-Log "Error: $_" -Type Error
        }
    }
}

if ($invalidFiles.Count -gt 0) {
    Write-Log "$($invalidFiles.Count) invalid PS1 files found. Build cancelled." -Type Error
    exit 1
}

# Add public and private functions
@('public', 'private') | ForEach-Object {
    $functionPath = Join-Path $sourceDir $_
    if (Test-Path $functionPath) {
        Get-ChildItem -Path $functionPath -Recurse -File -Filter "*.ps1" | ForEach-Object {
            $moduleContent += "`n# Source: $($_.FullName)`n"
            $moduleContent += (Get-Content $_.FullName -Raw)
            $moduleContent += "`n"
        }
    }
}

# Write module files
$moduleFile = Join-Path $moduleOutput "$moduleName.psm1"
$moduleContent | Out-File -FilePath $moduleFile -Encoding UTF8
Write-Log "Module file created: $moduleFile"

# Create module manifest
$manifestFile = Join-Path $moduleOutput "$moduleName.psd1"
$manifestParams = @{
    Path = $manifestFile
    RootModule = "$moduleName.psm1"
    ModuleVersion = $moduleVersion  # Use hardcoded version
    Author = "WimWitch Team"
    Description = "WimWitch-Reloaded Module"
    PowerShellVersion = "5.1"
    RequiredModules = @('OSDSUS', 'OSDUpdate')
}

New-ModuleManifest @manifestParams
Write-Log "Module manifest created: $manifestFile"

Write-Log "Build completed successfully" -Type Success

# Return the module path for Invoke_module.ps1
return $moduleOutput