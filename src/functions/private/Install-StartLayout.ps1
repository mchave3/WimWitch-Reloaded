<#
.SYNOPSIS
    Apply the start menu layout to the mounted image.

.DESCRIPTION
    This function is used to apply the start menu layout to the mounted image.

.NOTES
    Name:        Install-StartLayout.ps1
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
    Install-StartLayout
#>
function Install-StartLayout {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            $startpath = $WPFMISMountTextBox.Text + '\users\default\appdata\local\microsoft\windows\shell'
            Update-Log -Data 'Copying the start menu file...' -Class Information
            Copy-Item $WPFCustomTBStartMenu.Text -Destination $startpath -ErrorAction Stop
            $filename = (Split-Path -Path $WPFCustomTBStartMenu.Text -Leaf)
    
            $OS = $Windowstype
    
            if ($os -eq 'Windows 11') {
                if ($filename -ne 'LayoutModification.json') {
                    $newpath = $startpath + '\' + $filename
                    Update-Log -Data 'Renaming json file...' -Class Warning
                    Rename-Item -Path $newpath -NewName 'LayoutModification.json'
                    Update-Log -Data 'file renamed to LayoutModification.json' -Class Information
                }
            }
    
            if ($os -ne 'Windows 11') {
                if ($filename -ne 'LayoutModification.xml') {
                    $newpath = $startpath + '\' + $filename
                    Update-Log -Data 'Renaming xml file...' -Class Warning
                    Rename-Item -Path $newpath -NewName 'LayoutModification.xml'
                    Update-Log -Data 'file renamed to LayoutModification.xml' -Class Information
                }
            }
        } catch {
            Update-Log -Data "Couldn't apply the start menu XML" -Class Error
            Update-Log -data $_.Exception.Message -Class Error
        }
    }
}
