<#
.SYNOPSIS
    Select the working directory.

.DESCRIPTION
    This function is used to select the working directory.

.NOTES
    Name:        Select-WorkingDirectory.ps1
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
    Select-WorkingDirectory
#>
function Select-WorkingDirectory {
    [CmdletBinding()]
    param(

    )

    process {
        $selectWorkingDirectory = New-Object System.Windows.Forms.FolderBrowserDialog
        $selectWorkingDirectory.Description = 'Select the working directory.'
        $null = $selectWorkingDirectory.ShowDialog()

        if ($selectWorkingDirectory.SelectedPath -eq '') {
            Write-Output 'User Cancelled or invalid entry'
            exit 0
        }

        return $selectWorkingDirectory.SelectedPath
    }
}

