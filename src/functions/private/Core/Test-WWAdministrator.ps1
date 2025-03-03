<#
.SYNOPSIS
    Check if the current user has administrative privileges.

.DESCRIPTION
    This function checks if the current user has administrative privileges.

.NOTES
    Name:        Test-WWAdministrator.ps1
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
    Test-WWAdministrator
#>
function Test-WWAdministrator {
    [CmdletBinding()]
    param(

    )

    process {
        $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
        $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

        if ($currentUser.IsInRole($adminRole)) {
            Write-WimWitchLog -Data 'User has admin privileges' -Class Information
        } else {
            Write-WimWitchLog -Data 'This script requires administrative privileges. Please run it as an administrator.' -Class Error
            Exit
        }
    }
}

