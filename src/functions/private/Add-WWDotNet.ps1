<#
.SYNOPSIS
    Inject .Net 3.5 binaries into the WIM file.

.DESCRIPTION
    This function is used to inject .Net 3.5 binaries into the WIM file.

.NOTES
    Name:        Add-WWDotNet.ps1
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
    Add-WWDotNet
#>
function Add-WWDotNet {
    [CmdletBinding()]
    param(

    )

    process {
        $buildnum = Get-WWWindowsVersionNumber
        $OSType = Get-WWWindowsType

        #fix the build number 21h

        if ($OSType -eq 'Windows 10') { $DotNetFiles = "$Script:workdir\imports\DotNet\$buildnum" }
        if (($OSType -eq 'Windows 11') -or ($OSType -eq 'Windows Server')) { $DotNetFiles = "$Script:workdir\imports\DotNet\$OSType\$buildnum" }


        try {
            $text = 'Injecting .Net 3.5 binaries from ' + $DotNetFiles
            Write-WimWitchLog -Data $text -Class Information
            Add-WindowsPackage -PackagePath $DotNetFiles -Path $WPFMISMountTextBox.Text -ErrorAction Continue | Out-Null
        } catch {
            Write-WimWitchLog -Data "Couldn't inject .Net Binaries" -Class Warning
            Write-WimWitchLog -data $_.Exception.Message -Class Error
            return
        }
        Write-WimWitchLog -Data '.Net 3.5 injection complete' -Class Information
    }
}


