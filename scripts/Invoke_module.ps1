#Requires -RunAsAdministrator

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

#Region Variables
$moduleName = "WimWitch-Reloaded"
$requiredModules = @('OSDSUS', 'OSDUpdate')
$modulesToUninstall = $requiredModules + @($moduleName)
$moduleOutput = Join-Path (Split-Path -Parent $PSScriptRoot) "outputs\$moduleName"
#EndRegion Variables

#Region Functions
function Show-BuildBanner {
    param()
    $banner = @"
===========================================================
                WimWitch-Reloaded Module Setup
                $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
===========================================================
"@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-WWLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [Parameter()]
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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ModuleName
    )

    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            Write-WWLog "Installing module $ModuleName..." -Type Warning
            Install-Module -Name $ModuleName -Force -Scope CurrentUser -ErrorAction Stop

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
#EndRegion Functions

#Region Main
Clear-Host

# Initialize setup
Show-BuildBanner
Write-WWLog "Starting module setup process" -Type Stage

#Region Environment Validation
Write-WWLog "Validating environment" -Type Stage

if (!(Test-Path $moduleOutput)) {
    Write-WWLog "Module not found at: $moduleOutput" -Type Error
    Write-WWLog "Please build the module first using Build_module.ps1" -Type Error
    exit 1
}
#EndRegion Environment Validation

#Region Module Cleanup
Write-WWLog "Cleaning up existing modules" -Type Stage

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
#EndRegion Module Cleanup

#Region Dependencies Installation
Write-WWLog "Installing required modules" -Type Stage

foreach ($module in $requiredModules) {
    Write-WWLog "Processing module: $module" -Type Info
    if (!(Install-RequiredModule -ModuleName $module)) {
        Write-WWLog "Failed to process required module: $module" -Type Error
        exit 1
    }
}
#EndRegion Dependencies Installation

#Region Module Import
Write-WWLog "Importing WimWitch-Reloaded module" -Type Stage

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
#EndRegion Module Import

#Region Launch Application
# Press enter 
Start-WimWitch
#EndRegion Launch Application

#EndRegion Main
