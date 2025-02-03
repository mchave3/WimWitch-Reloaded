<#
.SYNOPSIS
    Install Local Experience Packs to the mounted WIM file.

.DESCRIPTION
    This function will install Local Experience Packs to the mounted WIM file.

.NOTES
    Name:        Install-LocalExperiencePack.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-31
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Install-LocalExperiencePack
#>
function Install-LocalExperiencePack {
    [CmdletBinding()]
    param(

    )

    process {
        Update-Log -data 'Applying Local Experience Packs...' -Class Information

        $mountdir = $WPFMISMountTextBox.text

        $WinOS = Get-WindowsType
        $Winver = Get-WinVersionNumber

        if (($WinOS -eq 'Windows 10') -and (($winver -eq '20H2') -or ($winver -eq '21H1') -or ($winver -eq '2009') -or ($winver -eq '21H2') -or ($winver -eq '22H2'))) { $winver = '2004' }

        $LPSourceFolder = $global:workdir + '\imports\Lang\' + $WinOS + '\' + $winver + '\localexperiencepack\'
        $items = $WPFCustomLBLEP.items

        foreach ($item in $items) {
            $source = $LPSourceFolder + $item
            $license = Get-Item -Path $source\*.xml
            $file = Get-Item -Path $source\*.appx
            $text = 'Applying ' + $item
            Update-Log -Data $text -Class Information
            try {
                Add-ProvisionedAppxPackage -PackagePath $file -LicensePath $license -Path $mountdir -ErrorAction Stop | Out-Null
                Update-Log -Data 'Injection Successful' -Class Information
            } catch {
                Update-Log -data 'Failed to apply Local Experience Pack' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
            }
        }
        Update-Log -Data 'Local Experience Pack injections complete' -Class Information
    }
}
