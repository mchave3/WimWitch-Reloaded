<#
.SYNOPSIS
    Install prerequisites for Windows 10 20H2 and later versions.

.DESCRIPTION
    This function downloads and installs the necessary prerequisites for
    Windows 10 version 20H2 and later versions during the image update process.

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
    param(

    )

    process {
        $KB_URI = 'http://download.windowsupdate.com/c/msdownload/update/software/secu/2021/05/windows10.0-kb5003173-x64_375062f9d88a5d9d11c5b99673792fdce8079e09.cab'
        $executable = "$env:windir\system32\expand.exe"
        $mountdir = $WPFMISMountTextBox.Text

        Update-Log -data 'Checking for SSU prerequisite...' -Class Information

        try {
            $prereqdir = $global:workdir + '\staging\prereq'
            if ((Test-Path -Path $prereqdir) -eq $false) {
                Update-Log -data 'Creating prerequisite folder...' -Class Information
                New-Item -Path $prereqdir -ItemType Directory -Force | Out-Null
            }

            $prereqfile = $prereqdir + '\' + ($KB_URI -split '/')[-1]
            if ((Test-Path -Path $prereqfile) -eq $false) {
                Update-Log -data 'Downloading prerequisite...' -Class Information
                Invoke-WebRequest -Uri $KB_URI -OutFile $prereqfile
            }

            Update-Log -data 'Extracting prerequisite...' -Class Information
            $arguments = @(
                "-F:*AMD64.cab"
                $prereqfile
                $prereqdir
            )
            Start-Process -FilePath $executable -ArgumentList $arguments -Wait

            $cabs = Get-ChildItem -Path $prereqdir -Filter *AMD64.cab
            foreach ($cab in $cabs) {
                Update-Log -data "Installing prerequisite: $($cab.Name)..." -Class Information
                Add-WindowsPackage -PackagePath $cab.FullName -Path $mountdir | Out-Null
            }

            Update-Log -data 'Prerequisites installed successfully' -Class Information
        }
        catch {
            Update-Log -data 'Failed to install prerequisites' -Class Error
            Update-Log -data $_.Exception.Message -Class Error
        }
    }
}
