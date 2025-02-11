<#
.SYNOPSIS
    Check the WIM Witch Update store for superseded updates.

.DESCRIPTION
    This function is used to check the WIM Witch Update store for superseded updates.

.NOTES
    Name:        Test-WWSuperseded.ps1
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
    Test-WWSuperseded -OS 'Windows 10' -Build '1909' -action 'audit'
#>
function Test-WWSuperseded {
    [CmdletBinding()]
    param(
        [string]$OS,
        [string]$Build,
        [string]$action
    )

    process {
        Write-WimWitchLog -Data 'Checking WIM Witch Update store for superseded updates' -Class Information
        $path = $Script:workdir + '\updates\' + $OS + '\' + $Build + '\' #sets base path

        if ((Test-Path -Path $path) -eq $false) {
            Write-WimWitchLog -Data 'No updates found, likely not yet downloaded. Skipping supersedense check...' -Class Warning
            return
        }

        $Children = Get-ChildItem -Path $path  #query sub directories

        foreach ($Children in $Children) {
            $path1 = $path + $Children
            $sprout = Get-ChildItem -Path $path1

            foreach ($sprout in $sprout) {
                $path3 = $path1 + '\' + $sprout
                $fileinfo = Get-ChildItem -Path $path3
                foreach ($file in $fileinfo) {
                    $StillCurrent = Get-OSDUpdate |
                        Where-Object { $_.FileName -eq $file }
                    If ($null -eq $StillCurrent) {
                        Write-WimWitchLog -data "$file no longer current" -Class Warning
                        if ($action -eq 'delete') {
                            Write-WimWitchLog -data "Deleting $path3" -class Warning
                            Remove-Item -Path $path3 -Recurse -Force
                        }
                        if ($action -eq 'audit') {
                            $message = 'Superceded updates discovered. Please select the versions of Windows 10 ' + `
                                'you are supporting and click Update'
                            $WPFUpdatesOSDListBox.items.add($message)
                            Return
                        }
                    } else {
                        Write-WimWitchLog -data "$file is still current" -Class Information
                    }
                }
            }
        }
        Write-WimWitchLog -data 'Supercedense check complete.' -Class Information
    }
}


