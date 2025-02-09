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
            Write-WWLog -Data 'Extracting LCU Package content to staging folder...' -Class Information
            Start-Process $executable -args @("`"$packagepath\$filename`"", '/f:*.CAB', "`"$Script:workdir\staging`"") -Wait -ErrorAction Stop
            $cabs = (Get-Item $Script:workdir\staging\*.cab)
            #MMSMOA2022
            Write-WWLog -data 'Applying SSU...' -class information
            foreach ($cab in $cabs) {
                if ($cab -like '*SSU*') {
                    Write-WWLog -data $cab -class Information
                    if ($demomode -eq $false) { Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $cab -ErrorAction stop | Out-Null }
                    else {
                        $string = 'Demo mode active - Not applying ' + $cab
                        Write-WWLog -data $string -Class Warning
                    }
                }
            }
            Write-WWLog -data 'Applying LCU...' -class information
            foreach ($cab in $cabs) {
                if ($cab -notlike '*SSU*') {
                    Write-WWLog -data $cab -class information
                    if ($demomode -eq $false) { Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $cab -ErrorAction stop | Out-Null }
                    else {
                        $string = 'Demo mode active - Not applying ' + $cab
                        Write-WWLog -data $string -Class Warning
                    }
                }
            }
        }
        if ($osver -eq 'Windows 11') {
            # Copy file to staging
            Write-WWLog -data 'Copying LCU file to staging folder...' -class information
            $filename = (Get-ChildItem -Path $packagepath -Name)
            Copy-Item -Path $packagepath\$filename -Destination $Script:workdir\staging -Force
            Write-WWLog -data 'Changing file extension type from CAB to MSU...' -class information
            $basename = (Get-Item -Path $Script:workdir\staging\$filename).BaseName
            $newname = $basename + '.msu'
            Rename-Item -Path $Script:workdir\staging\$filename -NewName $newname
            Write-WWLog -data 'Applying LCU...' -class information
            Write-WWLog -data $Script:workdir\staging\$newname -class information
            $updatename = (Get-Item -Path $packagepath).name
            Write-WWLog -data $updatename -Class Information
            try {
                if ($demomode -eq $false) {
                    Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $Script:workdir\staging\$newname -ErrorAction Stop | Out-Null
                } else {
                    $string = 'Demo mode active - Not applying ' + $updatename
                    Write-WWLog -data $string -Class Warning
                }
            } catch {
                Write-WWLog -data 'Failed to apply update' -class Warning
                Write-WWLog -data $_.Exception.Message -class Warning
            }
        }
    }
}
