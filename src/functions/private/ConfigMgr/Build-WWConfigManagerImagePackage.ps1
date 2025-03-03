<#
.SYNOPSIS
    Creates a new ConfigMgr image package.

.DESCRIPTION
    This function creates a new ConfigMgr image package based on the selected WIM file.

.NOTES
    Name:        Build-WWConfigManagerImagePackage.ps1
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
    Build-WWConfigManagerImagePackage
#>
function Build-WWConfigManagerImagePackage {
    [CmdletBinding()]
    param(

    )

    process {
        #set-ConfigMgrConnection
        Set-Location $CMDrive
        $Path = $WPFMISWimFolderTextBox.text + '\' + $WPFMISWimNameTextBox.text

        try {
            New-CMOperatingSystemImage -Name $WPFCMTBImageName.text -Path $Path -ErrorAction Stop
            Write-WimWitchLog -data 'Image was created. Check ConfigMgr console' -Class Information
        } catch {
            Write-WimWitchLog -data 'Failed to create the image' -Class Error
            Write-WimWitchLog -data $_.Exception.Message -Class Error
        }

        $PackageID = (Get-CMOperatingSystemImage -Name $WPFCMTBImageName.text).PackageID
        Write-WimWitchLog -Data "The Package ID of the new image is $PackageID" -Class Information

        Update-WWConfigManagerImageProperty -PackageID $PackageID

        Write-WimWitchLog -Data 'Retriveing Distribution Point information...' -Class Information
        $DPs = $WPFCMLBDPs.Items

        foreach ($DP in $DPs) {
            # Hello! This line was written on 3/3/2020.
            $DP = $DP -replace '\\', ''

            Write-WimWitchLog -Data 'Distributiong image package content...' -Class Information
            if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Points') {
                Start-CMContentDistribution -OperatingSystemImageId $PackageID -DistributionPointName $DP
            }
            if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Point Groups') {
                Start-CMContentDistribution -OperatingSystemImageId $PackageID -DistributionPointGroupName $DP
            }

            Write-WimWitchLog -Data 'Content has been distributed.' -Class Information
        }

        Save-WWSetting -CM $PackageID
        Set-Location $script:workingDirectory
    }
}

