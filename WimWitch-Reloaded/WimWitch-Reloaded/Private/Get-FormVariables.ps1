<#
.SYNOPSIS
.DESCRIPTION
    This function is used to get all the variables that are used in the WPF forms.
#>
function Get-FormVariables {
    [CmdletBinding()]
    param(

    )

    process {
        if ($global:ReadmeDisplay -ne $true) { 
            Write-Host 'If you need to reference this display again, run Get-FormVariables' -ForegroundColor Yellow; $global:ReadmeDisplay = $true 
        }
        Get-Variable WPF*
    }
}
