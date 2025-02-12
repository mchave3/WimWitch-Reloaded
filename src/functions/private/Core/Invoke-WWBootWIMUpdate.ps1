<#
.SYNOPSIS
    Update the boot.wim file in the staging area.

.DESCRIPTION
    This function updates the boot.wim file in the staging area by mounting it, applying updates, and managing the mounting/unmounting process.

.NOTES
    Name:        Invoke-WWBootWIMUpdate.ps1
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
    Invoke-WWBootWIMUpdate
#>
function Invoke-WWBootWIMUpdate {
    [CmdletBinding()]
    param(

    )

    process {
        #create mount point in staging
        try {
            Write-WimWitchLog -Data 'Creating mount point in staging folder...'
            New-Item -Path $Script:workdir\staging `
                    -Name 'mount' `
                    -ItemType Directory `
                    -ErrorAction Stop
            Write-WimWitchLog -Data 'Staging folder mount point created successfully' -Class Information
        } catch {
            Write-WimWitchLog -data 'Failed to create the staging folder mount point' -Class Error
            Write-WimWitchLog -data $_.Exception.Message -class Error
            return
        }

        #change attribute of boot.wim
        #Change file attribute to normal
        Write-WimWitchLog -Data 'Setting file attribute of boot.wim to Normal' -Class Information
        $attrib = Get-Item $Script:workdir\staging\media\sources\boot.wim
        $attrib.Attributes = 'Normal'

        $BootImages = Get-WindowsImage -ImagePath $Script:workdir\staging\media\sources\boot.wim
        Foreach ($BootImage in $BootImages) {
            #Mount the PE Image
            try {
                $text = 'Mounting PE image number ' + $BootImage.ImageIndex
                Write-WimWitchLog -data $text -Class Information
                Mount-WindowsImage `
                    -ImagePath $Script:workdir\staging\media\sources\boot.wim `
                    -Path $Script:workdir\staging\mount `
                    -Index $BootImage.ImageIndex `
                    -ErrorAction Stop
            } catch {
                Write-WimWitchLog -Data 'Could not mount the boot.wim' -Class Error
                Write-WimWitchLog -data $_.Exception.Message -class Error
                return
            }

            Write-WimWitchLog -data 'Applying SSU Update' -Class Information
            Deploy-WWUpdate -class 'PESSU'
            Write-WimWitchLog -data 'Applying LCU Update' -Class Information
            Deploy-WWUpdate -class 'PELCU'

            #Dismount the PE Image
            try {
                Write-WimWitchLog -data 'Dismounting Windows PE image...' -Class Information
                Dismount-WindowsImage -Path $Script:workdir\staging\mount -Save -ErrorAction Stop
            } catch {
                Write-WimWitchLog -data 'Could not dismount the winpe image.' -Class Error
                Write-WimWitchLog -data $_.Exception.Message -class Error
            }

            #Export the WinPE Image
            Try {
                Write-WimWitchLog -data 'Exporting WinPE image index...' -Class Information
                Export-WindowsImage `
                    -SourceImagePath $Script:workdir\staging\media\sources\boot.wim `
                    -SourceIndex $BootImage.ImageIndex `
                    -DestinationImagePath $Script:workdir\staging\tempboot.wim `
                    -ErrorAction Stop
            } catch {
                Write-WimWitchLog -Data 'Failed to export WinPE image' -Class Error
                Write-WimWitchLog -data $_.Exception.Message -class Error
            }
        }

        #Overwrite the stock boot.wim file with the updated one
        try {
            Write-WimWitchLog -Data 'Overwriting boot.wim with updated and optimized version...' -Class Information
            Move-Item -Path $Script:workdir\staging\tempboot.wim -Destination $Script:workdir\staging\media\sources\boot.wim -Force -ErrorAction Stop
            Write-WimWitchLog -Data 'Boot.WIM updated successfully' -Class Information
        } catch {
            Write-WimWitchLog -Data 'Could not copy the updated boot.wim' -Class Error
            Write-WimWitchLog -data $_.Exception.Message -class Error
        }
    }
}




