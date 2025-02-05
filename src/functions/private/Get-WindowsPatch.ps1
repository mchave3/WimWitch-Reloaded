<#
.SYNOPSIS
    Get Windows patches for a specific OS and build

.DESCRIPTION
    This function is used to get OS updates for a specific OS and build. 
    It will download SSU, AdobeSU, LCU, .Net, .Net CU, optional and dynamic updates for the specified OS and build.

.NOTES
    Name:        Get-WindowsPatch.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-27
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Get-WindowsPatch -OS 'Windows 10' -build '1909'
#>
function Get-WindowsPatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OS,
        [Parameter(Mandatory = $true)]
        [string]$build
    )

    process {
        Update-Log -Data "Downloading SSU updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop | 
                Where-Object { 
                    $_.UpdateOS -eq $OS -and 
                    $_.UpdateArch -eq 'x64' -and 
                    $_.UpdateBuild -eq $build -and 
                    $_.UpdateGroup -eq 'SSU' 
                } | Get-DownOSDUpdate -DownloadPath $global:workdir\updates\$OS\$build\SSU
        } catch {
            Update-Log -data 'Failed to download SSU update' -Class Error
            Update-Log -data $_.Exception.Message -class Error
        }
    
        Update-Log -Data "Downloading AdobeSU updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop | 
                Where-Object { 
                    $_.UpdateOS -eq $OS -and 
                    $_.UpdateArch -eq 'x64' -and 
                    $_.UpdateBuild -eq $build -and 
                    $_.UpdateGroup -eq 'AdobeSU' 
                } | Get-DownOSDUpdate -DownloadPath $global:workdir\updates\$OS\$build\AdobeSU
        } catch {
            Update-Log -data 'Failed to download AdobeSU update' -Class Error
            Update-Log -data $_.Exception.Message -class Error
        }
    
        Update-Log -Data "Downloading LCU updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop | 
                Where-Object { 
                    $_.UpdateOS -eq $OS -and 
                    $_.UpdateArch -eq 'x64' -and 
                    $_.UpdateBuild -eq $build -and 
                    $_.UpdateGroup -eq 'LCU' 
                } | Get-DownOSDUpdate -DownloadPath $global:workdir\updates\$OS\$build\LCU
        } catch {
            Update-Log -data 'Failed to download LCU update' -Class Error
            Update-Log -data $_.Exception.Message -class Error
        }
        Update-Log -Data "Downloading .Net updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop | 
                Where-Object { 
                    $_.UpdateOS -eq $OS -and 
                    $_.UpdateArch -eq 'x64' -and 
                    $_.UpdateBuild -eq $build -and 
                    $_.UpdateGroup -eq 'DotNet' 
                } | Get-DownOSDUpdate -DownloadPath $global:workdir\updates\$OS\$build\DotNet
        } catch {
            Update-Log -data 'Failed to download .Net update' -Class Error
            Update-Log -data $_.Exception.Message -class Error
        }
    
        Update-Log -Data "Downloading .Net CU updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop | 
                Where-Object { 
                    $_.UpdateOS -eq $OS -and 
                    $_.UpdateArch -eq 'x64' -and 
                    $_.UpdateBuild -eq $build -and 
                    $_.UpdateGroup -eq 'DotNetCU' 
                } | Get-DownOSDUpdate -DownloadPath $global:workdir\updates\$OS\$build\DotNetCU
        } catch {
            Update-Log -data 'Failed to download .Net CU update' -Class Error
            Update-Log -data $_.Exception.Message -class Error
        }
    
        if ($WPFUpdatesCBEnableOptional.IsChecked -eq $True) {
            try {
                Update-Log -Data "Downloading optional updates for $OS $build" -Class Information
                Get-OSDUpdate -ErrorAction Stop | 
                    Where-Object { 
                        $_.UpdateOS -eq $OS -and 
                        $_.UpdateArch -eq 'x64' -and 
                        $_.UpdateBuild -eq $build -and 
                        $_.UpdateGroup -eq 'Optional' 
                    } | Get-DownOSDUpdate -DownloadPath $global:workdir\updates\$OS\$build\Optional
            } catch {
                Update-Log -data 'Failed to download optional update' -Class Error
                Update-Log -data $_.Exception.Message -class Error
            }
        }
    
        if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True) {
            try {
                Update-Log -Data "Downloading dynamic updates for $OS $build" -Class Information
                Get-OSDUpdate -ErrorAction Stop | 
                    Where-Object { 
                        $_.UpdateOS -eq $OS -and 
                        $_.UpdateArch -eq 'x64' -and 
                        $_.UpdateBuild -eq $build -and 
                        $_.UpdateGroup -eq 'SetupDU' 
                    } | Get-DownOSDUpdate -DownloadPath $global:workdir\updates\$OS\$build\Dynamic
            } catch {
                Update-Log -data 'Failed to download dynamic update' -Class Error
                Update-Log -data $_.Exception.Message -class Error
            }
        }

        Update-Log -Data "Downloading completed for $OS $build" -Class Information
    }
}
