﻿<#
.SYNOPSIS
    Download and apply the required SSU for 2004/20H2 June '21 LCU.

.DESCRIPTION
    This function download and apply the required SSU for 2004/20H2 June '21 LCU.

.NOTES
    Name:        Invoke-2XXXPreReq.ps1
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
    Invoke-2XXXPreReq
#>
function Invoke-2XXXPreReq {
    [CmdletBinding()]
    [OutputType([bool])]
    param(

    )

    process {
        $KB_URI = 'http://download.windowsupdate.com/c/msdownload/update/software/secu/2021/05/' + `
            'windows10.0-kb5003173-x64_375062f9d88a5d9d11c5b99673792fdce8079e09.cab'
        $executable = "$env:windir\system32\expand.exe"
        $mountdir = $WPFMISMountTextBox.Text

        Write-WWLog -data 'Mounting offline registry and validating UBR / Patch level...' -class Information
        reg LOAD HKLM\OFFLINE $mountdir\Windows\System32\Config\SOFTWARE | Out-Null
        $regvalues = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\OFFLINE\Microsoft\Windows NT\CurrentVersion\' )


        Write-WWLog -data 'The UBR (Patch Level) is:' -class Information
        Write-WWLog -data $regvalues.ubr -class information
        reg UNLOAD HKLM\OFFLINE | Out-Null

        if ($null -eq $regvalues.ubr) {
            Write-WWLog -data "Registry key wasn't copied. Can't continue." -class Error
            return $true
        }

        if ($regvalues.UBR -lt '985') {
            Write-WWLog -data 'The image requires an additional required SSU.' -class Information
            Write-WWLog -data 'Checking to see if the required SSU exists...' -class Information
            if ((Test-Path "$Script:workdir\updates\Windows 10\2XXX_prereq\SSU-19041.985-x64.cab") -eq $false) {
                Write-WWLog -data 'The required SSU does not exist. Downloading it now...' -class Information

                try {
                    Invoke-WebRequest -Uri $KB_URI -OutFile "$Script:workdir\staging\extract_me.cab" -ErrorAction stop
                } catch {
                    Write-WWLog -data 'Failed to download the update' -class Error
                    Write-WWLog -data $_.Exception.Message -Class Error
                    return $true
                }

                if ((Test-Path "$Script:workdir\updates\Windows 10\2XXX_prereq") -eq $false) {

                    try {
                        Write-WWLog -data 'The folder for the required SSU does not exist. Creating it now...' -class Information
                        New-Item -Path "$Script:workdir\updates\Windows 10" -Name '2XXX_prereq' `
                            -ItemType Directory -ErrorAction stop | Out-Null
                        Write-WWLog -data 'The folder has been created' -class information
                    } catch {
                        Write-WWLog -data 'Could not create the required folder.' -class error
                        Write-WWLog -data $_.Exception.Message -Class Error
                        return $true
                    }
                }

                try {
                    Write-WWLog -data 'Extracting the SSU from the May 2021 LCU...' -class Information
                    Start-Process $executable -args @(
                        "`"$Script:workdir\staging\extract_me.cab`"",
                        '/f:*SSU*.CAB',
                        "`"$Script:workdir\updates\Windows 10\2XXX_prereq`""
                    ) -Wait -ErrorAction Stop
                    Write-WWLog 'Extraction of SSU was success' -class information
                } catch {
                    Write-WWLog -data "Couldn't extract the SSU from the LCU" -class error
                    Write-WWLog -data $_.Exception.Message -Class Error
                    return $true

                }

                try {
                    Write-WWLog -data 'Deleting the staged LCU file...' -class Information
                    Remove-Item -Path $Script:workdir\staging\extract_me.cab -Force -ErrorAction stop | Out-Null
                    Write-WWLog -data 'The source file for the SSU has been Baleeted!' -Class Information
                } catch {
                    Write-WWLog -data 'Could not delete the source package' -Class Error
                    Write-WWLog -data $_.Exception.Message -Class Error
                    return $true
                }
            } else {
                Write-WWLog -data 'The required SSU exists. No need to download' -Class Information
            }

            try {
                Write-WWLog -data 'Applying the SSU...' -class Information
                Add-WindowsPackage -PackagePath "$Script:workdir\updates\Windows 10\2XXX_prereq" `
                    -Path $WPFMISMountTextBox.Text -ErrorAction Stop | Out-Null
                Write-WWLog -data 'SSU applied successfully' -class Information

            } catch {
                Write-WWLog -data "Couldn't apply the SSU update" -class error
                Write-WWLog -data $_.Exception.Message -Class Error
                return $true
            }
        } else {
            Write-WWLog -Data "Image doesn't require the prereq SSU" -Class Information
        }

        Write-WWLog -data 'SSU remdiation complete' -Class Information
        return $false
    }
}

