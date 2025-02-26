<#
.SYNOPSIS
    Restore a WimWitch-Reloaded backup.

.DESCRIPTION
    This function restores a WimWitch-Reloaded backup created by the Backup-WimWitch function.
    It extracts the backup file and restores the configuration, settings, and templates as needed.

.NOTES
    Name:        Restore-WimWitchBackup.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.PARAMETER BackupPath
    The path to the backup ZIP file to restore.

.PARAMETER RestoreConfig
    Restore configuration files.

.PARAMETER RestoreSettings
    Restore settings file.

.PARAMETER RestoreTemplates
    Restore templates.

.PARAMETER Full
    Restore everything in the backup.

.EXAMPLE
    Restore-WimWitchBackup -BackupPath "C:\Scripts\WimWitch-Reloaded\backup\WimWitch-Backup-2025-01-30_120000.zip" -Full
#>
function Restore-WimWitchBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$BackupPath,
        
        [Parameter()]
        [switch]$RestoreConfig,
        
        [Parameter()]
        [switch]$RestoreSettings,
        
        [Parameter()]
        [switch]$RestoreTemplates,
        
        [Parameter()]
        [switch]$Full
    )

    process {
        Write-WimWitchLog -Data "Restoring WimWitch-Reloaded from backup: $BackupPath" -Class Information
        
        if (-not (Test-Path -Path $BackupPath)) {
            Write-WimWitchLog -Data "Backup file not found: $BackupPath" -Class Error
            return $false
        }
        
        try {
            # Create a temporary directory for extraction
            $tempRestoreDir = Join-Path -Path $env:TEMP -ChildPath "WimWitchRestore_$(Get-Date -Format 'yyyyMMddHHmmss')"
            New-Item -Path $tempRestoreDir -ItemType Directory -Force | Out-Null
            
            # Extract the backup
            Expand-Archive -Path $BackupPath -DestinationPath $tempRestoreDir -Force
            
            # Restore configuration if requested or doing a full restore
            if ($RestoreConfig -or $Full) {
                $configSrcDir = Join-Path -Path $tempRestoreDir -ChildPath "Config"
                if (Test-Path -Path $configSrcDir) {
                    $configDestDir = Join-Path -Path $script:workingDirectory -ChildPath "Config"
                    
                    # Backup existing config before overwriting
                    if (Test-Path -Path $configDestDir) {
                        $configBackupDir = Join-Path -Path $script:workingDirectory -ChildPath "backup\Config_$(Get-Date -Format 'yyyyMMddHHmmss')"
                        Move-Item -Path $configDestDir -Destination $configBackupDir -Force
                        Write-WimWitchLog -Data "Existing configuration backed up to: $configBackupDir" -Class Information
                    }
                    
                    # Copy restored config
                    Copy-Item -Path $configSrcDir -Destination $script:workingDirectory -Recurse -Force
                    Write-WimWitchLog -Data "Configuration restored successfully" -Class Information
                } else {
                    Write-WimWitchLog -Data "No configuration found in backup" -Class Warning
                }
            }
            
            # Restore settings if requested or doing a full restore
            if ($RestoreSettings -or $Full) {
                $settingsFile = Join-Path -Path $tempRestoreDir -ChildPath "settings.xml"
                if (Test-Path -Path $settingsFile) {
                    $settingsDestFile = Join-Path -Path $script:workingDirectory -ChildPath "settings.xml"
                    
                    # Backup existing settings before overwriting
                    if (Test-Path -Path $settingsDestFile) {
                        $settingsBackupFile = Join-Path -Path $script:workingDirectory -ChildPath "backup\settings_$(Get-Date -Format 'yyyyMMddHHmmss').xml"
                        Copy-Item -Path $settingsDestFile -Destination $settingsBackupFile -Force
                        Write-WimWitchLog -Data "Existing settings backed up to: $settingsBackupFile" -Class Information
                    }
                    
                    # Copy restored settings
                    Copy-Item -Path $settingsFile -Destination $settingsDestFile -Force
                    Write-WimWitchLog -Data "Settings restored successfully" -Class Information
                } else {
                    Write-WimWitchLog -Data "No settings file found in backup" -Class Warning
                }
            }
            
            # Restore templates if requested or doing a full restore
            if ($RestoreTemplates -or $Full) {
                $templateSrcDir = Join-Path -Path $tempRestoreDir -ChildPath "Templates"
                if (Test-Path -Path $templateSrcDir) {
                    $templateDestDir = Join-Path -Path $script:workingDirectory -ChildPath "Templates"
                    
                    # Backup existing templates before overwriting
                    if (Test-Path -Path $templateDestDir) {
                        $templateBackupDir = Join-Path -Path $script:workingDirectory -ChildPath "backup\Templates_$(Get-Date -Format 'yyyyMMddHHmmss')"
                        Move-Item -Path $templateDestDir -Destination $templateBackupDir -Force
                        Write-WimWitchLog -Data "Existing templates backed up to: $templateBackupDir" -Class Information
                    }
                    
                    # Copy restored templates
                    Copy-Item -Path $templateSrcDir -Destination $script:workingDirectory -Recurse -Force
                    Write-WimWitchLog -Data "Templates restored successfully" -Class Information
                } else {
                    Write-WimWitchLog -Data "No templates found in backup" -Class Warning
                }
            }
            
            # Clean up temporary directory
            Remove-Item -Path $tempRestoreDir -Recurse -Force -ErrorAction SilentlyContinue
            
            Write-WimWitchLog -Data "Backup restored successfully" -Class Information
            return $true
        } catch {
            Write-WimWitchLog -Data "Error restoring backup: $_" -Class Error
            Write-WimWitchLog -Data $_.Exception.Message -Class Error
            
            # Clean up temporary directory if it exists
            if (Test-Path -Path $tempRestoreDir) {
                Remove-Item -Path $tempRestoreDir -Recurse -Force -ErrorAction SilentlyContinue
            }
            
            return $false
        }
    }
}
