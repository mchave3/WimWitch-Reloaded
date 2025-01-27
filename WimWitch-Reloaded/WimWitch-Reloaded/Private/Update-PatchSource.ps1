<#
.SYNOPSIS
    Remove superceded updates and download the latest updates for the selected OS and build.

.DESCRIPTION
    This function is used to remove superceded updates and download the latest updates for the selected OS and build.

.NOTES
    Name:        Update-PatchSource.ps1
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
    Update-PatchSource
#>
function Update-PatchSource {
    [CmdletBinding()]
    param(

    )

    process {
        Update-Log -Data 'attempting to start download Function' -Class Information
        if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'OSDSUS') {
            if ($WPFUpdatesW10Main.IsChecked -eq $true) {
                if ($WPFUpdatesW10_22H2.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 22H2 -OS 'Windows 10'
                    Get-WindowsPatches -build 22H2 -OS 'Windows 10'
                }
                if ($WPFUpdatesW10_21H2.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 21H2 -OS 'Windows 10'
                    Get-WindowsPatches -build 21H2 -OS 'Windows 10'
                }
                if ($WPFUpdatesW10_21H1.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 21H1 -OS 'Windows 10'
                    Get-WindowsPatches -build 21H1 -OS 'Windows 10'
                }
                if ($WPFUpdatesW10_20H2.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 20H2 -OS 'Windows 10'
                    Get-WindowsPatches -build 20H2 -OS 'Windows 10'
                }
                if ($WPFUpdatesW10_2004.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 2004 -OS 'Windows 10'
                    Get-WindowsPatches -build 2004 -OS 'Windows 10'
                }
                if ($WPFUpdatesW10_1909.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 1909 -OS 'Windows 10'
                    Get-WindowsPatches -build 1909 -OS 'Windows 10'
                }
                if ($WPFUpdatesW10_1903.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 1903 -OS 'Windows 10'
                    Get-WindowsPatches -build 1903 -OS 'Windows 10'
                }
                if ($WPFUpdatesW10_1809.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 1809 -OS 'Windows 10'
                    Get-WindowsPatches -build 1809 -OS 'Windows 10'
                }
                if ($WPFUpdatesW10_1803.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 1803 -OS 'Windows 10'
                    Get-WindowsPatches -build 1803 -OS 'Windows 10'
                }
                if ($WPFUpdatesW10_1709.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 1709 -OS 'Windows 10'
                    Get-WindowsPatches -build 1709 -OS 'Windows 10'
                }
            }
            if ($WPFUpdatesS2019.IsChecked -eq $true) {
                Test-Superceded -action delete -build 1809 -OS 'Windows Server'
                Get-WindowsPatches -build 1809 -OS 'Windows Server'
            }
            if ($WPFUpdatesS2016.IsChecked -eq $true) {
                Test-Superceded -action delete -build 1607 -OS 'Windows Server'
                Get-WindowsPatches -build 1607 -OS 'Windows Server'
            }
            if ($WPFUpdatesS2022.IsChecked -eq $true) {
                Test-Superceded -action delete -build 21H2 -OS 'Windows Server'
                Get-WindowsPatches -build 21H2 -OS 'Windows Server'
            }
    
            if ($WPFUpdatesW11Main.IsChecked -eq $true) {
                if ($WPFUpdatesW11_22H2.IsChecked -eq $true) {
                    Test-Superceded -action delete -build 22H2 -OS 'Windows 11'
                    Get-WindowsPatches -build 22H2 -OS 'Windows 11'
                }
                if ($WPFUpdatesW11_21h2.IsChecked -eq $true) {
                    Write-Host '21H2'
                    Test-Superceded -action delete -build 21H2 -OS 'Windows 11'
                    Get-WindowsPatches -build 21H2 -OS 'Windows 11'
                }
                if ($WPFUpdatesW11_23h2.IsChecked -eq $true) {
                    Write-Host '23H2'
                    Test-Superceded -action delete -build 23H2 -OS 'Windows 11'
                    Get-WindowsPatches -build 23H2 -OS 'Windows 11'
                }
    
            }
            Get-OneDrive
        }
    
        if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'ConfigMgr') {
            if ($WPFUpdatesW10Main.IsChecked -eq $true) {
                if ($WPFUpdatesW10_22H2.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '22H2'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '22H2'
                }
                if ($WPFUpdatesW10_21H2.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '21H2'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '21H2'
                }
                if ($WPFUpdatesW10_21H1.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '21H1'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '21H1'
                }
                if ($WPFUpdatesW10_20H2.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '20H2'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '20H2'
                }
                if ($WPFUpdatesW10_2004.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '2004'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '2004'
                }
                if ($WPFUpdatesW10_1909.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '1909'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '1909'
                }
                if ($WPFUpdatesW10_1903.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '1903'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '1903'
                }
                if ($WPFUpdatesW10_1809.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '1809'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '1809'
                }
                if ($WPFUpdatesW10_1803.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '1803'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '1803'
                }
                if ($WPFUpdatesW10_1709.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver '1709'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -ver '1709'
                }
                #Get-OneDrive
            }
            if ($WPFUpdatesS2019.IsChecked -eq $true) {
                Invoke-MEMCMUpdateSupersedence -prod 'Windows Server' -Ver '1809'
                Invoke-MEMCMUpdatecatalog -prod 'Windows Server' -Ver '1809'
            }
            if ($WPFUpdatesS2016.IsChecked -eq $true) {
                Invoke-MEMCMUpdateSupersedence -prod 'Windows Server' -Ver '1607'
                Invoke-MEMCMUpdatecatalog -prod 'Windows Server' -Ver '1607'
            }
            if ($WPFUpdatesS2022.IsChecked -eq $true) {
                Invoke-MEMCMUpdateSupersedence -prod 'Windows Server' -Ver '21H2'
                Invoke-MEMCMUpdatecatalog -prod 'Windows Server' -Ver '21H2'
            }
            if ($WPFUpdatesW11Main.IsChecked -eq $true) {
                if ($WPFUpdatesW11_21H2.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 11' -Ver '21H2'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 11' -ver '21H2'
                }
                if ($WPFUpdatesW11_22H2.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 11' -Ver '22H2'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 11' -ver '22H2'
                }
                if ($WPFUpdatesW11_23H2.IsChecked -eq $true) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows 11' -Ver '23H2'
                    Invoke-MEMCMUpdatecatalog -prod 'Windows 11' -ver '23H2'
                }
            }
            Get-OneDrive
        }
        Update-Log -data 'All downloads complete' -class Information
    }
}
