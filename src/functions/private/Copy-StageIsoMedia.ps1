<#
.SYNOPSIS
    Copy ISO media files to the staging area.

.DESCRIPTION
    This function copies ISO media files to the staging area, preparing them for ISO creation.
    It handles different Windows versions and their specific requirements.

.NOTES
    Name:        Copy-StageIsoMedia.ps1
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
    Copy-StageIsoMedia
#>
function Copy-StageIsoMedia {
    [CmdletBinding()]
    param(

    )

    process {
        # if($WPFSourceWIMImgDesTextBox.Text -like '*Windows 10*'){$OS = 'Windows 10'}
        # if($WPFSourceWIMImgDesTextBox.Text -like '*Server*'){$OS = 'Windows Server'}

        $OS = Get-WindowsType

        #$Ver = (Get-WinVersionNumber)
        $Ver = $Script:MISWinVer

        #create staging folder
        try {
            Write-WWLog -Data 'Creating staging folder for media' -Class Information
            New-Item -Path $Script:workdir\staging -Name 'Media' -ItemType Directory -ErrorAction Stop | Out-Null
            Write-WWLog -Data 'Media staging folder has been created' -Class Information
        } catch {
            Write-WWLog -Data 'Could not create staging folder' -Class Error
            Write-WWLog -data $_.Exception.Message -class Error
        }

        #copy source to staging
        try {
            Write-WWLog -data 'Staging media binaries...' -Class Information
            Copy-Item -Path $Script:workdir\imports\iso\$OS\$Ver\* -Destination $Script:workdir\staging\media -Force -Recurse -ErrorAction Stop
            Write-WWLog -data 'Media files have been staged' -Class Information
        } catch {
            Write-WWLog -Data 'Failed to stage media binaries...' -Class Error
            Write-WWLog -data $_.Exception.Message -class Error
        }
    }
}
