<#
.SYNOPSIS
    Restore a WimWitch-Reloaded backup.

.DESCRIPTION
    This function restores a WimWitch-Reloaded backup created by the Backup-WimWitch function.
    It extracts the backup file and restores the configuration and settings as needed.

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

.PARAMETER Full
    Restore everything in the backup.
#>
function Restore-WimWitchBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$BackupPath,
        
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
            
            # Always restore configuration files
            $configSrcDir = Join-Path -Path $tempRestoreDir -ChildPath "Config"
            if (Test-Path -Path $configSrcDir) {
                $configDestDir = Join-Path -Path $script:workingDirectory -ChildPath "Config"
                
                if (Test-Path -Path $configDestDir) {
                    Remove-Item -Path $configDestDir -Recurse -Force -ErrorAction SilentlyContinue
                }
                
                # Copy restored config
                Copy-Item -Path $configSrcDir -Destination $script:workingDirectory -Recurse -Force
                Write-WimWitchLog -Data "Configuration restored successfully" -Class Information
            }
            
            # Always restore settings file
            $settingsFile = Join-Path -Path $tempRestoreDir -ChildPath "settings.xml"
            if (Test-Path -Path $settingsFile) {
                $settingsDestFile = Join-Path -Path $script:workingDirectory -ChildPath "settings.xml"
                Copy-Item -Path $settingsFile -Destination $settingsDestFile -Force
                Write-WimWitchLog -Data "Settings restored successfully" -Class Information
            }
            
            # Restore templates if full restore requested
            if ($Full) {
                $templateSrcDir = Join-Path -Path $tempRestoreDir -ChildPath "Templates"
                if (Test-Path -Path $templateSrcDir) {
                    $templateDestDir = Join-Path -Path $script:workingDirectory -ChildPath "Templates"
                    
                    if (Test-Path -Path $templateDestDir) {
                        Remove-Item -Path $templateDestDir -Recurse -Force -ErrorAction SilentlyContinue
                    }
                    
                    # Copy restored templates
                    Copy-Item -Path $templateSrcDir -Destination $script:workingDirectory -Recurse -Force
                    Write-WimWitchLog -Data "Templates restored successfully" -Class Information
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
