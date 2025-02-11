<#
.SYNOPSIS
    Install default application associations.

.DESCRIPTION
    This function applies default application associations to the mounted Windows image using the specified XML file.
    It uses DISM to import the associations and handles any errors that occur during the process.

.NOTES
    Name:        Install-WWDefaultApplicationAssociation.ps1
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
    Install-WWDefaultApplicationAssociation
#>
function Install-WWDefaultApplicationAssociation {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Write-WimWitchLog -Data 'Installing default application associations...' -Class Information

            $mountPath = $WPFMISMountTextBox.Text
            $defaultAppPath = $WPFCustomDefaultAppTextBox.Text

            if (Test-Path -Path $defaultAppPath) {
                # Apply default app associations using DISM
                $result = dism.exe /image:$mountPath /Import-DefaultAppAssociations:$defaultAppPath

                if ($result.exitCode -eq 0) {
                    Write-WimWitchLog -Data 'Default application associations installed successfully' -Class Information
                }
                else {
                    throw "DISM failed with exit code: $LASTEXITCODE"
                }
            }
            else {
                throw "Default app associations file not found: $defaultAppPath"
            }
        }
        catch {
            Write-WimWitchLog -Data 'Failed to install default application associations' -Class Error
            Write-WimWitchLog -Data $_.Exception.Message -Class Error
        }
    }
}



