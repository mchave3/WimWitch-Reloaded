<#
.SYNOPSIS
    Import Features On Demand into the imports folder.

.DESCRIPTION
    This function imports the selected Features On Demand (FODs) into the appropriate imports folder structure.
    It handles different Windows versions (including Windows 11) and creates necessary directories.

.NOTES
    Name:        Import-FeatureOnDemand.ps1
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
    Import-FeatureOnDemand -Winver "21H2" -LPSourceFolder "C:\FODs\" -WinOS "Windows 10"
#>
function Import-FeatureOnDemand {
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

        $path = $WPFImportOtherTBPath.text
        $text = 'Starting importation of Feature On Demand binaries from ' + $path
        Write-WWLog -Data $text -Class Information

        $langpacks = Get-ChildItem -Path $LPSourceFolder

        if ((Test-Path -Path $Script:workdir\imports\FODs\$WinOS\$Winver) -eq $False) {
            Write-WWLog -Data 'Destination folder does not exist. Creating...' -Class Warning
            $path = $Script:workdir + '\imports\FODs\' + $WinOS + '\' + $winver
            $text = 'Creating folder ' + $path
            Write-WWLog -data $text -Class Information
            New-Item -Path $Script:workdir\imports\fods\$WinOS -Name $winver -ItemType Directory
            Write-WWLog -Data 'Folder created successfully' -Class Information
        }

        #If Windows 11
        if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') {
            $items = $WPFImportOtherLBList.items
            foreach ($item in $items) {
                $source = $LPSourceFolder + $item
                $text = 'Importing ' + $item
                Write-WWLog -Data $text -Class Information
                Copy-Item $source -Destination $Script:workdir\imports\FODs\$WinOS\$Winver\ -Force
            }
        }

        #If not Windows 11
        if ($WPFImportOtherCBWinOS.SelectedItem -ne 'Windows 11') {
            foreach ($langpack in $langpacks) {
                $source = $LPSourceFolder + $langpack.name
                Copy-Item $source -Destination $Script:workdir\imports\FODs\$WinOS\$Winver\ -Force
                $name = $langpack.name
                $text = 'Copying ' + $name
                Write-WWLog -Data $text -Class Information
            }
        }

        Write-WWLog -Data 'Importing metadata subfolder...' -Class Information
        Get-ChildItem -Path ($LPSourceFolder + '\metadata\') | Copy-Item -Destination $Script:workdir\imports\FODs\$WinOS\$Winver\metadata -Force
        Write-WWLog -data 'Feature On Demand imporation complete.'
    }
}
