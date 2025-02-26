<#
.SYNOPSIS
    Update image version, properties and binary differential replication settings.

.DESCRIPTION
    This function will update image version, properties and binary differential replication settings.

.NOTES
    Name:        Update-WWConfigManagerImageProperty.ps1
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
    Update-WWConfigManagerImageProperty -PackageID "ABC00001"
#>
function Update-WWConfigManagerImageProperty {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageID
    )

    process {
        Set-Location $CMDrive

        if ($WPFCMCBImageVerAuto.IsChecked -eq $true) {
            $string = 'Built ' + (Get-Date -DisplayHint Date)
            if ($PSCmdlet.ShouldProcess("Image version", "Update to $string")) {
                Write-WimWitchLog -Data "Updating image version to $string" -Class Information
                Set-CMOperatingSystemImage -Id $PackageID -Version $string
            }
        }

        if (($WPFCMCBImageVerAuto.IsChecked -eq $false) -and ($null -ne $WPFCMTBImageVer.text)) {
            if ($PSCmdlet.ShouldProcess("Image version", "Update to $($WPFCMTBImageVer.text)")) {
                Write-WimWitchLog -Data 'Updating version of the image...' -Class Information
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
            Write-WimWitchLog -data 'Setting image description...' -Class Information
            Set-CMOperatingSystemImage -Id $PackageID -Description $string
        }

        if ($WPFCMCBDescriptionAuto.IsChecked -eq $false) {

            if ($null -ne $WPFCMTBDescription.Text) {
                Write-WimWitchLog -Data 'Updating description of the image...' -Class Information
                Set-CMOperatingSystemImage -Id $PackageID -Description $WPFCMTBDescription.Text
            }
        }

        #Check Box properties
        #Binary Differnential Replication
        if ($WPFCMCBBinDirRep.IsChecked -eq $true) {
            if ($PSCmdlet.ShouldProcess("Binary Differential Replication", "Enable")) {
                Write-WimWitchLog -Data 'Enabling Binary Differential Replication' -Class Information
                Set-CMOperatingSystemImage -Id $PackageID -EnableBinaryDeltaReplication $true
            }
        } else {
            if ($PSCmdlet.ShouldProcess("Binary Differential Replication", "Disable")) {
                Write-WimWitchLog -Data 'Disabling Binary Differential Replication' -Class Information
                Set-CMOperatingSystemImage -Id $PackageID -EnableBinaryDeltaReplication $false
            }
        }

        #Package Share
        if ($WPFCMCBDeploymentShare.IsChecked -eq $true) {
            Write-WimWitchLog -Data 'Enabling Package Share' -Class Information
            Set-CMOperatingSystemImage -Id $PackageID -CopyToPackageShareOnDistributionPoint $true
        } else {
            Write-WimWitchLog -Data 'Disabling Package Share' -Class Information
            Set-CMOperatingSystemImage -Id $PackageID -CopyToPackageShareOnDistributionPoint $false
        }
    }
}

