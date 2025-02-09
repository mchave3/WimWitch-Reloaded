<#
.SYNOPSIS
    Select Appx packages to remove from the WIM.

.DESCRIPTION
    This function is used to select Appx packages to remove from the WIM.

.NOTES
    Name:        Select-Appx.ps1
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
    Select-Appx
#>
function Select-Appx {
    [CmdletBinding()]
    param(

    )

    process {
        $AssetsPath = Join-Path -Path $PSScriptRoot -ChildPath 'Assets'

        $OS = Get-WindowsType
        $buildnum = $WPFSourceWimTBVersionNum.text

        if ($OS -eq 'Windows 10') {
            $OS = 'Win10'
        }
        if ($OS -eq 'Windows 11') {
            $OS = 'Win11'
        }

        $appxListFile = Join-Path -Path $AssetsPath -ChildPath $("appx$OS" + '_' + "$buildnum.txt")
        Write-WWLog -Data "Looking for Appx list file $appxListFile" -Class Information

        if (Test-Path $appxListFile) {
            $appxPackages = Get-Content $appxListFile
            $exappxs = $appxPackages | Out-GridView -Title 'Select apps to remove' -PassThru
        } else {
            Write-Warning "No matching Appx list file found for build $buildnum."
            return
        }

        if ($null -eq $exappxs) {
            Write-WWLog -Data 'No apps were selected' -Class Warning
        } elseif ($null -ne $exappxs) {
            Write-WWLog -data 'The following apps were selected for removal:' -Class Information
            Foreach ($exappx in $exappxs) {
                Write-WWLog -Data $exappx -Class Information
            }

            $WPFAppxTextBox.Text = $exappxs -join "`r`n"
            return $exappxs
        }
    }
}

