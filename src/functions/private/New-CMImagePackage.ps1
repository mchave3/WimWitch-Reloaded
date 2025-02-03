<#
.SYNOPSIS
    Creates a new ConfigMgr image package.

.DESCRIPTION
    This function creates a new ConfigMgr image package based on the selected WIM file.

.NOTES
    Name:        New-CMImagePackage.ps1
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
    New-CMImagePackage
#>
function New-CMImagePackage {
    [CmdletBinding()]
    param(

    )

    process {
        #set-ConfigMgrConnection
        Set-Location $CMDrive
        $Path = $WPFMISWimFolderTextBox.text + '\' + $WPFMISWimNameTextBox.text

        try {
            New-CMOperatingSystemImage -Name $WPFCMTBImageName.text -Path $Path -ErrorAction Stop
            Update-Log -data 'Image was created. Check ConfigMgr console' -Class Information
        } catch {
            Update-Log -data 'Failed to create the image' -Class Error
            Update-Log -data $_.Exception.Message -Class Error
        }

        $PackageID = (Get-CMOperatingSystemImage -Name $WPFCMTBImageName.text).PackageID
        Update-Log -Data "The Package ID of the new image is $PackageID" -Class Information

        Set-ImageProperties -PackageID $PackageID

        Update-Log -Data 'Retriveing Distribution Point information...' -Class Information
        $DPs = $WPFCMLBDPs.Items

        foreach ($DP in $DPs) {
            # Hello! This line was written on 3/3/2020.
            $DP = $DP -replace '\\', ''

            Update-Log -Data 'Distributiong image package content...' -Class Information
            if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Points') {
                Start-CMContentDistribution -OperatingSystemImageId $PackageID -DistributionPointName $DP
            }
            if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Point Groups') {
                Start-CMContentDistribution -OperatingSystemImageId $PackageID -DistributionPointGroupName $DP
            }

            Update-Log -Data 'Content has been distributed.' -Class Information
        }

        Save-Configuration -CM $PackageID
        Set-Location $global:workdir
    }
}
