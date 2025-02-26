<#
.SYNOPSIS
    Import an ISO file into WimWitch.

.DESCRIPTION
    This function is used to import an ISO file into WimWitch.
    It will mount the ISO, check for the install.wim or install.esd file, and then copy the file to the staging folder.
    If the user has selected to import the WIM file, it will then rename the file to the user's desired name and move it
    to the imports folder. If the user has selected to import the .Net binaries, it will copy the .Net binaries to the
    imports folder. If the user has selected to import the ISO files, it will copy the boot, efi, sources, and support
    folders, as well as the autorun.inf, bootmgr, bootmgr.efi, and setup.exe files to the imports folder.

.NOTES
    Name:        Import-WWWindowsISO.ps1
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
    Import-WWWindowsISO
#>
function Import-WWWindowsISO {
    [CmdletBinding()]
    param(

    )

    process {
        $newname = $WPFImportNewNameTextBox.Text
        $file = $WPFImportISOTextBox.Text

        #Check to see if destination WIM already exists

        if ($WPFImportWIMCheckBox.IsChecked -eq $true) {
            Write-WimWitchLog -data 'Checking to see if the destination WIM file exists...' -Class Information
            #check to see if the new name for the imported WIM is valid
            if (($WPFImportNewNameTextBox.Text -eq '') -or
                ($WPFImportNewNameTextBox.Text -eq 'Name for the imported WIM')) {
                Write-WimWitchLog -Data 'Enter a valid file name for the imported WIM and then try again' -Class Error
                return
            }

            If ($newname -notlike '*.wim') {
                $newname = $newname + '.wim'
                Write-WimWitchLog -Data 'Appending new file name with an extension' -Class Information
            }

            if ((Test-Path -Path $script:workingDirectory\Imports\WIM\$newname) -eq $true) {
                Write-WimWitchLog -Data 'Destination WIM name already exists. Provide a new name and try again.' -Class Error
                return
            } else {
                Write-WimWitchLog -Data 'Name appears to be good. Continuing...' -Class Information
            }
        }

        #Mount ISO
        Write-WimWitchLog -Data 'Mounting ISO...' -Class Information
        try {
            $isomount = Mount-DiskImage -ImagePath $file -PassThru -NoDriveLetter -ErrorAction Stop
            $iso = $isomount.devicepath

        } catch {
            Write-WimWitchLog -Data 'Could not mount the ISO! Stopping actions...' -Class Error
            return
        }
        if (-not(Test-Path -Path (Join-Path $iso '\sources\'))) {
            Write-WimWitchLog -Data 'Could not access the mounted ISO! Stopping actions...' -Class Error
            try {
                Invoke-WWRemoveISOMount -inputObject $isomount
            } catch {
                Write-WimWitchLog -Data 'Attempted to dismount iso - might have failed...' -Class Warning
            }
            return
        }
        Write-WimWitchLog -Data "$isomount" -Class Information
        #Testing for ESD or WIM format
        if (Test-Path -Path (Join-Path $iso '\sources\install.wim')) {
            $installWimFound = $true
        } elseif (Test-Path -Path (Join-Path $iso '\sources\install.esd')) {
            $installEsdFound = $true
            Write-WimWitchLog -data 'Found ESD type installer - attempting to convert to WIM.' -Class Information
        } else {
            Write-WimWitchLog -data 'Error accessing install.wim or install.esd! Breaking' -Class Warning
            try {
                Invoke-WWRemoveISOMount -inputObject $isomount
            } catch {
                Write-WimWitchLog -Data 'Attempted to dismount iso - might have failed...' -Class Warning
            }
            return
        }

        try {
            if ($installWimFound) {
                $windowsver = Get-WindowsImage -ImagePath (Join-Path $iso '\sources\install.wim') `
                    -Index 1 -ErrorAction Stop
            } elseif ($installEsdFound) {
                $windowsver = Get-WindowsImage -ImagePath (Join-Path $iso '\sources\install.esd') `
                    -Index 1 -ErrorAction Stop
            }

            #####################
            #Right here
            $version = Get-WWWindowsReleaseFromWim -wimversion $windowsver.version

            if ($version -eq 2004) {
                $script:Win10VerDet = $null
                Invoke-WW19041Select
                if ($null -eq $script:Win10VerDet) {
                    Write-Host 'cancelling'
                    return
                } else {
                    $version = $script:Win10VerDet
                    $script:Win10VerDet = $null
                }

                if ($version -eq '20H2') { $version = '2009' }
                Write-Host $version
            }

        } catch {
            Write-WimWitchLog -data 'install.wim could not be found or accessed! Skipping...' -Class Warning
            $installWimFound = $false
        }

        #Copy out WIM file
        #if (($type -eq "all") -or ($type -eq "wim")) {
        if (($WPFImportWIMCheckBox.IsChecked -eq $true) -and (($installWimFound) -or ($installEsdFound))) {
            #Copy out the WIM file from the selected ISO
            try {
                Write-WimWitchLog -data 'Purging staging folder...' -Class Information
                Remove-Item -Path $script:workingDirectory\staging\*.* -Force
                Write-WimWitchLog -data 'Purge complete.' -Class Information
                if ($installWimFound) {
                    Write-WimWitchLog -Data 'Copying WIM file to the staging folder...' -Class Information
                    Copy-Item -Path $iso\sources\install.wim -Destination $script:workingDirectory\staging -Force -ErrorAction Stop -PassThru
                }
            } catch {
                Write-WimWitchLog -data "Couldn't copy from the source" -Class Error
                Invoke-WWRemoveISOMount -inputObject $isomount
                return
            }
            #convert the ESD file to WIM
            if ($installEsdFound) {
                $sourceEsdFile = (Join-Path $iso '\sources\install.esd')
                Write-WimWitchLog -Data 'Assessing install.esd file...' -Class Information
                $indexesFound = Get-WindowsImage -ImagePath $sourceEsdFile
                Write-WimWitchLog -Data "$($indexesFound.Count) indexes found for conversion..." -Class Information
                foreach ($index in $indexesFound) {
                    try {
                        Write-WimWitchLog -Data "Converting index $($index.ImageIndex) - $($index.ImageName)" -Class Information
                        Export-WindowsImage -SourceImagePath $sourceEsdFile -SourceIndex $($index.ImageIndex) `
                            -DestinationImagePath (Join-Path $script:workingDirectory '\staging\install.wim') -CompressionType fast -ErrorAction Stop
                    } catch {
                        Write-WimWitchLog -Data "Converting index $($index.ImageIndex) failed - skipping..." -Class Error
                        continue
                    }
                }
            }
            #Change file attribute to normal
            Write-WimWitchLog -Data 'Setting file attribute of install.wim to Normal' -Class Information
            $attrib = Get-Item $script:workingDirectory\staging\install.wim
            $attrib.Attributes = 'Normal'

            #Rename install.wim to the new name
            try {
                $text = 'Renaming install.wim to ' + $newname
                Write-WimWitchLog -Data $text -Class Information
                Rename-Item -Path $script:workingDirectory\Staging\install.wim -NewName $newname -ErrorAction Stop
            } catch {
                Write-WimWitchLog -data "Couldn't rename the copied file. Most likely a weird permissions issues." -Class Error
                Invoke-WWRemoveISOMount -inputObject $isomount
                return
            }
            #Move the imported WIM to the imports folder
            try {
                Write-WimWitchLog -data "Moving $newname to imports folder..." -Class Information
                Move-Item -Path $script:workingDirectory\Staging\$newname -Destination $script:workingDirectory\Imports\WIM -ErrorAction Stop
            } catch {
                Write-WimWitchLog -Data "Couldn't move the new WIM to the staging folder." -Class Error
                Invoke-WWRemoveISOMount -inputObject $isomount
                return
            }
            Write-WimWitchLog -data 'WIM importation complete' -Class Information
        }

        #Copy DotNet binaries

        if ($WPFImportDotNetCheckBox.IsChecked -eq $true) {
            If (($windowsver.imagename -like '*Windows 10*') -or
                (($windowsver.imagename -like '*server') -and ($windowsver.version -lt 10.0.20248.0))) {
                $Path = "$script:workingDirectory\Imports\DotNet\$version"
            }
            If (($windowsver.Imagename -like '*server*') -and
                ($windowsver.version -gt 10.0.20348.0)) {
                $Path = "$script:workingDirectory\Imports\Dotnet\Windows Server\$version"
            }
            If ($windowsver.imagename -like '*Windows 11*') {
                $Path = "$script:workingDirectory\Imports\Dotnet\Windows 11\$version"
            }
            if ((Test-Path -Path $Path) -eq $false) {
                try {
                    Write-WimWitchLog -Data 'Creating folders...' -Class Warning
                    New-Item -Path (Split-Path -Path $path -Parent) -Name $version -ItemType Directory -ErrorAction stop | Out-Null
                } catch {
                    Write-WimWitchLog -Data "Couldn't creating new folder in DotNet imports folder" -Class Error
                    return
                }
            }
            try {
                Write-WimWitchLog -Data 'Copying .Net binaries...' -Class Information
                Copy-Item -Path $iso\sources\sxs\*netfx3* -Destination $path -Force -ErrorAction Stop
            } catch {
                Write-WimWitchLog -Data "Couldn't copy the .Net binaries" -Class Error
                return
            }
        }
        #Copy out ISO files
        if ($WPFImportISOCheckBox.IsChecked -eq $true) {
            #Determine if is Windows 10 or Windows Server
            Write-WimWitchLog -Data 'Importing ISO/Upgrade Package files...' -Class Information
            if ($windowsver.ImageName -like 'Windows 10*') { $OS = 'Windows 10' }
            if ($windowsver.ImageName -like 'Windows 11*') { $OS = 'Windows 11' }
            if ($windowsver.ImageName -like '*Server*') { $OS = 'Windows Server' }
            Write-WimWitchLog -Data "$OS detected" -Class Information
            if ((Test-Path -Path $script:workingDirectory\imports\iso\$OS\$Version) -eq $false) {
                Write-WimWitchLog -Data 'Path does not exist. Creating...' -Class Information
                New-Item -Path $script:workingDirectory\imports\iso\$OS\ -Name $version -ItemType Directory
            }

            Write-WimWitchLog -Data 'Copying boot folder...' -Class Information
            Copy-Item -Path $iso\boot\ -Destination $script:workingDirectory\imports\iso\$OS\$Version\boot -Recurse -Force #-Exclude install.wim

            Write-WimWitchLog -Data 'Copying efi folder...' -Class Information
            Copy-Item -Path $iso\efi\ -Destination $script:workingDirectory\imports\iso\$OS\$Version\efi -Recurse -Force #-Exclude install.wim

            Write-WimWitchLog -Data 'Copying sources folder...' -Class Information
            Copy-Item -Path $iso\sources\ -Destination $script:workingDirectory\imports\iso\$OS\$Version\sources -Recurse -Force -Exclude install.wim

            Write-WimWitchLog -Data 'Copying support folder...' -Class Information
            Copy-Item -Path $iso\support\ -Destination $script:workingDirectory\imports\iso\$OS\$Version\support -Recurse -Force #-Exclude install.wim

            Write-WimWitchLog -Data 'Copying files in root folder...' -Class Information
            Copy-Item $iso\autorun.inf -Destination $script:workingDirectory\imports\iso\$OS\$Version\ -Force
            Copy-Item $iso\bootmgr -Destination $script:workingDirectory\imports\iso\$OS\$Version\ -Force
            Copy-Item $iso\bootmgr.efi -Destination $script:workingDirectory\imports\iso\$OS\$Version\ -Force
            Copy-Item $iso\setup.exe -Destination $script:workingDirectory\imports\iso\$OS\$Version\ -Force
        }
        #Dismount and finish
        try {
            Write-WimWitchLog -Data 'Dismount!' -Class Information
            Invoke-WWRemoveISOMount -inputObject $isomount
        } catch {
            Write-WimWitchLog -Data "Couldn't dismount the ISO. WIM Witch uses a file mount option that does not" -Class Error
            Write-WimWitchLog -Data 'provision a drive letter. Use the Dismount-DiskImage command to manaully dismount.' `
                -Class Error
        }
        Write-WimWitchLog -data 'Importing complete' -class Information
    }
}




