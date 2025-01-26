<#
.SYNOPSIS
.DESCRIPTION
    This function checks if the current user has administrative privileges.
#>
function Test-Admin {
    [CmdletBinding()]
    param(

    )

    process {
        $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
        $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    
        if ($currentUser.IsInRole($adminRole)) {
            Update-Log -Data 'User has admin privileges' -Class Information
        } else {
            Update-Log -Data 'This script requires administrative privileges. Please run it as an administrator.' -Class Error
            Exit
        }
    }
}
