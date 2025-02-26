<#
.SYNOPSIS
    Deploy the latest Cumulative Update (LCU) for Windows 10 and Windows 11.

.DESCRIPTION
    This function is used to deploy the latest Cumulative Update (LCU) for Windows 10 and Windows 11.

.NOTES
    Name:        Deploy-WWLatestCumulativeUpdate.ps1
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
    Deploy-WWLatestCumulativeUpdate -packagepath "C:\Temp\LCU\KB5001234"
    Deploy-WWLatestCumulativeUpdate -packagepath "C:\Temp\LCU\KB5001234" -demomode $true
#>
function Deploy-WWLatestCumulativeUpdate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$packagepath,
        [Parameter(Mandatory = $false)]
        [bool]$demomode
    )

    process {
        $osver = Get-WWWindowsType

        if ($osver -eq 'Windows 10') {
            $executable = "$env:windir\system32\expand.exe"
            $filename = (Get-ChildItem $packagepath).name
            Write-WimWitchLog -Data 'Extracting LCU Package content to staging folder...' -Class Information
            Start-Process $executable -args @("`"$packagepath\$filename`"", '/f:*.CAB', "`"$script:workingDirectory\staging`"") -Wait -ErrorAction Stop
            $cabs = (Get-Item $script:workingDirectory\staging\*.cab)
            #MMSMOA2022
            Write-WimWitchLog -data 'Applying SSU...' -class information
            foreach ($cab in $cabs) {
                if ($cab -like '*SSU*') {
                    Write-WimWitchLog -data $cab -class Information
                    if ($demomode -eq $false) { Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $cab -ErrorAction stop | Out-Null }
                    else {
                        $string = 'Demo mode active - Not applying ' + $cab
                        Write-WimWitchLog -data $string -Class Warning
                    }
                }
            }
            Write-WimWitchLog -data 'Applying LCU...' -class information
            foreach ($cab in $cabs) {
                if ($cab -notlike '*SSU*') {
                    Write-WimWitchLog -data $cab -class information
                    if ($demomode -eq $false) { Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $cab -ErrorAction stop | Out-Null }
                    else {
                        $string = 'Demo mode active - Not applying ' + $cab
                        Write-WimWitchLog -data $string -Class Warning
                    }
                }
            }
        }
        if ($osver -eq 'Windows 11') {
            # Copy file to staging
            Write-WimWitchLog -data 'Copying LCU file to staging folder...' -class information
            $filename = (Get-ChildItem -Path $packagepath -Name)
            Copy-Item -Path $packagepath\$filename -Destination $script:workingDirectory\staging -Force
            Write-WimWitchLog -data 'Changing file extension type from CAB to MSU...' -class information
            $basename = (Get-Item -Path $script:workingDirectory\staging\$filename).BaseName
            $newname = $basename + '.msu'
            Rename-Item -Path $script:workingDirectory\staging\$filename -NewName $newname
            Write-WimWitchLog -data 'Applying LCU...' -class information
            Write-WimWitchLog -data $script:workingDirectory\staging\$newname -class information
            $updatename = (Get-Item -Path $packagepath).name
            Write-WimWitchLog -data $updatename -Class Information
            try {
                if ($demomode -eq $false) {
                    Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $script:workingDirectory\staging\$newname -ErrorAction Stop | Out-Null
                } else {
                    $string = 'Demo mode active - Not applying ' + $updatename
                    Write-WimWitchLog -data $string -Class Warning
                }
            } catch {
                Write-WimWitchLog -data 'Failed to apply update' -class Warning
                Write-WimWitchLog -data $_.Exception.Message -class Warning
            }
        }
    }
}

