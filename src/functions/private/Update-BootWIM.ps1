<#
.SYNOPSIS
    Update the boot.wim file in the staging area.

.DESCRIPTION
    This function updates the boot.wim file in the staging area by mounting it, applying updates, and managing the mounting/unmounting process.

.NOTES
    Name:        Update-BootWIM.ps1
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
    Update-BootWIM
#>
function Update-BootWIM {
    [CmdletBinding()]
    param(

    )

    process {
        #create mount point in staging
        try {
            Update-Log -Data 'Creating mount point in staging folder...'
            New-Item -Path $Script:workdir\staging `
                    -Name 'mount' `
                    -ItemType Directory `
                    -ErrorAction Stop
            Update-Log -Data 'Staging folder mount point created successfully' -Class Information
        } catch {
            Update-Log -data 'Failed to create the staging folder mount point' -Class Error
            Update-Log -data $_.Exception.Message -class Error
            return
        }

        #change attribute of boot.wim
        #Change file attribute to normal
        Update-Log -Data 'Setting file attribute of boot.wim to Normal' -Class Information
        $attrib = Get-Item $Script:workdir\staging\media\sources\boot.wim
        $attrib.Attributes = 'Normal'

        $BootImages = Get-WindowsImage -ImagePath $Script:workdir\staging\media\sources\boot.wim
        Foreach ($BootImage in $BootImages) {
            #Mount the PE Image
            try {
                $text = 'Mounting PE image number ' + $BootImage.ImageIndex
                Update-Log -data $text -Class Information
                Mount-WindowsImage `
                    -ImagePath $Script:workdir\staging\media\sources\boot.wim `
                    -Path $Script:workdir\staging\mount `
                    -Index $BootImage.ImageIndex `
                    -ErrorAction Stop
            } catch {
                Update-Log -Data 'Could not mount the boot.wim' -Class Error
                Update-Log -data $_.Exception.Message -class Error
                return
            }

            Update-Log -data 'Applying SSU Update' -Class Information
            Deploy-Update -class 'PESSU'
            Update-Log -data 'Applying LCU Update' -Class Information
            Deploy-Update -class 'PELCU'

            #Dismount the PE Image
            try {
                Update-Log -data 'Dismounting Windows PE image...' -Class Information
                Dismount-WindowsImage -Path $Script:workdir\staging\mount -Save -ErrorAction Stop
            } catch {
                Update-Log -data 'Could not dismount the winpe image.' -Class Error
                Update-Log -data $_.Exception.Message -class Error
            }

            #Export the WinPE Image
            Try {
                Update-Log -data 'Exporting WinPE image index...' -Class Information
                Export-WindowsImage `
                    -SourceImagePath $Script:workdir\staging\media\sources\boot.wim `
                    -SourceIndex $BootImage.ImageIndex `
                    -DestinationImagePath $Script:workdir\staging\tempboot.wim `
                    -ErrorAction Stop
            } catch {
                Update-Log -Data 'Failed to export WinPE image' -Class Error
                Update-Log -data $_.Exception.Message -class Error
            }
        }

        #Overwrite the stock boot.wim file with the updated one
        try {
            Update-Log -Data 'Overwriting boot.wim with updated and optimized version...' -Class Information
            Move-Item -Path $Script:workdir\staging\tempboot.wim -Destination $Script:workdir\staging\media\sources\boot.wim -Force -ErrorAction Stop
            Update-Log -Data 'Boot.WIM updated successfully' -Class Information
        } catch {
            Update-Log -Data 'Could not copy the updated boot.wim' -Class Error
            Update-Log -data $_.Exception.Message -class Error
        }
    }
}
