<#
.SYNOPSIS
    Retrieve information about an existing ConfigMgr image package.

.DESCRIPTION
    This function retrieves information about an existing ConfigMgr image package and displays it in the GUI.

.NOTES
    Name:        Get-WWImageInformation.ps1
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
    Get-WWImageInformation -PackID "ABC00001"
#>
function Get-WWImageInformation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackID
    )

    process {
        #set-ConfigMgrConnection
        Set-Location $CMDrive
        $image = (Get-CimInstance -Namespace "root\SMS\Site_$($Script:SiteCode)" `
            -ClassName SMS_ImagePackage -ComputerName $Script:SiteServer) |
            Where-Object { ($_.PackageID -eq $PackID) }

        $WPFCMTBImageName.text = $image.name
        $WPFCMTBWinBuildNum.text = $image.ImageOSversion
        $WPFCMTBPackageID.text = $image.PackageID
        $WPFCMTBImageVer.text = $image.version
        $WPFCMTBDescription.text = $image.Description

        $text = 'Image ' + $WPFCMTBImageName.text + ' selected'
        Write-WimWitchLog -data $text -class Information

        $text = 'Package ID is ' + $image.PackageID
        Write-WimWitchLog -data $text -class Information

        $text = 'Image build number is ' + $image.ImageOSversion
        Write-WimWitchLog -data $text -class Information

        $packageID = (Get-CMOperatingSystemImage -Id $image.PackageID)
        # $packageID.PkgSourcePath

        $WPFMISWimFolderTextBox.text = (Split-Path -Path $packageID.PkgSourcePath)
        $WPFMISWimNameTextBox.text = (Split-Path -Path $packageID.PkgSourcePath -Leaf)

        $Package = $packageID.PackageID
        $DPs = Get-CMDistributionPoint
        $NALPaths = Get-CimInstance -Namespace "root\SMS\Site_$($Script:SiteCode)" `
            -ComputerName $Script:SiteServer `
            -Query "SELECT * FROM SMS_DistributionPoint WHERE PackageID='$Package'"

        Write-WimWitchLog -Data 'Retrieving Distrbution Point Information' -Class Information
        foreach ($NALPath in $NALPaths) {
            foreach ($dp in $dps) {
                $DPPath = $dp.NetworkOSPath
                if ($NALPath.ServerNALPath -like ("*$DPPath*")) {
                    Write-WimWitchLog -data "Image has been previously distributed to $DPPath" -class Information
                    $WPFCMLBDPs.Items.Add($DPPath)

                }
            }
        }

        #Detect Binary Diff Replication
        Write-WimWitchLog -data 'Checking Binary Differential Replication setting' -Class Information
        if ($image.PkgFlags -eq ($image.PkgFlags -bor 0x04000000)) {
            $WPFCMCBBinDirRep.IsChecked = $True
        } else {
            $WPFCMCBBinDirRep.IsChecked = $False
        }

        #Detect Package Share Enabled
        Write-WimWitchLog -data 'Checking package share settings' -Class Information
        if ($image.PkgFlags -eq ($image.PkgFlags -bor 0x80)) {
            $WPFCMCBDeploymentShare.IsChecked = $true
        } else
        { $WPFCMCBDeploymentShare.IsChecked = $false }

        Set-Location $Script:workdir
    }
}




