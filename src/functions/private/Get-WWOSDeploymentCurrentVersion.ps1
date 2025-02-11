<#
.SYNOPSIS
    Get the most current version of OSDUpdate available on the PowerShell Gallery.

.DESCRIPTION
    This function is used to get the most current version of OSDUpdate available on the PowerShell Gallery.

.NOTES
    Name:        Get-WWOSDeploymentCurrentVersion.ps1
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
    Get-WWOSDeploymentCurrentVersion
#>
function Get-WWOSDeploymentCurrentVersion {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WimWitchLog -Data 'Checking for the most current OSDUpdate version available' -Class Information
        try {
            $OSDBCurrentVer = Find-Module -Name OSDUpdate -ErrorAction Stop
            $WPFUpdatesOSDBCurrentVerTextBox.Text = $OSDBCurrentVer.version
            $text = $OSDBCurrentVer.version
            Write-WimWitchLog -data "$text is the most current version" -class Information
            Return
        } catch {
            $WPFUpdatesOSDBCurrentVerTextBox.Text = 'Network Error'
            Return
        }
    }
}



