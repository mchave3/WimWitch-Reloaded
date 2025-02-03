<#
.SYNOPSIS
    Update image version, properties and binary differential replication settings.

.DESCRIPTION
    This function will update image version, properties and binary differential replication settings.

.NOTES
    Name:        Set-ImageProperties.ps1
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
    Set-ImageProperties -PackageID "ABC00001"
#>
function Set-ImageProperties {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageID
    )

    process {
        #write-host $PackageID
        #set-ConfigMgrConnection
        Set-Location $CMDrive

        #Version Text Box
        if ($WPFCMCBImageVerAuto.IsChecked -eq $true) {
            $string = 'Built ' + (Get-Date -DisplayHint Date)
            Update-Log -Data "Updating image version to $string" -Class Information
            Set-CMOperatingSystemImage -Id $PackageID -Version $string
        }

        if ($WPFCMCBImageVerAuto.IsChecked -eq $false) {

            if ($null -ne $WPFCMTBImageVer.text) {
                Update-Log -Data 'Updating version of the image...' -Class Information
                Set-CMOperatingSystemImage -Id $PackageID -Version $WPFCMTBImageVer.text
            }
        }

        #Description Text Box
        if ($WPFCMCBDescriptionAuto.IsChecked -eq $true) {
            $string = 'This image contains the following customizations: '
            if ($WPFUpdatesEnableCheckBox.IsChecked -eq $true) { $string = $string + 'Software Updates, ' }
            if ($WPFCustomCBLangPacks.IsChecked -eq $true) { $string = $string + 'Language Packs, ' }
            if ($WPFCustomCBLEP.IsChecked -eq $true) { $string = $string + 'Local Experience Packs, ' }
            if ($WPFCustomCBFOD.IsChecked -eq $true) { $string = $string + 'Features on Demand, ' }
            if ($WPFMISDotNetCheckBox.IsChecked -eq $true) { $string = $string + '.Net 3.5, ' }
            if ($WPFMISOneDriveCheckBox.IsChecked -eq $true) { $string = $string + 'OneDrive Consumer, ' }
            if ($WPFAppxCheckBox.IsChecked -eq $true) { $string = $string + 'APPX Removal, ' }
            if ($WPFDriverCheckBox.IsChecked -eq $true) { $string = $string + 'Drivers, ' }
            if ($WPFJSONEnableCheckBox.IsChecked -eq $true) { $string = $string + 'Autopilot, ' }
            if ($WPFCustomCBRunScript.IsChecked -eq $true) { $string = $string + 'Custom Script, ' }
            Update-Log -data 'Setting image description...' -Class Information
            Set-CMOperatingSystemImage -Id $PackageID -Description $string
        }

        if ($WPFCMCBDescriptionAuto.IsChecked -eq $false) {

            if ($null -ne $WPFCMTBDescription.Text) {
                Update-Log -Data 'Updating description of the image...' -Class Information
                Set-CMOperatingSystemImage -Id $PackageID -Description $WPFCMTBDescription.Text
            }
        }

        #Check Box properties
        #Binary Differnential Replication
        if ($WPFCMCBBinDirRep.IsChecked -eq $true) {
            Update-Log -Data 'Enabling Binary Differential Replication' -Class Information
            Set-CMOperatingSystemImage -Id $PackageID -EnableBinaryDeltaReplication $true
        } else {
            Update-Log -Data 'Disabling Binary Differential Replication' -Class Information
            Set-CMOperatingSystemImage -Id $PackageID -EnableBinaryDeltaReplication $false
        }

        #Package Share
        if ($WPFCMCBDeploymentShare.IsChecked -eq $true) {
            Update-Log -Data 'Enabling Package Share' -Class Information
            Set-CMOperatingSystemImage -Id $PackageID -CopyToPackageShareOnDistributionPoint $true
        } else {
            Update-Log -Data 'Disabling Package Share' -Class Information
            Set-CMOperatingSystemImage -Id $PackageID -CopyToPackageShareOnDistributionPoint $false
        }
    }
}
