<#
.SYNOPSIS
    Retrieve the Autopilot profile from Intune.

.DESCRIPTION
    This function is used to retrieve the Autopilot profile from Intune.

.NOTES
    Name:        Get-WWAutopilotProfile.ps1
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
    Get-WWAutopilotProfile -path "C:\Temp" -login ""
#>
function Get-WWAutopilotProfile {
    [CmdletBinding()]
    param(
        [string]$path,
        [string]$login
    )

    process {
        Update-Log -data 'Checking dependencies for Autopilot profile retrieval...' -Class Information

        try {
            Import-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -ErrorAction Stop
            Update-Log -Data 'NuGet is installed' -Class Information
        } catch {
            Update-Log -data 'NuGet is not installed. Installing now...' -Class Warning
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
            Update-Log -data 'NuGet is now installed' -Class Information
        }
    
        try {
    
            Import-Module -Name AzureAD -ErrorAction Stop | Out-Null
            Update-Log -data 'AzureAD Module is installed' -Class Information
        } catch {
            Update-Log -data 'AzureAD Module is not installed. Installing now...' -Class Warning
            Install-Module AzureAD -Force
            Update-Log -data 'AzureAD is now installed' -class Information
        }
    
        try {
    
            Import-Module -Name WindowsAutopilotIntune -ErrorAction Stop
            Update-Log -data 'WindowsAutopilotIntune module is installed' -Class Information
        } catch {
    
            Update-Log -data 'WindowsAutopilotIntune module is not installed. Installing now...' -Class Warning
            Install-Module WindowsAutopilotIntune -Force
            Update-Log -data 'WindowsAutopilotIntune module is now installed.' -class Information
        }
    
        $AutopilotInstalledVer = (Get-Module -Name windowsautopilotintune).Version
        Update-Log -Data "The currently installed version of the WindowsAutopilotIntune module is $AutopilotInstalledVer" -Class Information
        $AutopilotLatestVersion = (Find-Module -Name windowsautopilotintune).version
        Update-Log -data "The latest available version of the WindowsAutopilotIntune module is $AutopilotLatestVersion" -Class Information
    
        if ($AutopilotInstalledVer -eq $AutopilotLatestVersion) {
            Update-Log -data 'WindowsAutopilotIntune module is current. Continuing...' -Class Information
        } else {
            Update-Log -data 'WindowsAutopilotIntune module is out of date. Prompting the user to upgrade...'
            $UpgradeAutopilot = ([System.Windows.MessageBox]::Show("Would you like to update the WindowsAutopilotIntune module to version $AutopilotLatestVersion now?", 'Update Autopilot Module?', 'YesNo', 'warning'))
        }
    
        if ($UpgradeAutopilot -eq 'Yes') {
            Update-Log -Data 'User has chosen to update WindowsAutopilotIntune module' -Class Warning
            Update-Autopilot
        } elseif ($AutopilotInstalledVer -ne $AutopilotLatestVersion) {
            Update-Log -data 'User declined to update WindowsAutopilotIntune module. Continuing...' -Class Warning
        }
    
    
        Update-Log -data 'Connecting to Intune...' -Class Information
        if ($AutopilotInstalledVer -lt 3.9) { Connect-AutopilotIntune | Out-Null }
        else {
            Connect-MSGraph | Out-Null
        }
    
        Update-Log -data 'Connected to Intune' -Class Information
    
        Update-Log -data 'Retrieving profile...' -Class Information
        Get-AutoPilotProfile | Out-GridView -Title 'Select Autopilot profile' -PassThru | ConvertTo-AutoPilotConfigurationJSON | Out-File $path\AutopilotConfigurationFile.json -Encoding ASCII
        $text = $path + '\AutopilotConfigurationFile.json'
        Update-Log -data "Profile successfully created at $text" -Class Information
    }
}
