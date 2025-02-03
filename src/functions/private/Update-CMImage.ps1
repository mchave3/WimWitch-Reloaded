<#
.SYNOPSIS
    Updates an existing ConfigMgr image package.

.DESCRIPTION
    This function updates an existing image package in Configuration Manager with the new
    image file and redistributes the content to the selected distribution points.

.NOTES
    Name:        Update-CMImage.ps1
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
    Update-CMImage
#>
function Update-CMImage {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Set-Location $CMDrive
            Update-Log -Data 'Updating existing image in ConfigMgr...' -Class Information

            $packageID = $WPFCMComboBox.SelectedItem.ToString()
            $newImagePath = $WPFMISFolderTextBox.Text
            
            # Update image package path
            Set-CMOperatingSystemImage -Id $packageID -Path $newImagePath
            Update-Log -Data 'Image path updated successfully' -Class Information
            
            # Set image properties
            Set-ImageProperties -PackageID $packageID
            
            # Update content on DPs
            if ($WPFCMLBDPs.Items.Count -gt 0) {
                Update-Log -Data 'Starting content update distribution...' -Class Information
                foreach ($dp in $WPFCMLBDPs.Items) {
                    try {
                        Update-CMDistributionPoint -Id $packageID -DeploymentTypeName $dp
                        Update-Log -Data "Content updated on $dp successfully" -Class Information
                    }
                    catch {
                        Update-Log -Data "Failed to update content on $dp" -Class Error
                        Update-Log -Data $_.Exception.Message -Class Error
                    }
                }
            }
        }
        catch {
            Update-Log -Data 'Failed to update image in ConfigMgr' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
        finally {
            Set-Location $PSScriptRoot
        }
    }
}
