Clear-Host

$modulePath = "C:\modules\WimWitch-Reloaded"
$requiredModules = @('OSDSUS', 'OSDUpdate')
$moduleToUninstall = $requiredModules + @('WimWitch-Reloaded')

# Uninstall existing modules
Write-Host "Uninstalling existing modules..." -ForegroundColor Yellow
foreach ($module in $moduleToUninstall) {
    if (Get-Module -Name $module) {
        Remove-Module -Name $module -Force -ErrorAction SilentlyContinue
        Write-Host "Removed module $module from current session" -ForegroundColor Gray
    }
    if (Get-Module -ListAvailable -Name $module) {
        try {
            Uninstall-Module -Name $module -Force -AllVersions -ErrorAction SilentlyContinue
            Write-Host "Uninstalled module $module" -ForegroundColor Gray
        }
        catch {
            Write-Warning "Could not completely uninstall $module : $_"
        }
    }
}

$modulePath = "C:\modules\WimWitch-Reloaded"
$requiredModules = @('OSDSUS', 'OSDUpdate')

function Install-RequiredModule {
    param (
        [string]$ModuleName
    )
    
    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            Write-Host "Installing module $ModuleName..." -ForegroundColor Yellow
            Install-Module -Name $ModuleName -Force -Scope CurrentUser
            
            # Verify installation
            if (!(Get-Module -ListAvailable -Name $ModuleName)) {
                Write-Error "Module $ModuleName installation verification failed"
                return $false
            }
            Write-Host "Module $ModuleName successfully installed" -ForegroundColor Green
        }
        catch {
            Write-Error "Error installing module $ModuleName : $_"
            return $false
        }
    }

    try {
        Import-Module $ModuleName -Force -ErrorAction Stop
        # Verify import
        if (!(Get-Module -Name $ModuleName)) {
            Write-Error "Module $ModuleName import verification failed"
            return $false
        }
        Write-Host "Module $ModuleName successfully loaded" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Error loading module $ModuleName : $_"
        return $false
    }
}

# Install and import required modules
foreach ($module in $requiredModules) {
    if (!(Install-RequiredModule -ModuleName $module)) {
        Write-Error "Failed to process required module: $module"
        return
    }
}

# Check and import WimWitch-Reloaded module
if (Test-Path $modulePath) {
    try {
        Import-Module $modulePath -Force -ErrorAction Stop
        if (!(Get-Module -Name (Split-Path $modulePath -Leaf))) {
            Write-Error "WimWitch-Reloaded module import verification failed"
            return
        }
        Write-Host "WimWitch-Reloaded module successfully imported" -ForegroundColor Green
    }
    catch {
        Write-Error "Error importing WimWitch-Reloaded module: $_"
    }
}
else {
    Write-Error "Module not found at specified path: $modulePath"
}

# Display loaded modules for verification
Write-Host "`nCurrently loaded modules:" -ForegroundColor Cyan
Get-Module | Where-Object { $_.Name -match 'OSDSUS|OSDUpdate|WimWitch-Reloaded' } | Format-Table -AutoSize
Start-WimWitch