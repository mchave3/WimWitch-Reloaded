<#
.SYNOPSIS
    Run the OSDSUS and OSDUpdate checks to determine if an update is available.

.DESCRIPTION
    This function will run the OSDSUS and OSDUpdate checks to determine if an update is available.

.NOTES
    Name:        Invoke-OSDCheck.ps1
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
    Invoke-OSDCheck
#>
function Invoke-OSDCheck {
    [CmdletBinding()]
    param(

    )

    process {
        Get-OSDBInstallation #Sets OSDUpate version info
        Get-OSDBCurrentVer #Discovers current version of OSDUpdate
        Compare-OSDBuilderVer #determines if an update of OSDUpdate can be applied
        get-osdsusinstallation #Sets OSDSUS version info
        Get-OSDSUSCurrentVer #Discovers current version of OSDSUS
        Compare-OSDSUSVer #determines if an update of OSDSUS can be applied
    }
}
