<#
.SYNOPSIS
    Apply updates to the mounted image.

.DESCRIPTION
    Function to apply updates to the mounted image.

.NOTES
    Name:        Deploy-Updates.ps1
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
    Deploy-Updates -class "SSU"
    Deploy-Updates -class "LCU"
    Deploy-Updates -class "AdobeSU"
    Deploy-Updates -class "DotNet"
    Deploy-Updates -class "DotNetCU"
#>
function Deploy-Updates {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$class
    )

    process {
        if ($class -eq 'AdobeSU' -and 
            $WPFSourceWIMImgDesTextBox.text -like 'Windows Server 20*' -and 
            $WPFSourceWIMImgDesTextBox.text -notlike '*(Desktop Experience)') {
            Update-Log -Data 'Skipping Adobe updates for Server Core build' -Class Information
            return
        }
    
        $OS = Get-WindowsType
        $buildnum = Get-WinVersionNumber
    
        if ($buildnum -eq '2009') { $buildnum = '20H2' }
    
        If (($WPFSourceWimVerTextBox.text -like '10.0.18362.*') -and (($class -ne 'Dynamic') -and ($class -notlike 'PE*'))) {
            $mountdir = $WPFMISMountTextBox.Text
            reg LOAD HKLM\OFFLINE $mountdir\Windows\System32\Config\SOFTWARE | Out-Null
            $regvalues = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\OFFLINE\Microsoft\Windows NT\CurrentVersion\' )
            $buildnum = $regvalues.ReleaseId
            reg UNLOAD HKLM\OFFLINE | Out-Null
        }
    
        If (($WPFSourceWimVerTextBox.text -like '10.0.18362.*') -and (($class -eq 'Dynamic') -or ($class -like 'PE*'))) {
            $windowsver = Get-WindowsImage -ImagePath ($global:workdir + '\staging\' + $WPFMISWimNameTextBox.text) -Index 1
            $Vardate = (Get-Date -Year 2019 -Month 10 -Day 01)
            if ($windowsver.CreatedTime -gt $vardate) { $buildnum = 1909 }
            else
            { $buildnum = 1903 }
        }
    
        if ($class -eq 'PESSU') {
            $IsPE = $true
            $class = 'SSU'
        }
    
        if ($class -eq 'PELCU') {
            $IsPE = $true
            $class = 'LCU'
        }
    
        $path = $global:workdir + '\updates\' + $OS + '\' + $buildnum + '\' + $class + '\'
    
    
        if ((Test-Path $path) -eq $False) {
            Update-Log -data "$path does not exist. There are no updates of this class to apply" -class Warning
            return
        }
    
        $Children = Get-ChildItem -Path $path
        foreach ($Child in $Children) {
            $compound = $Child.fullname
            Update-Log -Data "Applying $Child" -Class Information
            try {
                if ($class -eq 'Dynamic') {
                    #Update-Log -data "Applying Dynamic to media" -Class Information
                    $mediafolder = $global:workdir + '\staging\media\sources'
                    $DynUpdates = (Get-ChildItem -Path $compound -Name)
                    foreach ($DynUpdate in $DynUpdates) {
    
                        $text = $compound + '\' + $DynUpdate
                        $expandArgs = @("`"$text`"", '-F:*', "`"$mediafolder`"")
                        Start-Process -FilePath c:\windows\system32\expand.exe -ArgumentList $expandArgs -Wait
                    }
                } elseif ($IsPE -eq $true) { Add-WindowsPackage -Path ($global:workdir + '\staging\mount') -PackagePath $compound -ErrorAction stop | Out-Null }
                else {
                    if ($class -eq 'LCU') {
                        if (($os -eq 'Windows 10') -and (($buildnum -eq '2004') -or ($buildnum -eq '2009') -or ($buildnum -eq '20H2') -or ($buildnum -eq '21H1') -or ($buildnum -eq '21H2') -or ($buildnum -eq '22H2'))) {
                            Update-Log -data 'Processing the LCU package to retrieve SSU...' -class information
                            Deploy-LCU -packagepath $compound
                        } elseif ($os -eq 'Windows 11') {
                            Update-Log -data 'Windows 11 required LCU modification started...' -Class Information
                            Deploy-LCU -packagepath $compound
                        }
    
                        else {
    
                            Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $compound -ErrorAction stop | Out-Null
                        }
                    }
    
                    else { Add-WindowsPackage -Path $WPFMISMountTextBox.Text -PackagePath $compound -ErrorAction stop | Out-Null }
    
                }
            } catch {
                Update-Log -data 'Failed to apply update' -class Warning
                Update-Log -data $_.Exception.Message -class Warning
            }
        }
    }
}
