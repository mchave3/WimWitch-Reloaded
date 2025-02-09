<#
.SYNOPSIS
    Import selected Local Experience Packs into the imports folder.

.DESCRIPTION
    This function imports the selected Local Experience Packs (LXPs) into the appropriate imports folder structure.
    It creates necessary directories for each package and handles different Windows versions.

.NOTES
    Name:        Import-LocalExperiencePack.ps1
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
    Import-LocalExperiencePack -Winver "21H2" -LPSourceFolder "C:\LXPs\" -WinOS "Windows 10"
#>
function Import-LocalExperiencePack {
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
        if ($winver -eq '1903') {
            Write-WWLog -Data 'Changing version variable because 1903 and 1909 use the same packages' -Class Information
            $winver = '1909'
        }

        Write-WWLog -Data 'Importing Local Experience Packs...' -Class Information

        if ((Test-Path -Path $Script:workdir\imports\Lang\$WinOS\$winver\localexperiencepack) -eq $False) {
            Write-WWLog -Data 'Destination folder does not exist. Creating...' -Class Warning
            $path = $Script:workdir + '\imports\Lang\' + $WinOS + '\' + $winver + '\localexperiencepack'
            $text = 'Creating folder ' + $path
            Write-WWLog -data $text -Class Information
            New-Item -Path $Script:workdir\imports\Lang\$WinOS\$winver -Name localexperiencepack -ItemType Directory
            Write-WWLog -Data 'Folder created successfully' -Class Information
        }

        $items = $WPFImportOtherLBList.items
        foreach ($item in $items) {
            $name = $item
            $source = $LPSourceFolder + $name
            $text = 'Creating destination folder for ' + $item
            Write-WWLog -Data $text -Class Information

            if ((Test-Path -Path $Script:workdir\imports\lang\$WinOS\$winver\localexperiencepack\$name) -eq $False) {
                New-Item -Path $Script:workdir\imports\lang\$WinOS\$winver\localexperiencepack -Name $name -ItemType Directory
            }
            else {
                $text = 'The folder for ' + $item + ' already exists. Skipping creation...'
                Write-WWLog -Data $text -Class Warning
            }

            Write-WWLog -Data 'Copying source to destination folders...' -Class Information
            Get-ChildItem -Path $source | Copy-Item -Destination $Script:workdir\imports\Lang\$WinOS\$Winver\LocalExperiencePack\$name -Force
        }
        Write-WWLog -Data 'Importation complete' -Class Information
    }
}
