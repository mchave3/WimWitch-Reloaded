<#
.SYNOPSIS
    Rename a file by adding the last write time to the filename.

.DESCRIPTION
    This function is used to rename a file by adding the last write time to the filename.

.NOTES
    Name:        Rename-Name.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Rename-Name -file 'C:\path\to\file\file.txt' -extension '.txt'
#>
function Rename-Name {
    [CmdletBinding()]
    param(
        [parameter(mandatory = $true, HelpMessage = 'File to rename')]
        [string]$file,
        [parameter(mandatory = $true, HelpMessage = 'Extension to add')]
        [string]$extension
    )

    process {
        $text = 'Renaming existing ' + $extension + ' file...'
        Update-Log -Data $text -Class Warning
        $filename = (Split-Path -Leaf $file)
        $dateinfo = (Get-Item -Path $file).LastWriteTime -replace (' ', '_') -replace ('/', '_') -replace (':', '_')
        $filename = $filename -replace ($extension, '')
        $filename = $filename + $dateinfo + $extension
        try {
            Rename-Item -Path $file -NewName $filename -ErrorAction Stop
            $text = $file + ' has been renamed to ' + $filename
            Update-Log -Data $text -Class Warning
        } catch {
            Update-Log -data "Couldn't rename file. Stopping..." -force -Class Error
            return 'stop'
        }
    }
}
