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

# Uninstall existing modules
foreach ($module in $modulesToUninstall) {
    if (Get-Module -Name $module) {
        Remove-Module -Name $module -Force -ErrorAction SilentlyContinue
    }
    if (Get-Module -ListAvailable -Name $module) {
        try {
            Uninstall-Module -Name $module -Force -AllVersions -ErrorAction SilentlyContinue
        }
        catch {
            Write-WWLog "Warning: Unable to completely uninstall $module" -Type Warning
        }
    }
}

# Install required modules
foreach ($module in $requiredModules) {
    if (!(Install-RequiredModule -ModuleName $module)) {
        Write-WWLog "Failed to process required module: $module" -Type Error
        exit 1
    }
}

# Import and verify the new module
try {
    Import-Module $moduleOutput -Force -ErrorAction Stop
    if (Get-Module -Name $moduleName) {
        Write-WWLog "Module successfully loaded" -Type Success
        Write-WWLog "`nLoaded modules:" -Type Info
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

Write-WWLog "Starting WimWitch" -Type Stage
Start-WimWitch
