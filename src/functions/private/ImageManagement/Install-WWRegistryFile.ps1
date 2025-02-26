<#
.SYNOPSIS
    Apply registry files to the mounted image.

.DESCRIPTION
    This function applies registry modifications to the mounted Windows image by loading offline registry hives and importing registry files.

.NOTES
    Name:        Install-WWRegistryFile.ps1
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
    Install-WWRegistryFile
#>
function Install-WWRegistryFile {
    [CmdletBinding()]
    param(

    )

    process {
        #mount offline hives
        Write-WimWitchLog -Data 'Mounting the offline registry hives...' -Class Information

        try {
            $Path = $WPFMISMountTextBox.text + '\Users\Default\NTUser.dat'
            Write-WimWitchLog -Data $path -Class Information
            Invoke-Command { reg load HKLM\OfflineDefaultUser $Path } -ErrorAction Stop | Out-Null

            $Path = $WPFMISMountTextBox.text + '\Windows\System32\Config\DEFAULT'
            Write-WimWitchLog -Data $path -Class Information
            Invoke-Command { reg load HKLM\OfflineDefault $Path } -ErrorAction Stop | Out-Null

            $Path = $WPFMISMountTextBox.text + '\Windows\System32\Config\SOFTWARE'
            Write-WimWitchLog -Data $path -Class Information
            Invoke-Command { reg load HKLM\OfflineSoftware $Path } -ErrorAction Stop | Out-Null

            $Path = $WPFMISMountTextBox.text + '\Windows\System32\Config\SYSTEM'
            Write-WimWitchLog -Data $path -Class Information
            Invoke-Command { reg load HKLM\OfflineSystem $Path } -ErrorAction Stop | Out-Null
        } catch {
            Write-WimWitchLog -Data "Failed to mount $Path" -Class Error
            Write-WimWitchLog -data $_.Exception.Message -Class Error
        }

        #get reg files from list box
        $RegFiles = $WPFCustomLBRegistry.items

        #For Each to process Reg Files and Apply
        Write-WimWitchLog -Data 'Processing Reg Files...' -Class Information
        foreach ($RegFile in $Regfiles) {

            Write-WimWitchLog -Data $RegFile -Class Information
            #write-host $RegFile

            Try {
                $Destination = $script:workingDirectory + '\staging\'
                Write-WimWitchLog -Data 'Copying file to staging folder...' -Class Information
                Copy-Item -Path $regfile -Destination $Destination -Force -ErrorAction Stop  #Copy Source Registry File to staging
            } Catch {
                Write-WimWitchLog -Data "Couldn't copy reg file" -Class Error
                Write-WimWitchLog -data $_.Exception.Message -Class Error
            }

            $regtemp = Split-Path $regfile -Leaf #get file name
            $regpath = $script:workingDirectory + '\staging' + '\' + $regtemp

            # Write-Host $regpath
            Try {
                Write-WimWitchLog -Data 'Parsing reg file...'
                ((Get-Content -Path $regpath -Raw) -replace 'HKEY_CURRENT_USER',
                    'HKEY_LOCAL_MACHINE\OfflineDefaultUser') | Set-Content -Path $regpath -ErrorAction Stop
                ((Get-Content -Path $regpath -Raw) -replace 'HKEY_LOCAL_MACHINE\\SOFTWARE',
                    'HKEY_LOCAL_MACHINE\OfflineSoftware') | Set-Content -Path $regpath -ErrorAction Stop
                ((Get-Content -Path $regpath -Raw) -replace 'HKEY_LOCAL_MACHINE\\SYSTEM',
                    'HKEY_LOCAL_MACHINE\OfflineSystem') | Set-Content -Path $regpath -ErrorAction Stop
                ((Get-Content -Path $regpath -Raw) -replace 'HKEY_USERS\\.DEFAULT',
                    'HKEY_LOCAL_MACHINE\OfflineDefault') | Set-Content -Path $regpath -ErrorAction Stop
            } Catch {
                Write-WimWitchLog -Data "Couldn't read or update reg file $regpath" -Class Error
                Write-WimWitchLog -data $_.Exception.Message -Class Error
            }

            Write-WimWitchLog -Data 'Reg file has been parsed' -Class Information

            #import the registry file
            Try {
                Write-WimWitchLog -Data 'Importing registry file into mounted wim' -Class Information
                Start-Process reg -ArgumentList ('import', "`"$RegPath`"") -Wait -WindowStyle Hidden -ErrorAction stop
                Write-WimWitchLog -Data 'Import successful' -Class Information
            } Catch {
                Write-WimWitchLog -Data "Couldn't import $Regpath" -Class Error
                Write-WimWitchLog -data $_.Exception.Message -Class Error
            }
        }

        #dismount offline hives
        try {
            Write-WimWitchLog -Data 'Dismounting registry...' -Class Information
            Invoke-Command { reg unload HKLM\OfflineDefaultUser } -ErrorAction Stop | Out-Null
            Invoke-Command { reg unload HKLM\OfflineDefault } -ErrorAction Stop | Out-Null
            Invoke-Command { reg unload HKLM\OfflineSoftware } -ErrorAction Stop | Out-Null
            Invoke-Command { reg unload HKLM\OfflineSystem } -ErrorAction Stop | Out-Null
            Write-WimWitchLog -Data 'Dismount complete' -Class Information
        } catch {
            Write-WimWitchLog -Data "Couldn't dismount the registry hives" -Class Error
            Write-WimWitchLog -Data 'This will prevent the Windows image from properly dismounting' -Class Error
            Write-WimWitchLog -data $_.Exception.Message -Class Error
        }
    }
}




