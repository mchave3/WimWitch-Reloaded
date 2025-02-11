<#
.SYNOPSIS
    Import selected Language Packs into the Imports folder.

.DESCRIPTION
    This function imports the selected Language Packs (LPs) into the appropriate imports folder structure.
    It handles different Windows versions and creates necessary directories if they don't exist.

.NOTES
    Name:        Import-WWLanguagePack.ps1
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
    Import-WWLanguagePack -Winver "21H2" -LPSourceFolder "C:\LanguagePacks\" -WinOS "Windows 10"
#>
function Import-WWLanguagePack {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Winver,

        [Parameter(Mandatory = $true)]
        [string]$LPSourceFolder,

        [Parameter(Mandatory = $true)]
        [string]$WinOS
    )

    process {
        Write-WimWitchLog -Data 'Importing Language Packs...' -Class Information

        if ($winver -eq '1903') {
            Write-WimWitchLog -Data 'Changing version variable because 1903 and 1909 use the same packages' -Class Information
            $winver = '1909'
        }

        if ((Test-Path -Path $Script:workdir\imports\Lang\$WinOS\$winver\LanguagePacks) -eq $False) {
            Write-WimWitchLog -Data 'Destination folder does not exist. Creating...' -Class Warning
            $path = $Script:workdir + '\imports\Lang\' + $WinOS + '\' + $winver + '\LanguagePacks'
            $text = 'Creating folder ' + $path
            Write-WimWitchLog -data $text -Class Information
            New-Item -Path $Script:workdir\imports\Lang\$WinOS\$winver -Name LanguagePacks -ItemType Directory
            Write-WimWitchLog -Data 'Folder created successfully' -Class Information
        }

        $items = $WPFImportOtherLBList.items
        foreach ($item in $items) {
            $source = $LPSourceFolder + $item
            $text = 'Importing ' + $item
            Write-WimWitchLog -Data $text -Class Information
            Copy-Item $source -Destination $Script:workdir\imports\Lang\$WinOS\$Winver\LanguagePacks -Force
        }
        Write-WimWitchLog -Data 'Importation Complete' -Class Information
    }
}


