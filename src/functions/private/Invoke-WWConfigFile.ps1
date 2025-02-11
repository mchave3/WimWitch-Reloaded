<#
.SYNOPSIS
    Load the configuration file and run the MakeItSo function.

.DESCRIPTION
    This function is used to load the configuration file and run the MakeItSo function.

.NOTES
    Name:        Invoke-WWConfigFile.ps1
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
    Invoke-WWConfigFile -filename $filename
#>
function Invoke-WWConfigFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$filename
    )

    process {
        Write-WimWitchLog -Data "Loading the config file: $filename" -Class Information
        Get-WWConfiguration -filename $filename
        Write-WimWitchLog -Data $WWScriptVer
        Invoke-WWMakeItSo -appx $Script:SelectedAppx
        Write-Output ' '
        Write-Output '##########################################################'
        Write-Output ' '
    }
}




