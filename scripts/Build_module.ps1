<#
.SYNOPSIS
    Build the WimWitch-Reloaded module by combining public and private functions into a single module file.

.DESCRIPTION
    This script builds the WimWitch-Reloaded module by combining public and private functions into a single module file.

.NOTES
    Name:        Build_module.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-10
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Build_module.ps1
#>

Clear-Host

#region Functions
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

function Show-BuildBanner {
    $banner = @"
===========================================================
                WimWitch-Reloaded Build Script
                $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
===========================================================
"@
    Write-Host $banner -ForegroundColor Cyan
}

function Initialize-BuildDirectory {
    param (
        [string]$Path,
        [string]$Description
    )

    try {
        if (!(Test-Path $Path)) {
            $null = New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop
            Write-WWLog "Created $Description directory: $Path" -Type Info
        }
    }
    catch {
        Write-WWLog "Failed to create $Description directory: $Path" -Type Error
        Write-WWLog "Error: $_" -Type Error
        exit 1
    }
}
#endregion Functions

#region Configuration
# Core module settings
$moduleName = "WimWitch-Reloaded"
$moduleVersion = "0.0.1"

# Directory structure
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $projectRoot "src"
$functionsDir = Join-Path $sourceDir "functions"
$variablesDir = Join-Path $sourceDir "variables"
$outputDir = Join-Path $projectRoot "outputs"
$binariesDir = Join-Path $outputDir "binaries"
$moduleOutput = Join-Path $outputDir $moduleName

# Build configuration
$requiredFolders = @('public', 'private')
$manifestFile = Join-Path $moduleOutput "$moduleName.psd1"
#endregion Configuration

#region Validation
# Verify source directory existence
if (!(Test-Path $sourceDir)) {
    Write-WWLog "Source directory not found: $sourceDir" -Type Error
    exit 1
}

# Verify required function folders
foreach ($folder in $requiredFolders) {
    $path = Join-Path $functionsDir $folder
    if (!(Test-Path $path)) {
        Write-WWLog "Required folder not found: $path" -Type Error
        exit 1
    }
}
#endregion Validation

#region Build Process
# Initialize build
Show-BuildBanner
Write-WWLog "Starting build process for $moduleName" -Type Stage

# Phase 1: Environment Preparation
Write-WWLog "Preparing build environment" -Type Stage

# Setup build directories
if (Test-Path $outputDir) {
    Write-WWLog "Cleaning existing build directory..."
    Get-ChildItem -Path $outputDir -Recurse | Remove-Item -Force -Recurse
}

Initialize-BuildDirectory -Path $outputDir -Description "output"
Initialize-BuildDirectory -Path $moduleOutput -Description "module"
Initialize-BuildDirectory -Path $binariesDir -Description "binaries"

# Phase 2: Code Validation
Write-WWLog "Validating PowerShell files" -Type Stage
$invalidFiles = @()

foreach ($folder in $requiredFolders) {
    $folderPath = Join-Path $functionsDir $folder
    $ps1Files = Get-ChildItem -Path $folderPath -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue

    if (!$ps1Files) {
        Write-WWLog "No PS1 files found in $folder folder" -Type Warning
        continue
    }

    foreach ($file in $ps1Files) {
        try {
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $file.FullName -Raw), [ref]$null)
        }
        catch {
            $invalidFiles += $file.FullName
            Write-WWLog "Invalid PS1 file: $($file.FullName)" -Type Error
            Write-WWLog "Error: $_" -Type Error
        }
    }
}

if ($invalidFiles.Count -gt 0) {
    Write-WWLog "$($invalidFiles.Count) invalid PS1 files found. Build cancelled." -Type Error
    exit 1
}

# Phase 3: Module Assembly
Write-WWLog "Assembling module components" -Type Stage

$moduleContent = @"
# Module: $moduleName
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# Auto-generated file - Do not modify
"@

# First, add all variables to ensure they're initialized before functions
Write-WWLog "Processing variable files" -Type Info
if (Test-Path $variablesDir) {
    # Process private variables first, then public
    $varFolders = @('private', 'public')

    foreach ($folder in $varFolders) {
        $varFolderPath = Join-Path $variablesDir $folder
        if (Test-Path $varFolderPath) {
            Write-WWLog "Processing $folder variable files" -Type Info
            $varFiles = Get-ChildItem -Path $varFolderPath -Recurse -File -Filter "*.ps1"

            foreach ($file in $varFiles) {
                Write-WWLog "Adding variable file: $($file.Name)" -Type Info
                $moduleContent += "`n# Source: $($file.FullName)`n"
                $moduleContent += (Get-Content $file.FullName -Raw)
                $moduleContent += "`n"
            }
        }
    }
} else {
    Write-WWLog "No variables directory found at: $variablesDir" -Type Warning
}

# Combine function files
Write-WWLog "Processing function files" -Type Info
foreach ($folder in $requiredFolders) {
    $functionPath = Join-Path $functionsDir $folder
    if (Test-Path $functionPath) {
        Get-ChildItem -Path $functionPath -Recurse -File -Filter "*.ps1" | ForEach-Object {
            $moduleContent += "`n# Source: $($_.FullName)`n"
            $moduleContent += (Get-Content $_.FullName -Raw)
            $moduleContent += "`n"
        }
    }
}

$moduleFile = Join-Path $moduleOutput "$moduleName.psm1"
$moduleContent | Out-File -FilePath $moduleFile -Encoding UTF8
Write-WWLog "Core module file generated: $moduleFile"

# Phase 4: Resource Processing
Write-WWLog "Processing additional resources" -Type Stage

# Handle resource folders
$resourceFolders = Get-ChildItem -Path $sourceDir -Directory |
    Where-Object { $_.Name -ne 'functions' } |
    ForEach-Object {
        $targetPath = Join-Path $moduleOutput $_.Name
        # Copy folder content to module output
        Copy-Item -Path $_.FullName -Destination $targetPath -Recurse -Force
        # Return relative path for FileList
        Get-ChildItem -Path $targetPath -Recurse -File |
            Select-Object -ExpandProperty FullName |
            ForEach-Object { $_.Replace($moduleOutput + '\', '') }
    }

# Process DLL dependencies
$dllFiles = Get-ChildItem -Path $sourceDir -Recurse -Filter "*.dll" |
    ForEach-Object {
        $targetPath = Join-Path $moduleOutput $_.Name
        Copy-Item -Path $_.FullName -Destination $targetPath -Force
        $_.Name
    }

# Phase 5: Manifest Generation
Write-WWLog "Generating module manifest" -Type Stage

$manifestParams = @{
    Path               = $manifestFile
    RootModule         = "$moduleName.psm1"
    ModuleVersion      = $moduleVersion
    Author             = "Mickaël CHAVE"
    Description        = "WimWitch-Reloaded Module"
    PowerShellVersion  = "5.1"
    RequiredModules    = @('OSDSUS', 'OSDUpdate')
    FileList           = @($resourceFolders)
    RequiredAssemblies = $dllFiles
}

try {
    New-ModuleManifest @manifestParams -ErrorAction Stop
    Write-WWLog "Module manifest generated successfully" -Type Success
}
catch {
    Write-WWLog "Failed to generate module manifest" -Type Error
    Write-WWLog "Error details: $_" -Type Error
    exit 1
}
#endregion Build Process

Write-WWLog "Build process completed successfully" -Type Success
return $moduleOutput