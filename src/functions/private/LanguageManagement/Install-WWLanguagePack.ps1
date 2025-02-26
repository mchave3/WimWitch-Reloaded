<#
.SYNOPSIS
    Install Language Packs into a mounted WIM file.

.DESCRIPTION
    This function is used to install language packs into a mounted WIM file.

.NOTES
    Name:        Install-WWLanguagePack.ps1
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
    Install-WWLanguagePack
#>
function Install-WWLanguagePack {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WimWitchLog -data 'Applying Language Packs...' -Class Information

        $WinOS = Get-WWWindowsType
        $Winver = Get-WWWindowsVersionNumber

        if (($WinOS -eq 'Windows 10') -and (($winver -eq '20H2') -or ($winver -eq '21H1') -or
            ($winver -eq '2009') -or ($winver -eq '21H2') -or ($winver -eq '22H2'))) {
            $winver = '2004'
        }

        $mountdir = $WPFMISMountTextBox.text

        $LPSourceFolder = $script:workingDirectory + '\imports\Lang\' + $WinOS + '\' + $winver + '\LanguagePacks\'
        $items = $WPFCustomLBLangPacks.items

        foreach ($item in $items) {
            $source = $LPSourceFolder + $item

            $text = 'Applying ' + $item
            Write-WimWitchLog -Data $text -Class Information

            try {
                Add-WindowsPackage -PackagePath $source -Path $mountdir -ErrorAction Stop | Out-Null
                Write-WimWitchLog -Data 'Injection Successful' -Class Information
            } catch {
                Write-WimWitchLog -Data 'Failed to inject Language Pack' -Class Error
                Write-WimWitchLog -data $_.Exception.Message -Class Error
            }
        }
        Write-WimWitchLog -Data 'Language Pack injections complete' -Class Information
    }
}




