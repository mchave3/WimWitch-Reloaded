<#
.SYNOPSIS
    Apply registry files to the mounted image.

.DESCRIPTION
    This function applies registry modifications to the mounted Windows image by loading offline registry hives and importing registry files.

.NOTES
    Name:        Install-RegistryFile.ps1
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
    Install-RegistryFile
#>
function Install-RegistryFile {
    [CmdletBinding()]
    param(

    )

    process {
        #mount offline hives
        Update-Log -Data 'Mounting the offline registry hives...' -Class Information

        try {
            $Path = $WPFMISMountTextBox.text + '\Users\Default\NTUser.dat'
            Update-Log -Data $path -Class Information
            Invoke-Command { reg load HKLM\OfflineDefaultUser $Path } -ErrorAction Stop | Out-Null

            $Path = $WPFMISMountTextBox.text + '\Windows\System32\Config\DEFAULT'
            Update-Log -Data $path -Class Information
            Invoke-Command { reg load HKLM\OfflineDefault $Path } -ErrorAction Stop | Out-Null

            $Path = $WPFMISMountTextBox.text + '\Windows\System32\Config\SOFTWARE'
            Update-Log -Data $path -Class Information
            Invoke-Command { reg load HKLM\OfflineSoftware $Path } -ErrorAction Stop | Out-Null

            $Path = $WPFMISMountTextBox.text + '\Windows\System32\Config\SYSTEM'
            Update-Log -Data $path -Class Information
            Invoke-Command { reg load HKLM\OfflineSystem $Path } -ErrorAction Stop | Out-Null
        } catch {
            Update-Log -Data "Failed to mount $Path" -Class Error
            Update-Log -data $_.Exception.Message -Class Error
        }

        #get reg files from list box
        $RegFiles = $WPFCustomLBRegistry.items

        #For Each to process Reg Files and Apply
        Update-Log -Data 'Processing Reg Files...' -Class Information
        foreach ($RegFile in $Regfiles) {

            Update-Log -Data $RegFile -Class Information
            #write-host $RegFile

            Try {
                $Destination = $global:workdir + '\staging\'
                Update-Log -Data 'Copying file to staging folder...' -Class Information
                Copy-Item -Path $regfile -Destination $Destination -Force -ErrorAction Stop  #Copy Source Registry File to staging
            } Catch {
                Update-Log -Data "Couldn't copy reg file" -Class Error
                Update-Log -data $_.Exception.Message -Class Error
            }

            $regtemp = Split-Path $regfile -Leaf #get file name
            $regpath = $global:workdir + '\staging' + '\' + $regtemp

            # Write-Host $regpath
            Try {
                Update-Log -Data 'Parsing reg file...'
                ((Get-Content -Path $regpath -Raw) -replace 'HKEY_CURRENT_USER', 
                    'HKEY_LOCAL_MACHINE\OfflineDefaultUser') | Set-Content -Path $regpath -ErrorAction Stop
                ((Get-Content -Path $regpath -Raw) -replace 'HKEY_LOCAL_MACHINE\\SOFTWARE', 
                    'HKEY_LOCAL_MACHINE\OfflineSoftware') | Set-Content -Path $regpath -ErrorAction Stop
                ((Get-Content -Path $regpath -Raw) -replace 'HKEY_LOCAL_MACHINE\\SYSTEM', 
                    'HKEY_LOCAL_MACHINE\OfflineSystem') | Set-Content -Path $regpath -ErrorAction Stop
                ((Get-Content -Path $regpath -Raw) -replace 'HKEY_USERS\\.DEFAULT', 
                    'HKEY_LOCAL_MACHINE\OfflineDefault') | Set-Content -Path $regpath -ErrorAction Stop
            } Catch {
                Update-log -Data "Couldn't read or update reg file $regpath" -Class Error
                Update-Log -data $_.Exception.Message -Class Error
            }

            Update-Log -Data 'Reg file has been parsed' -Class Information

            #import the registry file
            Try {
                Update-Log -Data 'Importing registry file into mounted wim' -Class Information
                Start-Process reg -ArgumentList ('import', "`"$RegPath`"") -Wait -WindowStyle Hidden -ErrorAction stop
                Update-Log -Data 'Import successful' -Class Information
            } Catch {
                Update-Log -Data "Couldn't import $Regpath" -Class Error
                Update-Log -data $_.Exception.Message -Class Error
            }
        }

        #dismount offline hives
        try {
            Update-Log -Data 'Dismounting registry...' -Class Information
            Invoke-Command { reg unload HKLM\OfflineDefaultUser } -ErrorAction Stop | Out-Null
            Invoke-Command { reg unload HKLM\OfflineDefault } -ErrorAction Stop | Out-Null
            Invoke-Command { reg unload HKLM\OfflineSoftware } -ErrorAction Stop | Out-Null
            Invoke-Command { reg unload HKLM\OfflineSystem } -ErrorAction Stop | Out-Null
            Update-Log -Data 'Dismount complete' -Class Information
        } catch {
            Update-Log -Data "Couldn't dismount the registry hives" -Class Error
            Update-Log -Data 'This will prevent the Windows image from properly dismounting' -Class Error
            Update-Log -data $_.Exception.Message -Class Error
        }
    }
}
