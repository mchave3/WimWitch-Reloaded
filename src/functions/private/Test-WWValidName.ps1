<#
.SYNOPSIS
    Test the name of a WIM file

.DESCRIPTION
    This function is used to test the name of a WIM file. If the name is not valid, it will append the .wim extension to the name.

.NOTES
    Name:        Test-WWValidName.ps1
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
    Test-WWValidName
    Test-WWValidName -conflict append
    Test-WWValidName -conflict backup
    Test-WWValidName -conflict overwrite
#>
function Test-WWValidName {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [parameter(mandatory = $false, HelpMessage = 'what to do')]
        [ValidateSet('stop', 'append', 'backup', 'overwrite')]
        $conflict = 'stop'
    )

    process {
        If ($WPFMISWimNameTextBox.Text -like '*.wim') {
            #$WPFLogging.Focus()
            #Write-WimWitchLog -Data "New WIM name is valid" -Class Information
        }

        If ($WPFMISWimNameTextBox.Text -notlike '*.wim') {
            $WPFMISWimNameTextBox.Text = $WPFMISWimNameTextBox.Text + '.wim'
            Write-WimWitchLog -Data 'Appending new file name with an extension' -Class Information
        }

        $WIMpath = $WPFMISWimFolderTextBox.text + '\' + $WPFMISWimNameTextBox.Text
        $FileCheck = Test-Path -Path $WIMpath

        #append,overwrite,stop

        if ($FileCheck -eq $false) { Write-WimWitchLog -data 'Target WIM file name not in use. Continuing...' -class Information }
        else {
            if ($conflict -eq 'append') {
                $renamestatus = (Rename-WWName -file $WIMpath -extension '.wim')
                if ($renamestatus -eq 'stop') { return 'stop' }
            }
            if ($conflict -eq 'overwrite') {
                Write-Host 'overwrite action'
                return
            }
            if ($conflict -eq 'stop') {
                $string = $WPFMISWimNameTextBox.Text + ' already exists. Rename the target WIM and try again'
                Write-WimWitchLog -Data $string -Class Warning
                return 'stop'
            }
        }
        Write-WimWitchLog -Data 'New WIM name is valid' -Class Information
    }
}


