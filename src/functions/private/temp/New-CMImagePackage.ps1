<#
.SYNOPSIS
    Creates a new ConfigMgr image package.

.DESCRIPTION
    This function creates a new image package in Configuration Manager with the specified
    properties and distributes it to the selected distribution points.

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
        try {
            Set-Location $CMDrive
            Update-Log -Data 'Creating new image package in ConfigMgr...' -Class Information

            $packageName = $WPFCMTBImageName.Text
            $packagePath = $WPFMISFolderTextBox.Text
            $packageDescription = $WPFCMTBImageDescription.Text
            
            # Create new package
            $newPackage = New-CMOperatingSystemImage -Name $packageName -Path $packagePath -Description $packageDescription
            
            if ($null -ne $newPackage) {
                Update-Log -Data 'Image package created successfully' -Class Information
                $packageID = $newPackage.PackageID
                
                # Set image properties
                Set-ImageProperties -PackageID $packageID
                
                # Distribute content if DPs are selected
                if ($WPFCMLBDPs.Items.Count -gt 0) {
                    Update-Log -Data 'Starting content distribution...' -Class Information
                    foreach ($dp in $WPFCMLBDPs.Items) {
                        try {
                            Start-CMContentDistribution -OperatingSystemImageId $packageID -DistributionPointName $dp
                            Update-Log -Data "Content distributed to $dp successfully" -Class Information
                        }
                        catch {
                            Update-Log -Data "Failed to distribute content to $dp" -Class Error
                            Update-Log -Data $_.Exception.Message -Class Error
                        }
                    }
                }
            }
            else {
                throw "Failed to create image package"
            }
        }
        catch {
            Update-Log -Data 'Failed to create new image package in ConfigMgr' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
        finally {
            Set-Location $PSScriptRoot
        }
    }
}
