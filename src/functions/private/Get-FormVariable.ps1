<#
.SYNOPSIS
    Get all the variables that are used in the WPF forms.

.DESCRIPTION
    This function is used to get all the variables that are used in the WPF forms.

.NOTES
    Name:        Get-FormVariable.ps1
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
    Get-FormVariable
#>
function Get-FormVariable {
    [CmdletBinding()]
    param(

    )

    process {
        if ($global:ReadmeDisplay -ne $true) { 
            Write-Host 'If you need to reference this display again, run Get-FormVariable' -ForegroundColor Yellow; $global:ReadmeDisplay = $true 
        }
        Get-Variable WPF*
    }
}
