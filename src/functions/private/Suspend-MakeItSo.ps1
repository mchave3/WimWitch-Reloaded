<#
.SYNOPSIS
    Pause the image build process.

.DESCRIPTION
    This function allows the user to pause the image build process and choose whether to continue or cancel the build.
    If cancelled, the WIM file will be discarded.

.NOTES
    Name:        Suspend-MakeItSo.ps1
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
    Suspend-MakeItSo
#>
function Suspend-MakeItSo {
    [CmdletBinding()]
    param(

    )

    process {
        $MISPause = ([System.Windows.MessageBox]::Show(
            'Click Yes to continue the image build. Click No to cancel and discard the wim file.', 
            'WIM Witch Paused', 
            'YesNo', 
            'Warning'
        ))
        
        if ($MISPause -eq 'Yes') { 
            return 'Yes' 
        }

        if ($MISPause -eq 'No') { 
            return 'No' 
        }
    }
}
