<#
.SYNOPSIS
    Install required modules, uninstall existing modules, and import the WimWitch-Reloaded module.

.DESCRIPTION
    This script installs required modules, uninstalls existing modules, and imports the WimWitch-Reloaded module.

.NOTES
    Name:        Invoke_module.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-10
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Invoke_module.ps1
#>

Clear-Host

function Show-BuildBanner {
    $banner = @"
===========================================================
                WimWitch-Reloaded Module Setup
                $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
===========================================================
"@
    Write-Host $banner -ForegroundColor Cyan
}

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

$moduleName = "WimWitch-Reloaded"
$requiredModules = @('OSDSUS', 'OSDUpdate')
$modulesToUninstall = $requiredModules + @($moduleName)

# Define module path
$moduleOutput = Join-Path (Split-Path -Parent $PSScriptRoot) "outputs\$moduleName"

# Initialize setup
Show-BuildBanner
Write-WWLog "Starting module setup process" -Type Stage

# Phase 1: Environment Validation
Write-WWLog "Validating environment" -Type Stage

# Verify module exists
if (!(Test-Path $moduleOutput)) {
    Write-WWLog "Module not found at: $moduleOutput" -Type Error
    Write-WWLog "Please build the module first using Build_module.ps1" -Type Error
    exit 1
}

function Install-RequiredModule {
    param (
        [string]$ModuleName
    )

    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            Write-WWLog "Installing module $ModuleName..." -Type Warning
            Install-Module -Name $ModuleName -Force -Scope CurrentUser

            if (!(Get-Module -ListAvailable -Name $ModuleName)) {
                Write-WWLog "Module $ModuleName installation failed" -Type Error
                return $false
            }
        }
        catch {
            Write-WWLog "Error installing module $ModuleName : $_" -Type Error
            return $false
        }
    }

    try {
        Import-Module $ModuleName -Force -ErrorAction Stop
        return $true
    }
    catch {
        Write-WWLog "Error loading module $ModuleName : $_" -Type Error
        return $false
    }
}

# Phase 2: Module Cleanup
Write-WWLog "Cleaning up existing modules" -Type Stage

# Uninstall existing modules
foreach ($module in $modulesToUninstall) {
    if (Get-Module -Name $module) {
        Write-WWLog "Removing loaded module: $module" -Type Info
        Remove-Module -Name $module -Force -ErrorAction SilentlyContinue
    }
    if (Get-Module -ListAvailable -Name $module) {
        try {
            Write-WWLog "Uninstalling module: $module" -Type Info
            Uninstall-Module -Name $module -Force -AllVersions -ErrorAction SilentlyContinue
            Write-WWLog "Successfully uninstalled: $module" -Type Success
        }
        catch {
            Write-WWLog "Warning: Unable to completely uninstall $module" -Type Warning
        }
    }
}

# Phase 3: Dependencies Installation
Write-WWLog "Installing required modules" -Type Stage

# Install required modules
foreach ($module in $requiredModules) {
    Write-WWLog "Processing module: $module" -Type Info
    if (!(Install-RequiredModule -ModuleName $module)) {
        Write-WWLog "Failed to process required module: $module" -Type Error
        exit 1
    }
}

# Phase 4: Module Import
Write-WWLog "Importing WimWitch-Reloaded module" -Type Stage

# Import and verify the new module
try {
    Import-Module $moduleOutput -Force -ErrorAction Stop
    if (Get-Module -Name $moduleName) {
        Write-WWLog "Module successfully loaded" -Type Success
        Write-WWLog "Loaded modules:" -Type Info
        Get-Module | Where-Object { $_.Name -match 'OSDSUS|OSDUpdate|WimWitch-Reloaded' } |
            Format-Table -AutoSize Name, Version, ModuleType, Path
    } else {
        Write-WWLog "Module failed to load" -Type Error
        exit 1
    }
}
catch {
    Write-WWLog "Error loading module: $_" -Type Error
    exit 1
}

# Phase 5: Launch Application
Write-WWLog "Launching WimWitch-Reloaded" -Type Stage
Start-WimWitch
