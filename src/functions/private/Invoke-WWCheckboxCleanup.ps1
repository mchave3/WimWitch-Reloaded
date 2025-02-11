<#
.SYNOPSIS
    Clean up checkbox states.

.DESCRIPTION
    This function resets checkbox states in the UI to their default values.

.NOTES
    Name:        Invoke-WWCheckboxCleanup.ps1
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
    Invoke-WWCheckboxCleanup
#>
function Invoke-WWCheckboxCleanup {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WimWitchLog -Data 'Cleaning null checkboxes...' -Class Information
        $Variables = Get-Variable WPF*
        foreach ($variable in $variables) {

            if ($variable.value -like '*.CheckBox*') {
                #write-host $variable.name
                #write-host $variable.value.IsChecked
                if ($variable.value.IsChecked -ne $true) { $variable.value.IsChecked = $false }
            }
        }
    }
}


