<#
.SYNOPSIS
    Main function to build and customize the Windows image.

.DESCRIPTION
    This function orchestrates the entire process of building and customizing a Windows image.
    It handles mounting the image, applying updates, injecting drivers, adding features,
    customizing settings, and creating the final ISO.

.NOTES
    Name:        Invoke-MakeItSo.ps1
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
    Invoke-MakeItSo -appx $true
#>
function Invoke-MakeItSo {
    [CmdletBinding()]
    param(
        [Parameter()]
        [bool]$appx
    )

    process {
        ###Starting MIS Preflight###
        Test-MountPath -path $WPFMISMountTextBox.Text -clean True

        #Mount the WIM File
        try {
            $mountdir = $WPFMISMountTextBox.Text
            Update-Log -data 'Mounting WIM file...' -Class Information
            Mount-WindowsImage -Path $mountdir -ImagePath $WPFSourceWIMSelectWIMTextBox.Text -Index $WPFSourceWimIndexTextBox.Text | Out-Null
            Update-Log -Data 'WIM file mounted successfully' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to mount WIM file' -Class Error
            Update-Log -data $_.Exception.Message -Class Error
            return
        }

        #Pause after mounting
        If ($WPFMISCBPauseMount.IsChecked -eq $True) {
            Update-Log -Data 'Pausing image building. Waiting on user to continue...' -Class Warning
            $Pause = Suspend-MakeItSo
            if ($Pause -eq 'Yes') { 
                Update-Log -data 'Continuing on with making it so...' -Class Information 
            }
            if ($Pause -eq 'No') { 
                Update-Log -data 'Cancelling build...' -Class Error
                try {
                    Update-Log -data 'Dismounting WIM...' -Class Warning
                    Dismount-WindowsImage -Path $mountdir -Discard | Out-Null
                    Update-Log -data 'WIM dismounted successfully' -Class Warning
                }
                catch {
                    Update-Log -data "Couldn't dismount WIM" -Class Error
                    Update-Log -data $_.Exception.Message -Class Error
                }
                return
            }
        }

        #Apply Updates
        if ($WPFUpdatesEnableCheckBox.IsChecked -eq $true) {
            Update-Log -Data 'Starting Windows update process...' -Class Information
            Deploy-Updates
        }

        #Install .Net Framework 3.5
        if ($WPFCustomCBDotNet.IsChecked -eq $true) {
            Update-Log -data 'Installing .Net Framework 3.5...' -Class Information
            Add-DotNet
        }

        #Remove AppX Packages
        if ($appx -eq $true) {
            Update-Log -Data 'Starting AppX removal process...' -Class Information
            Remove-Appx
        }

        #Apply Custom Registry Settings
        if ($WPFCustomCBRegistry.IsChecked -eq $true) {
            Update-Log -Data 'Starting registry file application process...' -Class Information
            Install-RegistryFiles
        }

        #Apply Start Menu
        if ($WPFCustomCBStartMenu.IsChecked -eq $true) {
            Update-Log -Data 'Starting start menu implementation process...' -Class Information
            Install-StartLayout
        }

        #Apply default application association
        if ($WPFCustomCBDefaultApp.IsChecked -eq $true) {
            Update-Log -Data 'Importing default app associations...' -Class Information
            try {
                $DefaultAppPath = $WPFCustomDefaultAppTextBox.text
                Update-Log -data 'Importing default app associations XML...' -Class Information
                dism.exe /image:$mountdir /Import-DefaultAppAssociations:$DefaultAppPath | Out-Null
                Update-Log -data 'Default app associations imported successfully' -Class Information
            }
            catch {
                Update-Log -Data 'Failed to import default app associations' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
            }
        }

        #Run Custom Scripts
        if ($WPFCustomCBRunScript.IsChecked -eq $true) {
            Update-Log -Data 'Running custom scripts...' -Class Information
            foreach ($script in $WPFCustomLBRunScript.Items) {
                $scriptPath = $script
                $scriptName = Split-Path $script -Leaf
                $scriptParameters = "-MountPath $mountdir"
                Update-Log -Data "Running script: $scriptName" -Class Information
                Start-Script -File $scriptPath -Parameter $scriptParameters
            }
        }

        #OneDrive for Business
        if ($WPFMISOneDriveCheckBox.IsChecked -eq $true) {
            $os = Get-WindowsType
            $build = Get-WinVersionNumber

            if (($os -eq 'Windows 11') -and ($build -eq '22H2') -or ($build -eq '23H2')) {
                Update-Log -data 'Detected Windows 11 22H2 or later, copying OneDrive...' -Class Information
                Copy-OneDrivex64
            }
            else {
                Update-Log -data 'Copying OneDrive...' -Class Information
                Copy-OneDrive
            }
        }

        #Inject Drivers
        if ($WPFDriverCheckBox.IsChecked -eq $true) {
            Update-Log -Data 'Starting driver injection process...' -Class Information
            Start-DriverInjection
        }

        #Enable .Net 3.5
        if ($WPFCustomCBEnableDotNet.IsChecked -eq $true) {
            Update-Log -data 'Enabling .Net 3.5...' -Class Information
            try {
                Enable-WindowsOptionalFeature -Path $mountdir -FeatureName NetFx3 -All -LimitAccess -Source $DotNetSource | Out-Null
                Update-Log -data '.Net 3.5 enabled successfully' -Class Information
            }
            catch {
                Update-Log -data 'Failed to enable .Net 3.5' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
            }
        }

        #Inject Language Packs
        if ($WPFCustomCBLangPacks.IsChecked -eq $true) {
            Update-Log -Data 'Starting language pack injection process...' -Class Information
            Install-LanguagePacks
        }

        #Inject Local Experience Packs
        if ($WPFCustomCBLEP.IsChecked -eq $true) {
            Update-Log -Data 'Starting local experience pack injection process...' -Class Information
            Install-LocalExperiencePack
        }

        #Inject Features on Demand
        if ($WPFCustomCBFOD.IsChecked -eq $true) {
            Update-Log -Data 'Starting Features on Demand injection process...' -Class Information
            Install-FeaturesOnDemand
        }

        #Configure ConfigMgr
        if ($WPFCMCBImageType.SelectedItem -ne 'Disabled') {
            if ($WPFCMCBImageType.SelectedItem -eq 'New Image') {
                Update-Log -data 'Creating a new image in ConfigMgr...' -Class Information
                New-CMImagePackage
            }
            if ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image') {
                Update-Log -data 'Updating existing ConfigMgr image...' -Class Information
                Update-CMImage
            }
        }

        #Dismount and Save
        try {
            Update-Log -data 'Dismounting WIM...' -Class Information
            Dismount-WindowsImage -Path $mountdir -Save | Out-Null
            Update-Log -data 'WIM dismounted successfully' -Class Information
        }
        catch {
            Update-Log -data "Couldn't dismount WIM" -Class Error
            Update-Log -data $_.Exception.Message -Class Error
            return
        }

        Update-Log -Data 'Image build process complete!' -Class Information
    }
}
