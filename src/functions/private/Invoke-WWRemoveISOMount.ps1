<#
.SYNOPSIS
    Remove ISO mount points.

.DESCRIPTION
    This function removes ISO mount points.

.NOTES
    Name:        Invoke-WWRemoveISOMount.ps1
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
    Invoke-WWRemoveISOMount -inputObject $mountPath
#>
function Invoke-WWRemoveISOMount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$inputObject
    )

    process {
        DO {
            Dismount-DiskImage -InputObject $inputObject
        }
        while (Dismount-DiskImage -InputObject $inputObject)
        #He's dead Jim!
        Write-WimWitchLog -data 'Dismount complete' -class Information
    }
}


