<#
.SYNOPSIS
    Run the OSDSUS and OSDUpdate checks to determine if an update is available.

.DESCRIPTION
    This function will run the OSDSUS and OSDUpdate checks to determine if an update is available.

.NOTES
    Name:        Invoke-WWOSDCheck.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-02
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Invoke-WWOSDCheck
#>
function Invoke-WWOSDCheck {
    [CmdletBinding()]
    param(

    )

    process {
        Get-WWOSDeploymentInstallation #Sets OSDUpate version info
        Get-WWOSDeploymentCurrentVersion #Discovers current version of OSDUpdate
        Compare-WWOSDBuilderVersion #determines if an update of OSDUpdate can be applied
        Get-WWOSDSUSInstallation #Sets OSDSUS version info
        Get-WWOSDSUSCurrentVersion #Discovers current version of OSDSUS
        Compare-WWOSDSUSVersion #determines if an update of OSDSUS can be applied
    }
}



