<#
.SYNOPSIS
    Deploy the latest Cumulative Update (LCU) for Windows 10 and Windows 11.

.DESCRIPTION
    This function is used to deploy the latest Cumulative Update (LCU) for Windows 10 and Windows 11.

.NOTES
    Name:        Deploy-LCU.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-27
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Deploy-LCU -packagepath "C:\Temp\LCU\KB5001234"
    Deploy-LCU -packagepath "C:\Temp\LCU\KB5001234" -demomode $true
#>
function Deploy-LCU {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$packagepath,
        [Parameter(Mandatory = $false)]
        [bool]$demomode
    )

    process {
        $osver = Get-WindowsType

        if ($osver -eq 'Windows 10') {
            $executable = "$env:windir\system32\expand.exe"
            $filename = (Get-ChildItem $packagepath).name
            Update-Log -Data 'Extracting LCU Package content to staging folder...' -Class Information
            Start-Process $executable -args @("`"$packagepath\$filename`"", '/f:*.CAB', "`"$global:workdir\staging`"") -Wait -ErrorAction Stop
            $cabs = (Get-Item $global:workdir\staging\*.cab)
    
            #MMSMOA2022
            Update-Log -data 'Applying SSU...' -class information
            foreach ($cab in $cabs) {
    
                if ($cab -like '*SSU*') {
                    Update-Log -data $cab -class Information
    
                    if ($demomode -eq $false) { Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $cab -ErrorAction stop | Out-Null }
                    else {
                        $string = 'Demo mode active - Not applying ' + $cab
                        Update-Log -data $string -Class Warning
                    }
                }
    
            }
    
            Update-Log -data 'Applying LCU...' -class information
            foreach ($cab in $cabs) {
                if ($cab -notlike '*SSU*') {
                    Update-Log -data $cab -class information
                    if ($demomode -eq $false) { Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $cab -ErrorAction stop | Out-Null }
                    else {
                        $string = 'Demo mode active - Not applying ' + $cab
                        Update-Log -data $string -Class Warning
                    }
                }
            }
        }
        if ($osver -eq 'Windows 11') {
            # Copy file to staging
            Update-Log -data 'Copying LCU file to staging folder...' -class information
            $filename = (Get-ChildItem -Path $packagepath -Name)
            Copy-Item -Path $packagepath\$filename -Destination $global:workdir\staging -Force
    
            Update-Log -data 'Changing file extension type from CAB to MSU...' -class information
            $basename = (Get-Item -Path $global:workdir\staging\$filename).BaseName
            $newname = $basename + '.msu'
            Rename-Item -Path $global:workdir\staging\$filename -NewName $newname
    
            Update-Log -data 'Applying LCU...' -class information
            Update-Log -data $global:workdir\staging\$newname -class information
            $updatename = (Get-Item -Path $packagepath).name
            Update-Log -data $updatename -Class Information
    
            try {
                if ($demomode -eq $false) {
                    Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $global:workdir\staging\$newname -ErrorAction Stop | Out-Null
                } else {
                    $string = 'Demo mode active - Not applying ' + $updatename
                    Update-Log -data $string -Class Warning
                }
            } catch {
                Update-Log -data 'Failed to apply update' -class Warning
                Update-Log -data $_.Exception.Message -class Warning
            }
        }
    }
}
