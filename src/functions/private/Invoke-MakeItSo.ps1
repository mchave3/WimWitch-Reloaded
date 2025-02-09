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
            Write-WWLog -Data 'Enter a valid file name and then try again' -Class Error
            return
        }

        if (($auto -eq $false) -and ($WPFCMCBImageType.SelectedItem -ne 'Update Existing Image' )) {

            $checkresult = (Test-Name)
            if ($checkresult -eq 'stop') { return }
        }

        #check for working directory, make if does not exist, delete files if they exist
        Write-WWLog -Data 'Checking to see if the staging path exists...' -Class Information

        try {
            if (!(Test-Path "$Script:workdir\Staging" -PathType 'Any')) {
                New-Item -ItemType Directory -Force -Path $Script:workdir\Staging -ErrorAction Stop
                Write-WWLog -Data 'Path did not exist, but it does now' -Class Information -ErrorAction Stop
            } else {
                Remove-Item -Path $Script:workdir\Staging\* -Recurse -ErrorAction Stop
                Write-WWLog -Data 'The path existed, and it has been purged.' -Class Information -ErrorAction Stop
            }
        } catch {
            Write-WWLog -data $_.Exception.Message -class Error
            Write-WWLog -data "Something is wrong with folder $Script:workdir\Staging. Try deleting manually if it exists" -Class Error
            return
        }

        if ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
            Write-WWLog -Data 'Validating existance of JSON file...' -Class Information
            $APJSONExists = (Test-Path $WPFJSONTextBox.Text)
            if ($APJSONExists -eq $true) { Write-WWLog -Data 'JSON exists. Continuing...' -Class Information }
            else {
                Write-WWLog -Data 'The Autopilot file could not be verified. Check it and try again.' -Class Error
                return
            }
        }

        if ($WPFMISDotNetCheckBox.IsChecked -eq $true) {
            if ((Test-DotNetExist) -eq $False) { return }
        }

        #Check for free space
        if ($SkipFreeSpaceCheck -eq $false) {
            if (Test-FreeSpace -eq 1) {
                Write-WWLog -Data 'Insufficient free space. Delete some files and try again' -Class Error
                return
            } else {
                Write-WWLog -Data 'There is sufficient free space.' -Class Information
            }
        }
        #####End of MIS Preflight###################################################################

        #Copy source WIM
        Write-WWLog -Data 'Copying source WIM to the staging folder' -Class Information

        try {
            Copy-Item $WPFSourceWIMSelectWIMTextBox.Text -Destination "$Script:workdir\Staging" -ErrorAction Stop
        } catch {
            Write-WWLog -data $_.Exception.Message -class Error
            Write-WWLog -Data "The file couldn't be copied. No idea what happened" -class Error
            return
        }

        Write-WWLog -Data 'Source WIM has been copied to the source folder' -Class Information

        #Rename copied source WiM

        try {
            $wimname = Get-Item -Path $Script:workdir\Staging\*.wim -ErrorAction Stop
            Rename-Item -Path $wimname -NewName $WPFMISWimNameTextBox.Text -ErrorAction Stop
            Write-WWLog -Data 'Copied source WIM has been renamed' -Class Information
        } catch {
            Write-WWLog -data $_.Exception.Message -class Error
            Write-WWLog -data "The copied source file couldn't be renamed. This shouldn't have happened." -Class Error
            Write-WWLog -data "Go delete the WIM from $Script:workdir\Staging\, then try again" -Class Error
            return
        }

        #Remove the unwanted indexes
        Clear-OSIndex

        #Mount the WIM File
        $wimname = Get-Item -Path $Script:workdir\Staging\*.wim
        Write-WWLog -Data "Mounting source WIM $wimname" -Class Information
        Write-WWLog -Data 'to mount point:' -Class Information
        Write-WWLog -data $WPFMISMountTextBox.Text -Class Information

        try {
            Mount-WindowsImage -Path $WPFMISMountTextBox.Text -ImagePath $wimname -Index 1 -ErrorAction Stop | Out-Null
        } catch {
            Write-WWLog -data $_.Exception.Message -class Error
            Write-WWLog -data "The WIM couldn't be mounted. Make sure the mount directory is empty" -Class Error
            Write-WWLog -Data "and that it isn't an active mount point" -Class Error
            return
        }

        #checks to see if the iso binaries exist. Cancel and discard WIM if they are not present.
        If (($WPFMISCBISO.IsChecked -eq $true) -or ($WPFMISCBUpgradePackage.IsChecked -eq $true)) {
            if ((Test-IsoBinariesExist) -eq $False) {
                Write-WWLog -Data 'Discarding WIM and not making it so' -Class Error
                Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Discard -ErrorAction Stop | Out-Null
                return
            }
        }

        #Get Mounted WIM version and save it to a variable for useage later in the Function
        $Script:MISWinVer = (Get-WinVersionNumber)

        #Pause after mounting
        If ($WPFMISCBPauseMount.IsChecked -eq $True) {
            Write-WWLog -Data 'Pausing image building. Waiting on user to continue...' -Class Warning
            $Pause = Suspend-MakeItSo
            if ($Pause -eq 'Yes') { Write-WWLog -data 'Continuing on with making it so...' -Class Information }
            if ($Pause -eq 'No') {
                Write-WWLog -data 'Discarding build...' -Class Error
                Write-WWLog -Data 'Discarding mounted WIM' -Class Warning
                Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Discard -ErrorAction Stop | Out-Null
                Write-WWLog -Data 'WIM has been discarded. Better luck next time.' -Class Warning
                return
            }
        }

        #Run Script after mounting
        if (($WPFCustomCBRunScript.IsChecked -eq $True) -and ($WPFCustomCBScriptTiming.SelectedItem -eq 'After image mount')) {
            Write-WWLog -data 'Running PowerShell script...' -Class Information
            Invoke-WWScript -file $WPFCustomTBFile.text -parameter $WPFCustomTBParameters.text
            Write-WWLog -data 'Script completed.' -Class Information
        }

        #Language Packs and FOD
        if ($WPFCustomCBLangPacks.IsChecked -eq $true) {
            Install-LanguagePack
        } else {
            Write-WWLog -Data 'Language Packs Injection not selected. Skipping...'
        }

        if ($WPFCustomCBLEP.IsChecked -eq $true) {
            Install-LocalExperiencePack
        } else {
            Write-WWLog -Data 'Local Experience Packs not selected. Skipping...'
        }

        if ($WPFCustomCBFOD.IsChecked -eq $true) {
            Install-FeaturesOnDemand
        } else {
            Write-WWLog -Data 'Features On Demand not selected. Skipping...'
        }

        #Inject .Net Binaries
        if ($WPFMISDotNetCheckBox.IsChecked -eq $true) { Add-DotNet }

        #Inject Autopilot JSON file
        if ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
            Write-WWLog -Data 'Injecting JSON file' -Class Information
            try {
                $autopilotdir = $WPFMISMountTextBox.Text + '\windows\Provisioning\Autopilot'
                Copy-Item $WPFJSONTextBox.Text -Destination $autopilotdir -ErrorAction Stop
            } catch {
                Write-WWLog -data $_.Exception.Message -class Error
                Write-WWLog -data "JSON file couldn't be copied. Check to see if the correct SKU" -Class Error
                Write-WWLog -Data 'of Windows has been selected' -Class Error
                Write-WWLog -Data "The WIM is still mounted. You'll need to clean that up manually until" -Class Error
                Write-WWLog -data 'I get around to handling that error more betterer' -Class Error
                return
            }
        } else {
            Write-WWLog -Data 'JSON not selected. Skipping JSON Injection' -Class Information
        }

        #Inject Drivers
        If ($WPFDriverCheckBox.IsChecked -eq $true) {
            Invoke-WWDriverInjection -Folder $WPFDriverDir1TextBox.text
            Invoke-WWDriverInjection -Folder $WPFDriverDir2TextBox.text
            Invoke-WWDriverInjection -Folder $WPFDriverDir3TextBox.text
            Invoke-WWDriverInjection -Folder $WPFDriverDir4TextBox.text
            Invoke-WWDriverInjection -Folder $WPFDriverDir5TextBox.text
        } Else {
            Write-WWLog -Data 'Drivers were not selected for injection. Skipping.' -Class Information
        }

        #Inject default application association XML
        if ($WPFCustomCBEnableApp.IsChecked -eq $true) {
            Install-DefaultApplicationAssociation
        } else {
            Write-WWLog -Data 'Default Application Association not selected. Skipping...' -Class Information
        }

        #Inject start menu layout
        if ($WPFCustomCBEnableStart.IsChecked -eq $true) {
            Install-StartLayout
        } else {
            Write-WWLog -Data 'Start Menu Layout injection not selected. Skipping...' -Class Information
        }

        #apply registry files
        if ($WPFCustomCBEnableRegistry.IsChecked -eq $true) {
            Install-RegistryFile
        } else {
            Write-WWLog -Data 'Registry file injection not selected. Skipping...' -Class Information
        }

        #Check for updates when ConfigMgr source is selected
        if ($WPFMISCBCheckForUpdates.IsChecked -eq $true) {
            Invoke-MISUpdate
            if (($WPFSourceWIMImgDesTextBox.text -like '*Windows 10*') -or ($WPFSourceWIMImgDesTextBox.text -like '*Windows 11*')) { Get-OneDrive }
        }

        #Apply Updates
        If ($WPFUpdatesEnableCheckBox.IsChecked -eq $true) {
            Deploy-Update -class 'SSU'
            Deploy-Update -class 'LCU'
            Deploy-Update -class 'AdobeSU'
            Deploy-Update -class 'DotNet'
            Deploy-Update -class 'DotNetCU'
            #if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True){Deploy-Update -class "Dynamic"}
            if ($WPFUpdatesOptionalEnableCheckBox.IsChecked -eq $True) {
                Deploy-Update -class 'Optional'
            }
        } else {
            Write-WWLog -Data 'Updates not enabled' -Class Information
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
            Write-WWLog -data 'OneDrive agent update skipped as it was not selected' -Class Information
        }

        #Remove AppX Packages
        if ($WPFAppxCheckBox.IsChecked -eq $true) {
            Deregister-WWAppx -array $appx
        } Else {
            Write-WWLog -Data 'App removal not enabled' -Class Information
        }

        #Run Script before dismount
        if (($WPFCustomCBRunScript.IsChecked -eq $True) -and ($WPFCustomCBScriptTiming.SelectedItem -eq 'Before image dismount')) {
            Invoke-WWScript -file $WPFCustomTBFile.text -parameter $WPFCustomTBParameters.text
        }

        #Pause before dismounting
        If ($WPFMISCBPauseDismount.IsChecked -eq $True) {
            Write-WWLog -Data 'Pausing image building. Waiting on user to continue...' -Class Warning
            $Pause = Suspend-MakeItSo
            if ($Pause -eq 'Yes') { Write-WWLog -data 'Continuing on with making it so...' -Class Information }
            if ($Pause -eq 'No') {
                Write-WWLog -data 'Discarding build...' -Class Error
                Write-WWLog -Data 'Discarding mounted WIM' -Class Warning
                Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Discard -ErrorAction Stop | Out-Null
                Write-WWLog -Data 'WIM has been discarded. Better luck next time.' -Class Warning
                return
            }
        }

        #Copy log to mounted WIM
        try {
            Write-WWLog -Data 'Attempting to copy log to mounted image' -Class Information
            $mountlogdir = $WPFMISMountTextBox.Text + '\windows\'
            Copy-Item $Script:workdir\logging\WIMWitch.log -Destination $mountlogdir -ErrorAction Stop
            $CopyLogExist = Test-Path $mountlogdir\WIMWitch.log -PathType Leaf
            if ($CopyLogExist -eq $true) { Write-WWLog -Data 'Log filed copied successfully' -Class Information }
        } catch {
            Write-WWLog -data $_.Exception.Message -class Error
            Write-WWLog -data "Coudn't copy the log file to the mounted image." -class Error
        }

        #Dismount, commit, and move WIM
        Write-WWLog -Data 'Dismounting WIM file, committing changes' -Class Information
        try {
            Dismount-WindowsImage -Path $WPFMISMountTextBox.Text -Save -ErrorAction Stop | Out-Null
        } catch {
            Write-WWLog -data $_.Exception.Message -class Error
            Write-WWLog -data "The WIM couldn't save. You will have to manually discard the" -Class Error
            Write-WWLog -data 'mounted image manually' -Class Error
            return
        }
        Write-WWLog -Data 'WIM dismounted' -Class Information

        #Display new version number
        $WimInfo = (Get-WindowsImage -ImagePath $wimname -Index 1)
        $text = 'New image version number is ' + $WimInfo.Version
        Write-WWLog -data $text -Class Information

        if (($auto -eq $true) -or ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image')) {
            Write-WWLog -Data 'Backing up old WIM file...' -Class Information
            $checkresult = (Test-Name -conflict append)
            if ($checkresult -eq 'stop') { return }
        }

        #stage media if check boxes are selected
        if (($WPFMISCBUpgradePackage.IsChecked -eq $true) -or ($WPFMISCBISO.IsChecked -eq $true)) {
            Copy-StageIsoMedia
            Write-WWLog -Data 'Exporting install.wim to media staging folder...' -Class Information
            Export-WindowsImage -SourceImagePath $wimname -SourceIndex 1 `
                -DestinationImagePath ($Script:workdir + '\staging\media\sources\install.wim') `
                -DestinationName ('WW - ' + $WPFSourceWIMImgDesTextBox.text) | Out-Null
        }

        #Export the wim file to various locations
        if ($WPFMISCBNoWIM.IsChecked -ne $true) {
            try {
                Write-WWLog -Data 'Exporting WIM file' -Class Information
                Export-WindowsImage -SourceImagePath $wimname -SourceIndex 1 `
                    -DestinationImagePath ($WPFMISWimFolderTextBox.Text + '\' + $WPFMISWimNameTextBox.Text) `
                    -DestinationName ('WW - ' + $WPFSourceWIMImgDesTextBox.text) | Out-Null
            } catch {
                Write-WWLog -data $_.Exception.Message -class Error
                Write-WWLog -data "The WIM couldn't be exported. You can still retrieve it from staging path." -Class Error
                Write-WWLog -data 'The file will be deleted when the tool is rerun.' -Class Error
                return
            }
            Write-WWLog -Data 'WIM successfully exported to target folder' -Class Information
        }

        #ConfigMgr Integration
        if ($WPFCMCBImageType.SelectedItem -ne 'Disabled') {
            #  "New Image","Update Existing Image"
            if ($WPFCMCBImageType.SelectedItem -eq 'New Image') {
                Write-WWLog -data 'Creating a new image in ConfigMgr...' -class Information
                Build-WWCMImagePackage
            }

            if ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image') {
                Write-WWLog -data 'Updating the existing image in ConfigMgr...' -class Information
                Invoke-WWCMImageUpdate
            }
        }

        #Apply Dynamic Update to media
        if ($WPFMISCBDynamicUpdates.IsChecked -eq $true) {
            Deploy-Update -class 'Dynamic'
        } else {
            Write-WWLog -data 'Dynamic Updates skipped or not applicable' -Class Information
        }

        #Apply updates to the boot.wim file
        if ($WPFMISCBBootWIM.IsChecked -eq $true) {
            Invoke-BootWimUpdate
        } else {
            Write-WWLog -data 'Updating Boot.WIM skipped or not applicable' -Class Information
        }

        #Copy upgrade package binaries if selected
        if ($WPFMISCBUpgradePackage.IsChecked -eq $true) {
            Copy-UpgradePackage
        } else {
            Write-WWLog -Data 'Upgrade Package skipped or not applicable' -Class Information
        }

        #Create ISO if selected
        if ($WPFMISCBISO.IsChecked -eq $true) {
            Build-WindowsISO
        } else {
            Write-WWLog -Data 'ISO Creation skipped or not applicable' -Class Information
        }

        #Run Script when build complete
        if (($WPFCustomCBRunScript.IsChecked -eq $True) -and ($WPFCustomCBScriptTiming.SelectedItem -eq 'On build completion')) {
            Invoke-WWScript -file $WPFCustomTBFile.text -parameter $WPFCustomTBParameters.text
        }

        #Clear out staging folder
        try {
            Write-WWLog -Data 'Clearing staging folder...' -Class Information
            Remove-Item $Script:workdir\staging\* -Force -Recurse -ErrorAction Stop
        } catch {
            Write-WWLog -Data 'Could not clear staging folder' -Class Warning
            Write-WWLog -data $_.Exception.Message -class Error
        }

        #Copy log here
        try {
            Write-WWLog -Data 'Copying build log to target folder' -Class Information
            Copy-Item -Path $Script:workdir\logging\WIMWitch.log -Destination $WPFMISWimFolderTextBox.Text -ErrorAction Stop
            $logold = $WPFMISWimFolderTextBox.Text + '\WIMWitch.log'
            $lognew = $WPFMISWimFolderTextBox.Text + '\' + $WPFMISWimNameTextBox.Text + '.log'
            #Put log detection code here
            if ((Test-Path -Path $lognew) -eq $true) {
                Write-WWLog -Data 'A preexisting log file contains the same name. Renaming old log...' -Class Warning
                Rename-Name -file $lognew -extension '.log'
            }

            #Put log detection code here
            Rename-Item $logold -NewName $lognew -Force -ErrorAction Stop
            Write-WWLog -Data 'Log copied successfully' -Class Information
        } catch {
            Write-WWLog -data $_.Exception.Message -class Error
            Write-WWLog -data "The log file couldn't be copied and renamed. You can still snag it from the source." -Class Error
            Write-WWLog -Data "Job's done." -Class Information
            return
        }
        Write-WWLog -Data "Job's done." -Class Information
    }
}

