# Invoke the module WimWitch-Reloaded
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
    
    Write-Host "[$timestamp] $prefix $Message" -ForegroundColor $color
}

$moduleName = "WimWitch-Reloaded"
$requiredModules = @('OSDSUS', 'OSDUpdate')
$modulesToUninstall = $requiredModules + @($moduleName)

# Define module path
$moduleOutput = Join-Path (Split-Path -Parent $PSScriptRoot) "outputs\$moduleName"

# Verify module exists
if (!(Test-Path $moduleOutput)) {
    Write-Log "Module not found at: $moduleOutput" -Type Error
    Write-Log "Please build the module first using Build_module.ps1" -Type Error
    exit 1
}

function Install-RequiredModule {
    param (
        [string]$ModuleName
    )
    
    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            Write-Log "Installing module $ModuleName..." -Type Warning
            Install-Module -Name $ModuleName -Force -Scope CurrentUser
            
            if (!(Get-Module -ListAvailable -Name $ModuleName)) {
                Write-Log "Module $ModuleName installation failed" -Type Error
                return $false
            }
        }
        catch {
            Write-Log "Error installing module $ModuleName : $_" -Type Error
            return $false
        }
    }

    try {
        Import-Module $ModuleName -Force -ErrorAction Stop
        return $true
    }
    catch {
        Write-Log "Error loading module $ModuleName : $_" -Type Error
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
            Write-Log "Warning: Unable to completely uninstall $module" -Type Warning
        }
    }
}

# Install required modules
foreach ($module in $requiredModules) {
    if (!(Install-RequiredModule -ModuleName $module)) {
        Write-Log "Failed to process required module: $module" -Type Error
        exit 1
    }
}

# Import and verify the new module
try {
    Import-Module $moduleOutput -Force -ErrorAction Stop
    if (Get-Module -Name $moduleName) {
        Write-Log "Module successfully loaded" -Type Success
        Write-Log "`nLoaded modules:" -Type Info
        Get-Module | Where-Object { $_.Name -match 'OSDSUS|OSDUpdate|WimWitch-Reloaded' } | 
            Format-Table -AutoSize Name, Version, ModuleType, Path
    } else {
        Write-Log "Module failed to load" -Type Error
        exit 1
    }
}
catch {
    Write-Log "Error loading module: $_" -Type Error
    exit 1
}

Write-Log "Starting WimWitch" -Type Stage
Start-WimWitch
