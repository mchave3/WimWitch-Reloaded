<#
.SYNOPSIS
    Get the Windows version number from the image description.

.DESCRIPTION
    This function will return the Windows version number based on the image description.

.NOTES
    Name:        Get-WinVersionNumber.ps1
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
    Get-WinVersionNumber
#>
function Get-WinVersionNumber {
    [CmdletBinding()]
    param(

    )

    process {
        $buildnum = $null

        # Latest 10 Windows 10 version checks
        switch -Regex ($WPFSourceWimVerTextBox.text) {
            
            #Windows 10 version checks
            '10\.0\.19044\.\d+' { $buildnum = '21H2' }
            '10\.0\.19045\.\d+' { $buildnum = '22H2' }

            # Windows 11 version checks
            '10\.0\.22000\.\d+' { $buildnum = '21H2' }
            '10\.0\.22621\.\d+' { $buildnum = '22H2' }
            '10\.0\.22631\.\d+' { $buildnum = '23H2' }

            Default { $buildnum = 'Unknown Version' }
        }

        If ($WPFSourceWimVerTextBox.text -like '10.0.19041.*') {
            $IsMountPoint = $False
            $currentmounts = Get-WindowsImage -Mounted
            foreach ($currentmount in $currentmounts) {
                if ($currentmount.path -eq $WPFMISMountTextBox.text) { $IsMountPoint = $true }
            }

            #IS a mount path
            If ($IsMountPoint -eq $true) {
                $mountdir = $WPFMISMountTextBox.Text
                reg LOAD HKLM\OFFLINE $mountdir\Windows\System32\Config\SOFTWARE | Out-Null
                $regvalues = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\OFFLINE\Microsoft\Windows NT\CurrentVersion\' )
                $buildnum = $regvalues.ReleaseId
                if ($regvalues.ReleaseId -eq '2009') {
                    if ($regvalues.CurrentBuild -eq '19042') { $buildnum = '2009' }
                    if ($regvalues.CurrentBuild -eq '19043') { $buildnum = '21H1' }
                    if ($regvalues.CurrentBuild -eq '19044') { $buildnum = '21H2' }
                    if ($regvalues.CurrentBuild -eq '19045') { $buildnum = '22H2' }
                }

                reg UNLOAD HKLM\OFFLINE | Out-Null
            }

            If ($IsMountPoint -eq $False) {
                $global:Win10VerDet = $null

                Update-Log -data 'Prompting user for Win10 version confirmation...' -class Information

                Invoke-19041Select

                if ($null -eq $global:Win10VerDet) { return }

                $temp = $global:Win10VerDet

                $buildnum = $temp
                Update-Log -data "User selected $buildnum" -class Information

                $global:Win10VerDet = $null
            }
        }
        return $buildnum
    }
}
