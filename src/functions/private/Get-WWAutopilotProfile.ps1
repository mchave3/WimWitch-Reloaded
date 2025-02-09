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
        [string]$path
    )

    process {
        Write-WWLog -data 'Checking dependencies for Autopilot profile retrieval...' -Class Information

        try {
            Import-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -ErrorAction Stop
            Write-WWLog -Data 'NuGet is installed' -Class Information
        } catch {
            Write-WWLog -data 'NuGet is not installed. Installing now...' -Class Warning
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
            Write-WWLog -data 'NuGet is now installed' -Class Information
        }

        try {

            Import-Module -Name AzureAD -ErrorAction Stop | Out-Null
            Write-WWLog -data 'AzureAD Module is installed' -Class Information
        } catch {
            Write-WWLog -data 'AzureAD Module is not installed. Installing now...' -Class Warning
            Install-Module AzureAD -Force
            Write-WWLog -data 'AzureAD is now installed' -class Information
        }

        try {

            Import-Module -Name WindowsAutopilotIntune -ErrorAction Stop
            Write-WWLog -data 'WindowsAutopilotIntune module is installed' -Class Information
        } catch {

            Write-WWLog -data 'WindowsAutopilotIntune module is not installed. Installing now...' -Class Warning
            Install-Module WindowsAutopilotIntune -Force
            Write-WWLog -data 'WindowsAutopilotIntune module is now installed.' -class Information
        }

        $AutopilotInstalledVer = (Get-Module -Name windowsautopilotintune).Version
        Write-WWLog -Data "The currently installed version of the WindowsAutopilotIntune module is $AutopilotInstalledVer" `
            -Class Information
        $AutopilotLatestVersion = (Find-Module -Name windowsautopilotintune).version
        Write-WWLog -data "The latest available version of the WindowsAutopilotIntune module is $AutopilotLatestVersion" `
            -Class Information

        if ($AutopilotInstalledVer -eq $AutopilotLatestVersion) {
            Write-WWLog -data 'WindowsAutopilotIntune module is current. Continuing...' -Class Information
        } else {
            Write-WWLog -data 'WindowsAutopilotIntune module is out of date. Prompting the user to upgrade...'
            $UpgradeAutopilot = ([System.Windows.MessageBox]::Show(
                "Would you like to update the WindowsAutopilotIntune module to version $AutopilotLatestVersion now?",
                'Update Autopilot Module?',
                'YesNo',
                'warning'))
        }

        if ($UpgradeAutopilot -eq 'Yes') {
            Write-WWLog -Data 'User has chosen to update WindowsAutopilotIntune module' -Class Warning
            Install-WWAutopilotModule
        } elseif ($AutopilotInstalledVer -ne $AutopilotLatestVersion) {
            Write-WWLog -data 'User declined to update WindowsAutopilotIntune module. Continuing...' -Class Warning
        }

        Write-WWLog -data 'Connecting to Intune...' -Class Information
        if ($AutopilotInstalledVer -lt 3.9) { Connect-AutopilotIntune | Out-Null }
        else {
            Connect-MSGraph | Out-Null
        }

        Write-WWLog -data 'Connected to Intune' -Class Information

        Write-WWLog -data 'Retrieving profile...' -Class Information
        Get-AutoPilotProfile |
            Out-GridView -Title 'Select Autopilot profile' -PassThru |
            ConvertTo-AutoPilotConfigurationJSON |
            Out-File $path\AutopilotConfigurationFile.json -Encoding ASCII
        $text = $path + '\AutopilotConfigurationFile.json'
        Write-WWLog -data "Profile successfully created at $text" -Class Information
    }
}

