<#
.SYNOPSIS
    Inject drivers into a WIM file.

.DESCRIPTION
    This function is used to inject drivers into a WIM file.

.NOTES
    Name:        Invoke-WWDriverInjection.ps1
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
    Invoke-WWDriverInjection -folder "C:\Drivers"
#>
function Invoke-WWDriverInjection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$folder
    )

    process {
        $testpath = Test-Path $folder -PathType Container
        If ($testpath -eq $false) { return }

        If ($testpath -eq $true) {

            Write-WWLog -data "Applying drivers from $folder" -class Information

            Get-ChildItem $Folder -Recurse -Filter '*inf' | ForEach-Object { Install-Driver $_.FullName }
            Write-WWLog -Data "Completed driver injection from $folder" -Class Information
        }
    }
}
