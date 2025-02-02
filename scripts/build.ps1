# Build script for WimWitch-Reloaded
[CmdletBinding()]
param (
    [switch]$Force
)

Clear-Host

# Configuration
$moduleName = "WimWitch-Reloaded"
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $projectRoot "src\functions"
$outputDir = Join-Path $projectRoot "outputs"
$binariesDir = Join-Path $outputDir "binaries"
$requiredModules = @('OSDSUS', 'OSDUpdate')
$modulesToUninstall = $requiredModules + @($moduleName)

function Show-BuildBanner {
    $banner = @"
===========================================================
                WimWitch-Reloaded Build Script              
                $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')               
===========================================================
"@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-BuildLog {
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

function Install-RequiredModule {
    param (
        [string]$ModuleName
    )
    
    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            Write-BuildLog "Installing module $ModuleName..." -Type Warning
            Install-Module -Name $ModuleName -Force -Scope CurrentUser
            
            # Verify installation
            if (!(Get-Module -ListAvailable -Name $ModuleName)) {
                Write-BuildLog "Module $ModuleName installation verification failed" -Type Error
                return $false
            }
            Write-BuildLog "Module $ModuleName successfully installed" -Type Info
        }
        catch {
            Write-BuildLog "Error installing module $ModuleName : $_" -Type Error
            return $false
        }
    }

    try {
        Import-Module $ModuleName -Force -ErrorAction Stop
        # Verify import
        if (!(Get-Module -Name $ModuleName)) {
            Write-BuildLog "Module $ModuleName import verification failed" -Type Error
            return $false
        }
        Write-BuildLog "Module $ModuleName successfully loaded" -Type Info
        return $true
    }
    catch {
        Write-BuildLog "Error loading module $ModuleName : $_" -Type Error
        return $false
    }
}

# Start build process
Show-BuildBanner
Write-BuildLog "Starting build process for $moduleName" -Type Stage
Write-BuildLog "PowerShell Version: $($PSVersionTable.PSVersion)" -Type Info
Write-BuildLog "Operating System: $([System.Environment]::OSVersion.VersionString)" -Type Info

# 1. Uninstalling existing modules
Write-BuildLog "STAGE 1: Cleaning up existing modules" -Type Stage
foreach ($module in $modulesToUninstall) {
    if (Get-Module -Name $module) {
        Remove-Module -Name $module -Force -ErrorAction SilentlyContinue
        Write-BuildLog "Module $module removed from current session"
    }
    if (Get-Module -ListAvailable -Name $module) {
        try {
            Uninstall-Module -Name $module -Force -AllVersions -ErrorAction SilentlyContinue
            Write-BuildLog "Module $module uninstalled"
        }
        catch {
            Write-BuildLog "Unable to completely uninstall $module : $_" -Type Warning
        }
    }
}

# 2. Environment preparation
Write-BuildLog "STAGE 2: Preparing build environment" -Type Stage

# Clean or create output folder
if (Test-Path $outputDir) {
    Write-BuildLog "Cleaning existing outputs folder..."
    Get-ChildItem -Path $outputDir -Recurse | Remove-Item -Force -Recurse
    Write-BuildLog "Outputs folder cleaned"
} else {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    Write-BuildLog "Outputs folder created"
}

# Create module folder
$moduleOutput = Join-Path $outputDir $moduleName
New-Item -ItemType Directory -Path $moduleOutput -Force | Out-Null
Write-BuildLog "Module folder created: $moduleOutput"

# Create binaries folder for testing
New-Item -ItemType Directory -Path $binariesDir -Force | Out-Null
Write-BuildLog "Binaries folder created: $binariesDir"

# 3. Module build
Write-BuildLog "STAGE 3: Building module" -Type Stage

# Generate module content
$moduleContent = @"
# Module $moduleName
# Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

"@

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

# Write content to module file
$moduleFile = Join-Path $moduleOutput "$moduleName.psm1"
$moduleContent | Out-File -FilePath $moduleFile -Encoding UTF8
Write-BuildLog "Module file created: $moduleFile"

# Create module manifest
$manifestFile = Join-Path $moduleOutput "$moduleName.psd1"
$manifestParams = @{
    Path = $manifestFile
    RootModule = "$moduleName.psm1"
    ModuleVersion = "1.0.0"
    Author = "WimWitch Team"
    Description = "WimWitch-Reloaded Module"
    PowerShellVersion = "5.1"
    RequiredModules = $requiredModules
}

New-ModuleManifest @manifestParams
Write-BuildLog "Module manifest created: $manifestFile"

# 4. Installing required modules
Write-BuildLog "STAGE 4: Processing required modules" -Type Stage
foreach ($module in $requiredModules) {
    if (!(Install-RequiredModule -ModuleName $module)) {
        Write-BuildLog "Failed to process required module: $module" -Type Error
        exit 1
    }
}

# 5. Import and verify the newly built module
Write-BuildLog "STAGE 5: Verifying module" -Type Stage
try {
    Import-Module $moduleOutput -Force -ErrorAction Stop
    if (Get-Module -Name $moduleName) {
        Write-BuildLog "Module successfully imported and verified" -Type Success
    } else {
        Write-BuildLog "Module import verification failed" -Type Error
        exit 1
    }
}
catch {
    Write-BuildLog "Error during module import: $_" -Type Error
    exit 1
}

# Build Summary
$summary = @"
══════════════════════ Build Summary ══════════════════════
Module Name    : $moduleName
Build Path     : $moduleOutput
Build Time     : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Build Status   : Success
══════════════════════════════════════════════════════════
"@

Write-Host "`n$summary" -ForegroundColor Green
Write-BuildLog "Currently loaded modules:" -Type Info
Get-Module | Where-Object { $_.Name -match 'OSDSUS|OSDUpdate|WimWitch-Reloaded' } | 
    Format-Table -AutoSize Name, Version, ModuleType, Path

Start-WimWitch