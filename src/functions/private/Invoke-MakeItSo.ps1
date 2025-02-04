<#
.SYNOPSIS
    Main function to build and customize the Windows image.

.DESCRIPTION
    This function orchestrates the entire process of building and customizing a Windows image.
    It handles mounting the image, applying updates, injecting drivers, adding features, customizing settings, and creating the final ISO.

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
    Invoke-MakeItSo -appx "Microsoft.WindowsStore"
#>
function Invoke-MakeItSo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $appx
    )

    process {
        #Check if new file name is valid, also append file extension if neccessary

        ###Starting MIS Preflight###
        Test-MountPath -path $WPFMISMountTextBox.Text -clean True

        if (($WPFMISWimNameTextBox.Text -eq '') -or ($WPFMISWimNameTextBox.Text -eq 'Enter Target WIM Name')) {
            Update-Log -Data 'Enter a valid file name and then try again' -Class Error
            return
        }

        if (($auto -eq $false) -and ($WPFCMCBImageType.SelectedItem -ne 'Update Existing Image' )) {

            $checkresult = (Test-Name)
            if ($checkresult -eq 'stop') { return }
        }

        #check for working directory, make if does not exist, delete files if they exist
        Update-Log -Data 'Checking to see if the staging path exists...' -Class Information

        try {
            if (!(Test-Path "$global:workdir\Staging" -PathType 'Any')) {
                New-Item -ItemType Directory -Force -Path $global:workdir\Staging -ErrorAction Stop
                Update-Log -Data 'Path did not exist, but it does now' -Class Information -ErrorAction Stop
            } else {
                Remove-Item -Path $global:workdir\Staging\* -Recurse -ErrorAction Stop
                Update-Log -Data 'The path existed, and it has been purged.' -Class Information -ErrorAction Stop
            }
        } catch {
            Update-Log -data $_.Exception.Message -class Error
            Update-Log -data "Something is wrong with folder $global:workdir\Staging. Try deleting manually if it exists" -Class Error
            return
        }

        if ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
            Update-Log -Data 'Validating existance of JSON file...' -Class Information
            $APJSONExists = (Test-Path $WPFJSONTextBox.Text)
            if ($APJSONExists -eq $true) { Update-Log -Data 'JSON exists. Continuing...' -Class Information }
            else {
                Update-Log -Data 'The Autopilot file could not be verified. Check it and try again.' -Class Error
                return
            }
        }

        if ($WPFMISDotNetCheckBox.IsChecked -eq $true) {
            if ((Test-DotNetExists) -eq $False) { return }
        }

        #Check for free space
        if ($SkipFreeSpaceCheck -eq $false) {
            if (Test-FreeSpace -eq 1) {
                Update-Log -Data 'Insufficient free space. Delete some files and try again' -Class Error
                return
            } else {
                Update-Log -Data 'There is sufficient free space.' -Class Information
            }
        }
        #####End of MIS Preflight###################################################################

        #Copy source WIM
        Update-Log -Data 'Copying source WIM to the staging folder' -Class Information

        try {
            Copy-Item $WPFSourceWIMSelectWIMTextBox.Text -Destination "$global:workdir\Staging" -ErrorAction Stop
        } catch {
            Update-Log -data $_.Exception.Message -class Error
            Update-Log -Data "The file couldn't be copied. No idea what happened" -class Error
            return
        }

        Update-Log -Data 'Source WIM has been copied to the source folder' -Class Information

        #Rename copied source WiM

        try {
            $wimname = Get-Item -Path $global:workdir\Staging\*.wim -ErrorAction Stop
            Rename-Item -Path $wimname -NewName $WPFMISWimNameTextBox.Text -ErrorAction Stop
            Update-Log -Data 'Copied source WIM has been renamed' -Class Information
        } catch {
            Update-Log -data $_.Exception.Message -class Error
            Update-Log -data "The copied source file couldn't be renamed. This shouldn't have happened." -Class Error
            Update-Log -data "Go delete the WIM from $global:workdir\Staging\, then try again" -Class Error
            return
        }

        #Remove the unwanted indexes
        Remove-OSIndex

        #Mount the WIM File
        $wimname = Get-Item -Path $global:workdir\Staging\*.wim
        Update-Log -Data "Mounting source WIM $wimname" -Class Information
        Update-Log -Data 'to mount point:' -Class Information
        Update-Log -data $WPFMISMountTextBox.Text -Class Information

        try {
            Mount-WindowsImage -Path $WPFMISMountTextBox.Text -ImagePath $wimname -Index 1 -ErrorAction Stop | Out-Null
        } catch {
            Update-Log -data $_.Exception.Message -class Error
            Update-Log -data "The WIM couldn't be mounted. Make sure the mount directory is empty" -Class Error
            Update-Log -Data "and that it isn't an active mount point" -Class Error
            return
        }

        #checks to see if the iso binaries exist. Cancel and discard WIM if they are not present.
        If (($WPFMISCBISO.IsChecked -eq $true) -or ($WPFMISCBUpgradePackage.IsChecked -eq $true)) {
            if ((Test-IsoBinariesExist) -eq $False) {
                Update-Log -Data 'Discarding WIM and not making it so' -Class Error
                Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Discard -ErrorAction Stop | Out-Null
                return
            }
        }

        #Get Mounted WIM version and save it to a variable for useage later in the Function
        $MISWinVer = (Get-WinVersionNumber)

        #Pause after mounting
        If ($WPFMISCBPauseMount.IsChecked -eq $True) {
            Update-Log -Data 'Pausing image building. Waiting on user to continue...' -Class Warning
            $Pause = Suspend-MakeItSo
            if ($Pause -eq 'Yes') { Update-Log -data 'Continuing on with making it so...' -Class Information }
            if ($Pause -eq 'No') {
                Update-Log -data 'Discarding build...' -Class Error
                Update-Log -Data 'Discarding mounted WIM' -Class Warning
                Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Discard -ErrorAction Stop | Out-Null
                Update-Log -Data 'WIM has been discarded. Better luck next time.' -Class Warning
                return
            }
        }

        #Run Script after mounting
        if (($WPFCustomCBRunScript.IsChecked -eq $True) -and ($WPFCustomCBScriptTiming.SelectedItem -eq 'After image mount')) {
            Update-Log -data 'Running PowerShell script...' -Class Information
            Start-Script -file $WPFCustomTBFile.text -parameter $WPFCustomTBParameters.text
            Update-Log -data 'Script completed.' -Class Information
        }

        #Language Packs and FOD
        if ($WPFCustomCBLangPacks.IsChecked -eq $true) {
            Install-LanguagePacks
        } else {
            Update-Log -Data 'Language Packs Injection not selected. Skipping...'
        }

        if ($WPFCustomCBLEP.IsChecked -eq $true) {
            Install-LocalExperiencePack
        } else {
            Update-Log -Data 'Local Experience Packs not selected. Skipping...'
        }

        if ($WPFCustomCBFOD.IsChecked -eq $true) {
            Install-FeaturesOnDemand
        } else {
            Update-Log -Data 'Features On Demand not selected. Skipping...'
        }

        #Inject .Net Binaries
        if ($WPFMISDotNetCheckBox.IsChecked -eq $true) { Add-DotNet }

        #Inject Autopilot JSON file
        if ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
            Update-Log -Data 'Injecting JSON file' -Class Information
            try {
                $autopilotdir = $WPFMISMountTextBox.Text + '\windows\Provisioning\Autopilot'
                Copy-Item $WPFJSONTextBox.Text -Destination $autopilotdir -ErrorAction Stop
            } catch {
                Update-Log -data $_.Exception.Message -class Error
                Update-Log -data "JSON file couldn't be copied. Check to see if the correct SKU" -Class Error
                Update-Log -Data 'of Windows has been selected' -Class Error
                Update-log -Data "The WIM is still mounted. You'll need to clean that up manually until" -Class Error
                Update-Log -data 'I get around to handling that error more betterer' -Class Error
                return
            }
        } else {
            Update-Log -Data 'JSON not selected. Skipping JSON Injection' -Class Information
        }

        #Inject Drivers
        If ($WPFDriverCheckBox.IsChecked -eq $true) {
            Start-DriverInjection -Folder $WPFDriverDir1TextBox.text
            Start-DriverInjection -Folder $WPFDriverDir2TextBox.text
            Start-DriverInjection -Folder $WPFDriverDir3TextBox.text
            Start-DriverInjection -Folder $WPFDriverDir4TextBox.text
            Start-DriverInjection -Folder $WPFDriverDir5TextBox.text
        } Else {
            Update-Log -Data 'Drivers were not selected for injection. Skipping.' -Class Information
        }

        #Inject default application association XML
        if ($WPFCustomCBEnableApp.IsChecked -eq $true) {
            Install-DefaultApplicationAssociations
        } else {
            Update-Log -Data 'Default Application Association not selected. Skipping...' -Class Information
        }

        #Inject start menu layout
        if ($WPFCustomCBEnableStart.IsChecked -eq $true) {
            Install-StartLayout
        } else {
            Update-Log -Data 'Start Menu Layout injection not selected. Skipping...' -Class Information
        }

        #apply registry files
        if ($WPFCustomCBEnableRegistry.IsChecked -eq $true) {
            Install-RegistryFiles
        } else {
            Update-Log -Data 'Registry file injection not selected. Skipping...' -Class Information
        }

        #Check for updates when ConfigMgr source is selected
        if ($WPFMISCBCheckForUpdates.IsChecked -eq $true) {
            Invoke-MISUpdates
            if (($WPFSourceWIMImgDesTextBox.text -like '*Windows 10*') -or ($WPFSourceWIMImgDesTextBox.text -like '*Windows 11*')) { Get-OneDrive }
        }

        #Apply Updates
        If ($WPFUpdatesEnableCheckBox.IsChecked -eq $true) {
            Deploy-Updates -class 'SSU'
            Deploy-Updates -class 'LCU'
            Deploy-Updates -class 'AdobeSU'
            Deploy-Updates -class 'DotNet'
            Deploy-Updates -class 'DotNetCU'
            #if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True){Deploy-Updates -class "Dynamic"}
            if ($WPFUpdatesOptionalEnableCheckBox.IsChecked -eq $True) {
                Deploy-Updates -class 'Optional'
            }
        } else {
            Update-Log -Data 'Updates not enabled' -Class Information
        }

        #Copy the current OneDrive installer
        if ($WPFMISOneDriveCheckBox.IsChecked -eq $true) {
            $os = Get-WindowsType
            $build = Get-WinVersionNumber

            if (($os -eq 'Windows 11') -and ($build -eq '22H2') -or ($build -eq '23H2')) {
                Copy-OneDrivex64
            } else {
                Copy-OneDrive
            }
        } else {
            Update-Log -data 'OneDrive agent update skipped as it was not selected' -Class Information
        }

        #Remove AppX Packages
        if ($WPFAppxCheckBox.IsChecked -eq $true) {
            Remove-Appx -array $appx
        } Else {
            Update-Log -Data 'App removal not enabled' -Class Information
        }

        #Run Script before dismount
        if (($WPFCustomCBRunScript.IsChecked -eq $True) -and ($WPFCustomCBScriptTiming.SelectedItem -eq 'Before image dismount')) {
            Start-Script -file $WPFCustomTBFile.text -parameter $WPFCustomTBParameters.text
        }

        #Pause before dismounting
        If ($WPFMISCBPauseDismount.IsChecked -eq $True) {
            Update-Log -Data 'Pausing image building. Waiting on user to continue...' -Class Warning
            $Pause = Suspend-MakeItSo
            if ($Pause -eq 'Yes') { Update-Log -data 'Continuing on with making it so...' -Class Information }
            if ($Pause -eq 'No') {
                Update-Log -data 'Discarding build...' -Class Error
                Update-Log -Data 'Discarding mounted WIM' -Class Warning
                Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Discard -ErrorAction Stop | Out-Null
                Update-Log -Data 'WIM has been discarded. Better luck next time.' -Class Warning
                return
            }
        }

        #Copy log to mounted WIM
        try {
            Update-Log -Data 'Attempting to copy log to mounted image' -Class Information
            $mountlogdir = $WPFMISMountTextBox.Text + '\windows\'
            Copy-Item $global:workdir\logging\WIMWitch.log -Destination $mountlogdir -ErrorAction Stop
            $CopyLogExist = Test-Path $mountlogdir\WIMWitch.log -PathType Leaf
            if ($CopyLogExist -eq $true) { Update-Log -Data 'Log filed copied successfully' -Class Information }
        } catch {
            Update-Log -data $_.Exception.Message -class Error
            Update-Log -data "Coudn't copy the log file to the mounted image." -class Error
        }

        #Dismount, commit, and move WIM
        Update-Log -Data 'Dismounting WIM file, committing changes' -Class Information
        try {
            Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Save -ErrorAction Stop | Out-Null
        } catch {
            Update-Log -data $_.Exception.Message -class Error
            Update-Log -data "The WIM couldn't save. You will have to manually discard the" -Class Error
            Update-Log -data 'mounted image manually' -Class Error
            return
        }
        Update-Log -Data 'WIM dismounted' -Class Information

        #Display new version number
        $WimInfo = (Get-WindowsImage -ImagePath $wimname -Index 1)
        $text = 'New image version number is ' + $WimInfo.Version
        Update-Log -data $text -Class Information

        if (($auto -eq $true) -or ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image')) {
            Update-Log -Data 'Backing up old WIM file...' -Class Information
            $checkresult = (Test-Name -conflict append)
            if ($checkresult -eq 'stop') { return }
        }

        #stage media if check boxes are selected
        if (($WPFMISCBUpgradePackage.IsChecked -eq $true) -or ($WPFMISCBISO.IsChecked -eq $true)) {
            Copy-StageIsoMedia
            Update-Log -Data 'Exporting install.wim to media staging folder...' -Class Information
            Export-WindowsImage -SourceImagePath $wimname -SourceIndex 1 `
                -DestinationImagePath ($global:workdir + '\staging\media\sources\install.wim') `
                -DestinationName ('WW - ' + $WPFSourceWIMImgDesTextBox.text) | Out-Null
        }

        #Export the wim file to various locations
        if ($WPFMISCBNoWIM.IsChecked -ne $true) {
            try {
                Update-Log -Data 'Exporting WIM file' -Class Information
                Export-WindowsImage -SourceImagePath $wimname -SourceIndex 1 `
                    -DestinationImagePath ($WPFMISWimFolderTextBox.Text + '\' + $WPFMISWimNameTextBox.Text) `
                    -DestinationName ('WW - ' + $WPFSourceWIMImgDesTextBox.text) | Out-Null
            } catch {
                Update-Log -data $_.Exception.Message -class Error
                Update-Log -data "The WIM couldn't be exported. You can still retrieve it from staging path." -Class Error
                Update-Log -data 'The file will be deleted when the tool is rerun.' -Class Error
                return
            }
            Update-Log -Data 'WIM successfully exported to target folder' -Class Information
        }

        #ConfigMgr Integration
        if ($WPFCMCBImageType.SelectedItem -ne 'Disabled') {
            #  "New Image","Update Existing Image"
            if ($WPFCMCBImageType.SelectedItem -eq 'New Image') {
                Update-Log -data 'Creating a new image in ConfigMgr...' -class Information
                New-CMImagePackage
            }

            if ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image') {
                Update-Log -data 'Updating the existing image in ConfigMgr...' -class Information
                Update-CMImage
            }
        }

        #Apply Dynamic Update to media
        if ($WPFMISCBDynamicUpdates.IsChecked -eq $true) {
            Deploy-Updates -class 'Dynamic'
        } else {
            Update-Log -data 'Dynamic Updates skipped or not applicable' -Class Information
        }

        #Apply updates to the boot.wim file
        if ($WPFMISCBBootWIM.IsChecked -eq $true) {
            Update-BootWIM
        } else {
            Update-Log -data 'Updating Boot.WIM skipped or not applicable' -Class Information
        }

        #Copy upgrade package binaries if selected
        if ($WPFMISCBUpgradePackage.IsChecked -eq $true) {
            Copy-UpgradePackage
        } else {
            Update-Log -Data 'Upgrade Package skipped or not applicable' -Class Information
        }

        #Create ISO if selected
        if ($WPFMISCBISO.IsChecked -eq $true) {
            New-WindowsISO
        } else {
            Update-Log -Data 'ISO Creation skipped or not applicable' -Class Information
        }

        #Run Script when build complete
        if (($WPFCustomCBRunScript.IsChecked -eq $True) -and ($WPFCustomCBScriptTiming.SelectedItem -eq 'On build completion')) {
            Start-Script -file $WPFCustomTBFile.text -parameter $WPFCustomTBParameters.text
        }

        #Clear out staging folder
        try {
            Update-Log -Data 'Clearing staging folder...' -Class Information
            Remove-Item $global:workdir\staging\* -Force -Recurse -ErrorAction Stop
        } catch {
            Update-Log -Data 'Could not clear staging folder' -Class Warning
            Update-Log -data $_.Exception.Message -class Error
        }

        #Copy log here
        try {
            Update-Log -Data 'Copying build log to target folder' -Class Information
            Copy-Item -Path $global:workdir\logging\WIMWitch.log -Destination $WPFMISWimFolderTextBox.Text -ErrorAction Stop
            $logold = $WPFMISWimFolderTextBox.Text + '\WIMWitch.log'
            $lognew = $WPFMISWimFolderTextBox.Text + '\' + $WPFMISWimNameTextBox.Text + '.log'
            #Put log detection code here
            if ((Test-Path -Path $lognew) -eq $true) {
                Update-Log -Data 'A preexisting log file contains the same name. Renaming old log...' -Class Warning
                Rename-Name -file $lognew -extension '.log'
            }

            #Put log detection code here
            Rename-Item $logold -NewName $lognew -Force -ErrorAction Stop
            Update-Log -Data 'Log copied successfully' -Class Information
        } catch {
            Update-Log -data $_.Exception.Message -class Error
            Update-Log -data "The log file couldn't be copied and renamed. You can still snag it from the source." -Class Error
            Update-Log -Data "Job's done." -Class Information
            return
        }
        Update-Log -Data "Job's done." -Class Information
    }
}
