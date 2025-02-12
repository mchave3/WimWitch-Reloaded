<#
.SYNOPSIS
    Get Windows patches for a specific OS and build

.DESCRIPTION
    This function is used to get OS updates for a specific OS and build.
    It will download SSU, AdobeSU, LCU, .Net, .Net CU, optional and dynamic updates for the specified OS and build.

.NOTES
    Name:        Get-WWWindowsPatch.ps1
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
    Get-WWWindowsPatch -OS 'Windows 10' -build '1909'
#>
function Get-WWWindowsPatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OS,
        [Parameter(Mandatory = $true)]
        [string]$build
    )

    process {
        Write-WimWitchLog -Data "Downloading SSU updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop |
                Where-Object {
                    $_.UpdateOS -eq $OS -and
                    $_.UpdateArch -eq 'x64' -and
                    $_.UpdateBuild -eq $build -and
                    $_.UpdateGroup -eq 'SSU'
                } | Get-DownOSDUpdate -DownloadPath $Script:workdir\updates\$OS\$build\SSU
        } catch {
            Write-WimWitchLog -data 'Failed to download SSU update' -Class Error
            Write-WimWitchLog -data $_.Exception.Message -class Error
        }

        Write-WimWitchLog -Data "Downloading AdobeSU updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop |
                Where-Object {
                    $_.UpdateOS -eq $OS -and
                    $_.UpdateArch -eq 'x64' -and
                    $_.UpdateBuild -eq $build -and
                    $_.UpdateGroup -eq 'AdobeSU'
                } | Get-DownOSDUpdate -DownloadPath $Script:workdir\updates\$OS\$build\AdobeSU
        } catch {
            Write-WimWitchLog -data 'Failed to download AdobeSU update' -Class Error
            Write-WimWitchLog -data $_.Exception.Message -class Error
        }

        Write-WimWitchLog -Data "Downloading LCU updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop |
                Where-Object {
                    $_.UpdateOS -eq $OS -and
                    $_.UpdateArch -eq 'x64' -and
                    $_.UpdateBuild -eq $build -and
                    $_.UpdateGroup -eq 'LCU'
                } | Get-DownOSDUpdate -DownloadPath $Script:workdir\updates\$OS\$build\LCU
        } catch {
            Write-WimWitchLog -data 'Failed to download LCU update' -Class Error
            Write-WimWitchLog -data $_.Exception.Message -class Error
        }
        Write-WimWitchLog -Data "Downloading .Net updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop |
                Where-Object {
                    $_.UpdateOS -eq $OS -and
                    $_.UpdateArch -eq 'x64' -and
                    $_.UpdateBuild -eq $build -and
                    $_.UpdateGroup -eq 'DotNet'
                } | Get-DownOSDUpdate -DownloadPath $Script:workdir\updates\$OS\$build\DotNet
        } catch {
            Write-WimWitchLog -data 'Failed to download .Net update' -Class Error
            Write-WimWitchLog -data $_.Exception.Message -class Error
        }

        Write-WimWitchLog -Data "Downloading .Net CU updates for $OS $build" -Class Information
        try {
            Get-OSDUpdate -ErrorAction Stop |
                Where-Object {
                    $_.UpdateOS -eq $OS -and
                    $_.UpdateArch -eq 'x64' -and
                    $_.UpdateBuild -eq $build -and
                    $_.UpdateGroup -eq 'DotNetCU'
                } | Get-DownOSDUpdate -DownloadPath $Script:workdir\updates\$OS\$build\DotNetCU
        } catch {
            Write-WimWitchLog -data 'Failed to download .Net CU update' -Class Error
            Write-WimWitchLog -data $_.Exception.Message -class Error
        }

        if ($WPFUpdatesCBEnableOptional.IsChecked -eq $True) {
            try {
                Write-WimWitchLog -Data "Downloading optional updates for $OS $build" -Class Information
                Get-OSDUpdate -ErrorAction Stop |
                    Where-Object {
                        $_.UpdateOS -eq $OS -and
                        $_.UpdateArch -eq 'x64' -and
                        $_.UpdateBuild -eq $build -and
                        $_.UpdateGroup -eq 'Optional'
                    } | Get-DownOSDUpdate -DownloadPath $Script:workdir\updates\$OS\$build\Optional
            } catch {
                Write-WimWitchLog -data 'Failed to download optional update' -Class Error
                Write-WimWitchLog -data $_.Exception.Message -class Error
            }
        }

        if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True) {
            try {
                Write-WimWitchLog -Data "Downloading dynamic updates for $OS $build" -Class Information
                Get-OSDUpdate -ErrorAction Stop |
                    Where-Object {
                        $_.UpdateOS -eq $OS -and
                        $_.UpdateArch -eq 'x64' -and
                        $_.UpdateBuild -eq $build -and
                        $_.UpdateGroup -eq 'SetupDU'
                    } | Get-DownOSDUpdate -DownloadPath $Script:workdir\updates\$OS\$build\Dynamic
            } catch {
                Write-WimWitchLog -data 'Failed to download dynamic update' -Class Error
                Write-WimWitchLog -data $_.Exception.Message -class Error
            }
        }

        Write-WimWitchLog -Data "Downloading completed for $OS $build" -Class Information
    }
}




