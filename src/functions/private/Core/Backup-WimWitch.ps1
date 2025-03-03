<#
.SYNOPSIS
    Create a backup of the WimWitch-Reloaded module settings and configuration.

.DESCRIPTION
    This function creates a backup of the current WimWitch-Reloaded module settings and configuration.
    It exports the module configuration to a backup file and stores it in the backup directory.

.NOTES
    Name:        Backup-WimWitch.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

Based on original WIM-Witch by TheNotoriousDRR:
    https://github.com/thenotoriousdrr/WIM-Witch

Based on original WIM-Witch by TheNotoriousDRR:
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.PARAMETER BackupName
    Custom name for the backup file. If not specified, a timestamp will be used.

.PARAMETER Full
    Create a full backup including settings and templates.
#>
function Backup-WimWitch {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$BackupName,
        
        [Parameter()]
        [switch]$Full
    )

    process {
        Write-WimWitchLog -data 'Creating WimWitch-Reloaded backup...' -Class Information

        # Create timestamp for backup file name
        $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
        $backupName = if ($BackupName) { $BackupName } else { "WimWitch-Backup-$timestamp" }
        
        # Ensure backup directory exists
        $backupDir = Join-Path -Path $script:workingDirectory -ChildPath "backup"
        if (-not (Test-Path -Path $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
            Write-WimWitchLog -data "Created backup directory: $backupDir" -Class Information
        }
        
        try {
            $backupPath = Join-Path -Path $backupDir -ChildPath "$backupName.zip"
            
            # Create a temporary directory for items to back up
            $tempBackupDir = Join-Path -Path $env:TEMP -ChildPath "WimWitchBackup_$timestamp"
            New-Item -Path $tempBackupDir -ItemType Directory -Force | Out-Null
            
            # Always back up the configuration
            $configDir = Join-Path -Path $script:workingDirectory -ChildPath "Config"
            if (Test-Path -Path $configDir) {
                Copy-Item -Path $configDir -Destination $tempBackupDir -Recurse -Force
            }
            
            # Always include settings in backups during module updates
            $settingsFile = Join-Path -Path $script:workingDirectory -ChildPath "settings.xml"
            if (Test-Path -Path $settingsFile) {
                Copy-Item -Path $settingsFile -Destination $tempBackupDir -Force
            }
            
            # Create module information file
            $moduleInfo = Get-Module -Name "WimWitch-Reloaded" -ListAvailable | 
                Sort-Object Version -Descending | 
                Select-Object -First 1 |
                Select-Object Name, Version, Path, ModuleBase
            
            $moduleInfoFile = Join-Path -Path $tempBackupDir -ChildPath "ModuleInfo.json"
            $moduleInfo | ConvertTo-Json | Out-File -FilePath $moduleInfoFile -Force
            
            # Back up templates if requested or doing a full backup
            if ($Full) {
                $templateDir = Join-Path -Path $script:workingDirectory -ChildPath "Templates"
                if (Test-Path -Path $templateDir) {
                    Copy-Item -Path $templateDir -Destination $tempBackupDir -Recurse -Force
                }
            }
            
            # Create the ZIP file
            if (Test-Path -Path $tempBackupDir) {
                # Use Compress-Archive to create the backup
                Compress-Archive -Path "$tempBackupDir\*" -DestinationPath $backupPath -Force
                
                # Clean up temp directory
                Remove-Item -Path $tempBackupDir -Recurse -Force -ErrorAction SilentlyContinue
                
                Write-WimWitchLog -Data "Backup successfully created at: $backupPath" -Class Information
                return $backupPath
            } else {
                Write-WimWitchLog -Data "Failed to create backup - no items found to back up" -Class Error
                return $false
            }
        } catch {
            Write-WimWitchLog -Data "Error creating backup: $_" -Class Error
            Write-WimWitchLog -Data $_.Exception.Message -Class Error
            
            # Clean up temp directory if it exists
            if (Test-Path -Path $tempBackupDir) {
                Remove-Item -Path $tempBackupDir -Recurse -Force -ErrorAction SilentlyContinue
            }
            
            return $false
        }
    }
}

