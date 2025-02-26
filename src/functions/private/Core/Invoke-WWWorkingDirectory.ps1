<#
.SYNOPSIS
    

.DESCRIPTION
    

.NOTES
    Name:        Invoke-WWWorkingDirectory.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-25
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Invoke-WWWorkingDirectory
#>
function Invoke-WWWorkingDirectory {
    [CmdletBinding()]
    param(

    )

    process {
        $subfolders = @(
            'CompletedWIMs'
            'Configs'
            'Drivers'
            'Jobs'
            'Logging'
            'Mount'
            'Staging'
            'Updates'
            'Imports'
            'Imports\WIM'
            'Imports\DotNet'
            'Autopilot'
            'Backup'
        )
    }
}