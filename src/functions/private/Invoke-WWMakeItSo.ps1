<#
.SYNOPSIS
    Main function to build and customize the Windows image.

.DESCRIPTION
    This function orchestrates the entire process of building and customizing a Windows image.
    It handles mounting the image, applying updates, injecting drivers, adding features, customizing settings, and creating the final ISO.

.NOTES
    Name:        Invoke-WWMakeItSo.ps1
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
    Invoke-WWMakeItSo -appx "Microsoft.WindowsStore"
#>
function Invoke-WWMakeItSo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $appx
    )

    process {
        #Check if new file name is valid, also append file extension if neccessary

        ###Starting MIS Preflight###
        Test-WWMountPath -path $WPFMISMountTextBox.Text -clean True

        if (($WPFMISWimNameTextBox.Text -eq '') -or ($WPFMISWimNameTextBox.Text -eq 'Enter Target WIM Name')) {
            Write-WimWitchLog -Data 'Enter a valid file name and then try again' -Class Error
            return
        }

        if (($auto -eq $false) -and ($WPFCMCBImageType.SelectedItem -ne 'Update Existing Image' )) {

            $checkresult = (Test-WWValidName)
            if ($checkresult -eq 'stop') { return }
        }

        #check for working directory, make if does not exist, delete files if they exist
        Write-WimWitchLog -Data 'Checking to see if the staging path exists...' -Class Information

        try {
            if (!(Test-Path "$Script:workdir\Staging" -PathType 'Any')) {
                New-Item -ItemType Directory -Force -Path $Script:workdir\Staging -ErrorAction Stop
                Write-WimWitchLog -Data 'Path did not exist, but it does now' -Class Information -ErrorAction Stop
            } else {
                Remove-Item -Path $Script:workdir\Staging\* -Recurse -ErrorAction Stop
                Write-WimWitchLog -Data 'The path existed, and it has been purged.' -Class Information -ErrorAction Stop
            }
        } catch {
            Write-WimWitchLog -data $_.Exception.Message -class Error
            Write-WimWitchLog -data "Something is wrong with folder $Script:workdir\Staging. Try deleting manually if it exists" -Class Error
            return
        }

        if ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
            Write-WimWitchLog -Data 'Validating existance of JSON file...' -Class Information
            $APJSONExists = (Test-Path $WPFJSONTextBox.Text)
            if ($APJSONExists -eq $true) { Write-WimWitchLog -Data 'JSON exists. Continuing...' -Class Information }
            else {
                Write-WimWitchLog -Data 'The Autopilot file could not be verified. Check it and try again.' -Class Error
                return
            }
        }

        if ($WPFMISDotNetCheckBox.IsChecked -eq $true) {
            if ((Test-WWDotNetExist) -eq $False) { return }
        }

        #Check for free space
        if ($SkipFreeSpaceCheck -eq $false) {
            if (Test-FreeSpace -eq 1) {
                Write-WimWitchLog -Data 'Insufficient free space. Delete some files and try again' -Class Error
                return
            } else {
                Write-WimWitchLog -Data 'There is sufficient free space.' -Class Information
            }
        }
        #####End of MIS Preflight###################################################################

        #Copy source WIM
        Write-WimWitchLog -Data 'Copying source WIM to the staging folder' -Class Information

        try {
            Copy-Item $WPFSourceWIMSelectWIMTextBox.Text -Destination "$Script:workdir\Staging" -ErrorAction Stop
        } catch {
            Write-WimWitchLog -data $_.Exception.Message -class Error
            Write-WimWitchLog -Data "The file couldn't be copied. No idea what happened" -class Error
            return
        }

        Write-WimWitchLog -Data 'Source WIM has been copied to the source folder' -Class Information

        #Rename copied source WiM

        try {
            $wimname = Get-Item -Path $Script:workdir\Staging\*.wim -ErrorAction Stop
            Rename-Item -Path $wimname -NewName $WPFMISWimNameTextBox.Text -ErrorAction Stop
            Write-WimWitchLog -Data 'Copied source WIM has been renamed' -Class Information
        } catch {
            Write-WimWitchLog -data $_.Exception.Message -class Error
            Write-WimWitchLog -data "The copied source file couldn't be renamed. This shouldn't have happened." -Class Error
            Write-WimWitchLog -data "Go delete the WIM from $Script:workdir\Staging\, then try again" -Class Error
            return
        }

        #Remove the unwanted indexes
        Clear-WWOSIndex

        #Mount the WIM File
        $wimname = Get-Item -Path $Script:workdir\Staging\*.wim
        Write-WimWitchLog -Data "Mounting source WIM $wimname" -Class Information
        Write-WimWitchLog -Data 'to mount point:' -Class Information
        Write-WimWitchLog -data $WPFMISMountTextBox.Text -Class Information

        try {
            Mount-WindowsImage -Path $WPFMISMountTextBox.Text -ImagePath $wimname -Index 1 -ErrorAction Stop | Out-Null
        } catch {
            Write-WimWitchLog -data $_.Exception.Message -class Error
            Write-WimWitchLog -data "The WIM couldn't be mounted. Make sure the mount directory is empty" -Class Error
            Write-WimWitchLog -Data "and that it isn't an active mount point" -Class Error
            return
        }

        #checks to see if the iso binaries exist. Cancel and discard WIM if they are not present.
        If (($WPFMISCBISO.IsChecked -eq $true) -or ($WPFMISCBUpgradePackage.IsChecked -eq $true)) {
            if ((Test-WWISOBinariesExist) -eq $False) {
                Write-WimWitchLog -Data 'Discarding WIM and not making it so' -Class Error
                Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Discard -ErrorAction Stop | Out-Null
                return
            }
        }

        #Get Mounted WIM version and save it to a variable for useage later in the Function
        $Script:MISWinVer = (Get-WWWindowsVersionNumber)

        #Pause after mounting
        If ($WPFMISCBPauseMount.IsChecked -eq $True) {
            Write-WimWitchLog -Data 'Pausing image building. Waiting on user to continue...' -Class Warning
            $Pause = Suspend-WWMakeItSo
            if ($Pause -eq 'Yes') { Write-WimWitchLog -data 'Continuing on with making it so...' -Class Information }
            if ($Pause -eq 'No') {
                Write-WimWitchLog -data 'Discarding build...' -Class Error
                Write-WimWitchLog -Data 'Discarding mounted WIM' -Class Warning
                Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Discard -ErrorAction Stop | Out-Null
                Write-WimWitchLog -Data 'WIM has been discarded. Better luck next time.' -Class Warning
                return
            }
        }

        #Run Script after mounting
        if (($WPFCustomCBRunScript.IsChecked -eq $True) -and ($WPFCustomCBScriptTiming.SelectedItem -eq 'After image mount')) {
            Write-WimWitchLog -data 'Running PowerShell script...' -Class Information
            Invoke-WWScript -file $WPFCustomTBFile.text -parameter $WPFCustomTBParameters.text
            Write-WimWitchLog -data 'Script completed.' -Class Information
        }

        #Language Packs and FOD
        if ($WPFCustomCBLangPacks.IsChecked -eq $true) {
            Install-WWLanguagePack
        } else {
            Write-WimWitchLog -Data 'Language Packs Injection not selected. Skipping...'
        }

        if ($WPFCustomCBLEP.IsChecked -eq $true) {
            Install-WWLocalExperiencePack
        } else {
            Write-WimWitchLog -Data 'Local Experience Packs not selected. Skipping...'
        }

        if ($WPFCustomCBFOD.IsChecked -eq $true) {
            Install-WWFeaturesOnDemand
        } else {
            Write-WimWitchLog -Data 'Features On Demand not selected. Skipping...'
        }

        #Inject .Net Binaries
        if ($WPFMISDotNetCheckBox.IsChecked -eq $true) { Add-WWDotNet }

        #Inject Autopilot JSON file
        if ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
            Write-WimWitchLog -Data 'Injecting JSON file' -Class Information
            try {
                $autopilotdir = $WPFMISMountTextBox.Text + '\windows\Provisioning\Autopilot'
                Copy-Item $WPFJSONTextBox.Text -Destination $autopilotdir -ErrorAction Stop
            } catch {
                Write-WimWitchLog -data $_.Exception.Message -class Error
                Write-WimWitchLog -data "JSON file couldn't be copied. Check to see if the correct SKU" -Class Error
                Write-WimWitchLog -Data 'of Windows has been selected' -Class Error
                Write-WimWitchLog -Data "The WIM is still mounted. You'll need to clean that up manually until" -Class Error
                Write-WimWitchLog -data 'I get around to handling that error more betterer' -Class Error
                return
            }
        } else {
            Write-WimWitchLog -Data 'JSON not selected. Skipping JSON Injection' -Class Information
        }

        #Inject Drivers
        If ($WPFDriverCheckBox.IsChecked -eq $true) {
            Add-WWDriver -Folder $WPFDriverDir1TextBox.text
            Add-WWDriver -Folder $WPFDriverDir2TextBox.text
            Add-WWDriver -Folder $WPFDriverDir3TextBox.text
            Add-WWDriver -Folder $WPFDriverDir4TextBox.text
            Add-WWDriver -Folder $WPFDriverDir5TextBox.text
        } Else {
            Write-WimWitchLog -Data 'Drivers were not selected for injection. Skipping.' -Class Information
        }

        #Inject default application association XML
        if ($WPFCustomCBEnableApp.IsChecked -eq $true) {
            Install-WWDefaultApplicationAssociation
        } else {
            Write-WimWitchLog -Data 'Default Application Association not selected. Skipping...' -Class Information
        }

        #Inject start menu layout
        if ($WPFCustomCBEnableStart.IsChecked -eq $true) {
            Install-WWStartLayout
        } else {
            Write-WimWitchLog -Data 'Start Menu Layout injection not selected. Skipping...' -Class Information
        }

        #apply registry files
        if ($WPFCustomCBEnableRegistry.IsChecked -eq $true) {
            Install-WWRegistryFile
        } else {
            Write-WimWitchLog -Data 'Registry file injection not selected. Skipping...' -Class Information
        }

        #Check for updates when ConfigMgr source is selected
        if ($WPFMISCBCheckForUpdates.IsChecked -eq $true) {
            Invoke-WWMISUpdate
            if (($WPFSourceWIMImgDesTextBox.text -like '*Windows 10*') -or ($WPFSourceWIMImgDesTextBox.text -like '*Windows 11*')) { Get-WWOneDrive }
        }

        #Apply Updates
        If ($WPFUpdatesEnableCheckBox.IsChecked -eq $true) {
            Deploy-WWUpdate -class 'SSU'
            Deploy-WWUpdate -class 'LCU'
            Deploy-WWUpdate -class 'AdobeSU'
            Deploy-WWUpdate -class 'DotNet'
            Deploy-WWUpdate -class 'DotNetCU'
            #if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True){Deploy-WWUpdate -class "Dynamic"}
            if ($WPFUpdatesOptionalEnableCheckBox.IsChecked -eq $True) {
                Deploy-WWUpdate -class 'Optional'
            }
        } else {
            Write-WimWitchLog -Data 'Updates not enabled' -Class Information
        }

        #Copy the current OneDrive installer
        if ($WPFMISOneDriveCheckBox.IsChecked -eq $true) {
            $os = Get-WWWindowsType
            $build = Get-WWWindowsVersionNumber

            if (($os -eq 'Windows 11') -and ($build -eq '22H2') -or ($build -eq '23H2')) {
                Copy-WWOneDriveX64
            } else {
                Copy-WWOneDrive
            }
        } else {
            Write-WimWitchLog -data 'OneDrive agent update skipped as it was not selected' -Class Information
        }

        #Remove AppX Packages
        if ($WPFAppxCheckBox.IsChecked -eq $true) {
            Remove-WWAppx -array $appx
        } Else {
            Write-WimWitchLog -Data 'App removal not enabled' -Class Information
        }

        #Run Script before dismount
        if (($WPFCustomCBRunScript.IsChecked -eq $True) -and ($WPFCustomCBScriptTiming.SelectedItem -eq 'Before image dismount')) {
            Invoke-WWScript -file $WPFCustomTBFile.text -parameter $WPFCustomTBParameters.text
        }

        #Pause before dismounting
        If ($WPFMISCBPauseDismount.IsChecked -eq $True) {
            Write-WimWitchLog -Data 'Pausing image building. Waiting on user to continue...' -Class Warning
            $Pause = Suspend-WWMakeItSo
            if ($Pause -eq 'Yes') { Write-WimWitchLog -data 'Continuing on with making it so...' -Class Information }
            if ($Pause -eq 'No') {
                Write-WimWitchLog -data 'Discarding build...' -Class Error
                Write-WimWitchLog -Data 'Discarding mounted WIM' -Class Warning
                Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Discard -ErrorAction Stop | Out-Null
                Write-WimWitchLog -Data 'WIM has been discarded. Better luck next time.' -Class Warning
                return
            }
        }

        #Copy log to mounted WIM
        try {
            Write-WimWitchLog -Data 'Attempting to copy log to mounted image' -Class Information
            $mountlogdir = $WPFMISMountTextBox.Text + '\windows\'
            Copy-Item $Script:workdir\logging\WIMWitch.log -Destination $mountlogdir -ErrorAction Stop
            $CopyLogExist = Test-Path $mountlogdir\WIMWitch.log -PathType Leaf
            if ($CopyLogExist -eq $true) { Write-WimWitchLog -Data 'Log filed copied successfully' -Class Information }
        } catch {
            Write-WimWitchLog -data $_.Exception.Message -class Error
            Write-WimWitchLog -data "Coudn't copy the log file to the mounted image." -class Error
        }

        #Dismount, commit, and move WIM
        Write-WimWitchLog -Data 'Dismounting WIM file, committing changes' -Class Information
        try {
            Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Save -ErrorAction Stop | Out-Null
        } catch {
            Write-WimWitchLog -data $_.Exception.Message -class Error
            Write-WimWitchLog -data "The WIM couldn't save. You will have to manually discard the" -Class Error
            Write-WimWitchLog -data 'mounted image manually' -Class Error
            return
        }
        Write-WimWitchLog -Data 'WIM dismounted' -Class Information

        #Display new version number
        $WimInfo = (Get-WindowsImage -ImagePath $wimname -Index 1)
        $text = 'New image version number is ' + $WimInfo.Version
        Write-WimWitchLog -data $text -Class Information

        if (($auto -eq $true) -or ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image')) {
            Write-WimWitchLog -Data 'Backing up old WIM file...' -Class Information
            $checkresult = (Test-WWValidName -conflict append)
            if ($checkresult -eq 'stop') { return }
        }

        #stage media if check boxes are selected
        if (($WPFMISCBUpgradePackage.IsChecked -eq $true) -or ($WPFMISCBISO.IsChecked -eq $true)) {
            Copy-WWStageISOMedia
            Write-WimWitchLog -Data 'Exporting install.wim to media staging folder...' -Class Information
            Export-WindowsImage -SourceImagePath $wimname -SourceIndex 1 `
                -DestinationImagePath ($Script:workdir + '\staging\media\sources\install.wim') `
                -DestinationName ('WW - ' + $WPFSourceWIMImgDesTextBox.text) | Out-Null
        }

        #Export the wim file to various locations
        if ($WPFMISCBNoWIM.IsChecked -ne $true) {
            try {
                Write-WimWitchLog -Data 'Exporting WIM file' -Class Information
                Export-WindowsImage -SourceImagePath $wimname -SourceIndex 1 `
                    -DestinationImagePath ($WPFMISWimFolderTextBox.Text + '\' + $WPFMISWimNameTextBox.Text) `
                    -DestinationName ('WW - ' + $WPFSourceWIMImgDesTextBox.text) | Out-Null
            } catch {
                Write-WimWitchLog -data $_.Exception.Message -class Error
                Write-WimWitchLog -data "The WIM couldn't be exported. You can still retrieve it from staging path." -Class Error
                Write-WimWitchLog -data 'The file will be deleted when the tool is rerun.' -Class Error
                return
            }
            Write-WimWitchLog -Data 'WIM successfully exported to target folder' -Class Information
        }

        #ConfigMgr Integration
        if ($WPFCMCBImageType.SelectedItem -ne 'Disabled') {
            #  "New Image","Update Existing Image"
            if ($WPFCMCBImageType.SelectedItem -eq 'New Image') {
                Write-WimWitchLog -data 'Creating a new image in ConfigMgr...' -class Information
                Build-WWConfigManagerImagePackage
            }

            if ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image') {
                Write-WimWitchLog -data 'Updating the existing image in ConfigMgr...' -class Information
                Update-WWConfigManagerImage
            }
        }

        #Apply Dynamic Update to media
        if ($WPFMISCBDynamicUpdates.IsChecked -eq $true) {
            Deploy-WWUpdate -class 'Dynamic'
        } else {
            Write-WimWitchLog -data 'Dynamic Updates skipped or not applicable' -Class Information
        }

        #Apply updates to the boot.wim file
        if ($WPFMISCBBootWIM.IsChecked -eq $true) {
            Invoke-WWBootWIMUpdate
        } else {
            Write-WimWitchLog -data 'Updating Boot.WIM skipped or not applicable' -Class Information
        }

        #Copy upgrade package binaries if selected
        if ($WPFMISCBUpgradePackage.IsChecked -eq $true) {
            Copy-WWUpgradePackage
        } else {
            Write-WimWitchLog -Data 'Upgrade Package skipped or not applicable' -Class Information
        }

        #Create ISO if selected
        if ($WPFMISCBISO.IsChecked -eq $true) {
            Build-WWWindowsISO
        } else {
            Write-WimWitchLog -Data 'ISO Creation skipped or not applicable' -Class Information
        }

        #Run Script when build complete
        if (($WPFCustomCBRunScript.IsChecked -eq $True) -and ($WPFCustomCBScriptTiming.SelectedItem -eq 'On build completion')) {
            Invoke-WWScript -file $WPFCustomTBFile.text -parameter $WPFCustomTBParameters.text
        }

        #Clear out staging folder
        try {
            Write-WimWitchLog -Data 'Clearing staging folder...' -Class Information
            Remove-Item $Script:workdir\staging\* -Force -Recurse -ErrorAction Stop
        } catch {
            Write-WimWitchLog -Data 'Could not clear staging folder' -Class Warning
            Write-WimWitchLog -data $_.Exception.Message -class Error
        }

        #Copy log here
        try {
            Write-WimWitchLog -Data 'Copying build log to target folder' -Class Information
            Copy-Item -Path $Script:workdir\logging\WIMWitch.log -Destination $WPFMISWimFolderTextBox.Text -ErrorAction Stop
            $logold = $WPFMISWimFolderTextBox.Text + '\WIMWitch.log'
            $lognew = $WPFMISWimFolderTextBox.Text + '\' + $WPFMISWimNameTextBox.Text + '.log'
            #Put log detection code here
            if ((Test-Path -Path $lognew) -eq $true) {
                Write-WimWitchLog -Data 'A preexisting log file contains the same name. Renaming old log...' -Class Warning
                Rename-WWName -file $lognew -extension '.log'
            }

            #Put log detection code here
            Rename-Item $logold -NewName $lognew -Force -ErrorAction Stop
            Write-WimWitchLog -Data 'Log copied successfully' -Class Information
        } catch {
            Write-WimWitchLog -data $_.Exception.Message -class Error
            Write-WimWitchLog -data "The log file couldn't be copied and renamed. You can still snag it from the source." -Class Error
            Write-WimWitchLog -Data "Job's done." -Class Information
            return
        }
        Write-WimWitchLog -Data "Job's done." -Class Information
    }
}


