#region Functions

#Function to augment close out window text
Function Invoke-DadJoke {
    $header = @{accept = 'Application/json' }
    $joke = Invoke-RestMethod -Uri 'https://icanhazdadjoke.com' -Method Get -Headers $header
    return $joke.joke
}

#Function to stage and build installer media
Function Copy-StageIsoMedia {
    # if($WPFSourceWIMImgDesTextBox.Text -like '*Windows 10*'){$OS = 'Windows 10'}
    # if($WPFSourceWIMImgDesTextBox.Text -like '*Server*'){$OS = 'Windows Server'}

    $OS = Get-WindowsType


    #$Ver = (Get-WinVersionNumber)
    $Ver = $MISWinVer


    #create staging folder
    try {
        Update-Log -Data 'Creating staging folder for media' -Class Information
        New-Item -Path $global:workdir\staging -Name 'Media' -ItemType Directory -ErrorAction Stop | Out-Null
        Update-Log -Data 'Media staging folder has been created' -Class Information
    } catch {
        Update-Log -Data 'Could not create staging folder' -Class Error
        Update-Log -data $_.Exception.Message -class Error
    }

    #copy source to staging
    try {
        Update-Log -data 'Staging media binaries...' -Class Information
        Copy-Item -Path $global:workdir\imports\iso\$OS\$Ver\* -Destination $global:workdir\staging\media -Force -Recurse -ErrorAction Stop
        Update-Log -data 'Media files have been staged' -Class Information
    } catch {
        Update-Log -Data 'Failed to stage media binaries...' -Class Error
        Update-Log -data $_.Exception.Message -class Error
    }

}

#Function to create the ISO file from staged installer media
Function New-WindowsISO {

    if ((Test-Path -Path ${env:ProgramFiles(x86)}'\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe' -PathType Leaf) -eq $false) {
        Update-Log -Data 'The file oscdimg.exe was not found. Skipping ISO creation...' -Class Error
        return
    }

    If ($WPFMISTBISOFileName.Text -notlike '*.iso') {

        $WPFMISTBISOFileName.Text = $WPFMISTBISOFileName.Text + '.iso'
        Update-Log -Data 'Appending new file name with an extension' -Class Information
    }

    $Location = ${env:ProgramFiles(x86)}
    $executable = $location + '\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe'
    $bootbin = $global:workdir + '\staging\media\efi\microsoft\boot\efisys.bin'
    $source = $global:workdir + '\staging\media'
    $folder = $WPFMISTBFilePath.text
    $file = $WPFMISTBISOFileName.text
    $dest = "$folder\$file"
    $text = "-b$bootbin"

    if ((Test-Path -Path $dest) -eq $true) { Rename-Name -file $dest -extension '.iso' }
    try {
        Update-Log -Data 'Starting to build ISO...' -Class Information
        # write-host $executable
        Start-Process $executable -args @("`"$text`"", '-pEF', '-u1', '-udfver102', "`"$source`"", "`"$dest`"") -Wait -ErrorAction Stop
        Update-Log -Data 'ISO has been built' -Class Information
    } catch {
        Update-Log -Data "Couldn't create the ISO file" -Class Error
        Update-Log -data $_.Exception.Message -class Error
    }
}

#Function to copy staged installer media to CM Package Share
Function Copy-UpgradePackage {
    #copy staging folder to destination with force parameter
    try {
        Update-Log -data 'Copying updated media to Upgrade Package folder...' -Class Information
        Copy-Item -Path $global:workdir\staging\media\* -Destination $WPFMISTBUpgradePackage.text -Force -Recurse -ErrorAction Stop
        Update-Log -Data 'Updated media has been copied' -Class Information
    } catch {
        Update-Log -Data "Couldn't copy the updated media to the upgrade package folder" -Class Error
        Update-Log -data $_.Exception.Message -class Error
    }

}

#Function to update the boot wim in the staged installer media folder
Function Update-BootWIM {
    #create mount point in staging

    try {
        Update-Log -Data 'Creating mount point in staging folder...'
        New-Item -Path $global:workdir\staging -Name 'mount' -ItemType Directory -ErrorAction Stop
        Update-Log -Data 'Staging folder mount point created successfully' -Class Information
    } catch {
        Update-Log -data 'Failed to create the staging folder mount point' -Class Error
        Update-Log -data $_.Exception.Message -class Error
        return
    }


    #change attribute of boot.wim
    #Change file attribute to normal
    Update-Log -Data 'Setting file attribute of boot.wim to Normal' -Class Information
    $attrib = Get-Item $global:workdir\staging\media\sources\boot.wim
    $attrib.Attributes = 'Normal'

    $BootImages = Get-WindowsImage -ImagePath $global:workdir\staging\media\sources\boot.wim
    Foreach ($BootImage in $BootImages) {

        #Mount the PE Image
        try {
            $text = 'Mounting PE image number ' + $BootImage.ImageIndex
            Update-Log -data $text -Class Information
            Mount-WindowsImage -ImagePath $global:workdir\staging\media\sources\boot.wim -Path $global:workdir\staging\mount -Index $BootImage.ImageIndex -ErrorAction Stop
        } catch {
            Update-Log -Data 'Could not mount the boot.wim' -Class Error
            Update-Log -data $_.Exception.Message -class Error
            return
        }

        Update-Log -data 'Applying SSU Update' -Class Information
        Deploy-Updates -class 'PESSU'
        Update-Log -data 'Applying LCU Update' -Class Information
        Deploy-Updates -class 'PELCU'

        #Dismount the PE Image
        try {
            Update-Log -data 'Dismounting Windows PE image...' -Class Information
            Dismount-WindowsImage -Path $global:workdir\staging\mount -Save -ErrorAction Stop
        } catch {
            Update-Log -data 'Could not dismount the winpe image.' -Class Error
            Update-Log -data $_.Exception.Message -class Error
        }

        #Export the WinPE Image
        Try {
            Update-Log -data 'Exporting WinPE image index...' -Class Information
            Export-WindowsImage -SourceImagePath $global:workdir\staging\media\sources\boot.wim -SourceIndex $BootImage.ImageIndex -DestinationImagePath $global:workdir\staging\tempboot.wim -ErrorAction Stop
        } catch {
            Update-Log -Data 'Failed to export WinPE image' -Class Error
            Update-Log -data $_.Exception.Message -class Error
        }

    }

    #Overwrite the stock boot.wim file with the updated one
    try {
        Update-Log -Data 'Overwriting boot.wim with updated and optimized version...' -Class Information
        Move-Item -Path $global:workdir\staging\tempboot.wim -Destination $global:workdir\staging\media\sources\boot.wim -Force -ErrorAction Stop
        Update-Log -Data 'Boot.WIM updated successfully' -Class Information
    } catch {
        Update-Log -Data 'Could not copy the updated boot.wim' -Class Error
        Update-Log -data $_.Exception.Message -class Error
    }
}

#Function to update windows recovery in the mounted offline image
Function Update-WinReWim {
    #create mount point in staging
    #copy winre from mounted offline image
    #change attribute of winre.wim
    #mount staged winre.wim
    #update, dismount
    #copy wim back to mounted offline image
}

#Function to retrieve windows version
Function Get-WinVersionNumber {
    $buildnum = $null

    # Latest 10 Windows 10 version checks
    switch -Regex ($WPFSourceWimVerTextBox.text) {
        
        #Windows 10 version checks
        '10\.0\.19044\.\d+' { $buildnum = '21H2' }
        '10\.0\.19045\.\d+' { $buildnum = '22H2' }

        # Windows 11 version checks
        '10\.0\.22000\.\d+' { $buildnum = '21H2' }
        '10\.0\.22621\.\d+' { $buildnum = '22H2' }
        '10\.0\.22631\.\d+' { $buildnum = '23H2' }


        Default { $buildnum = 'Unknown Version' }
    }



    If ($WPFSourceWimVerTextBox.text -like '10.0.19041.*') {
        $IsMountPoint = $False
        $currentmounts = Get-WindowsImage -Mounted
        foreach ($currentmount in $currentmounts) {
            if ($currentmount.path -eq $WPFMISMountTextBox.text) { $IsMountPoint = $true }
        }

        #IS a mount path
        If ($IsMountPoint -eq $true) {
            $mountdir = $WPFMISMountTextBox.Text
            reg LOAD HKLM\OFFLINE $mountdir\Windows\System32\Config\SOFTWARE | Out-Null
            $regvalues = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\OFFLINE\Microsoft\Windows NT\CurrentVersion\' )
            $buildnum = $regvalues.ReleaseId
            if ($regvalues.ReleaseId -eq '2009') {
                if ($regvalues.CurrentBuild -eq '19042') { $buildnum = '2009' }
                if ($regvalues.CurrentBuild -eq '19043') { $buildnum = '21H1' }
                if ($regvalues.CurrentBuild -eq '19044') { $buildnum = '21H2' }
                if ($regvalues.CurrentBuild -eq '19045') { $buildnum = '22H2' }
            }

            reg UNLOAD HKLM\OFFLINE | Out-Null


        }

        If ($IsMountPoint -eq $False) {
            $global:Win10VerDet = $null

            Update-Log -data 'Prompting user for Win10 version confirmation...' -class Information

            Invoke-19041Select

            if ($null -eq $global:Win10VerDet) { return }

            $temp = $global:Win10VerDet

            $buildnum = $temp
            Update-Log -data "User selected $buildnum" -class Information

            $global:Win10VerDet = $null

        }
    }

    return $buildnum
}

#funcation to select ISO creation path
Function Select-ISODirectory {

    Add-Type -AssemblyName System.Windows.Forms
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog
    $browser.Description = 'Select the folder to save the ISO'
    $null = $browser.ShowDialog()
    $MountDir = $browser.SelectedPath
    $WPFMISTBFilePath.text = $MountDir
    #Test-MountPath -path $WPFMISMountTextBox.text
    Update-Log -Data 'ISO directory selected' -Class Information
}

#Function to determine if WIM is Win10 or Windows Server
Function Get-WindowsType {
    if ($WPFSourceWIMImgDesTextBox.text -like '*Windows 10*') { $type = 'Windows 10' }
    if ($WPFSourceWIMImgDesTextBox.text -like '*Windows Server*') { $type = 'Windows Server' }
    if ($WPFSourceWIMImgDesTextBox.text -like '*Windows 11*') { $type = 'Windows 11' }

    Return $type
}

#Function to check if ISO binaries exist
Function Test-IsoBinariesExist {
    $buildnum = Get-WinVersionNumber
    $OSType = get-Windowstype


    $ISOFiles = $global:workdir + '\imports\iso\' + $OSType + '\' + $buildnum + '\'

    Test-Path -Path $ISOFiles\*
    if ((Test-Path -Path $ISOFiles\*) -eq $false) {
        $text = 'ISO Binaries are not present for ' + $OSType + ' ' + $buildnum
        Update-Log -Data $text -Class Warning
        Update-Log -data 'Import ISO Binaries from an ISO or disable ISO/Upgrade Package creation' -Class Warning
        return $false
    }
}

#Function to clear partial checkboxes when importing config file
Function Invoke-CheckboxCleanup {
    Update-Log -Data 'Cleaning null checkboxes...' -Class Information
    $Variables = Get-Variable WPF*
    foreach ($variable in $variables) {

        if ($variable.value -like '*.CheckBox*') {
            #write-host $variable.name
            #write-host $variable.value.IsChecked
            if ($variable.value.IsChecked -ne $true) { $variable.value.IsChecked = $false }
        }
    }
}

#Function to really make sure the ISO mount is gone!
Function Invoke-RemoveISOMount ($inputObject) {
    DO {
        Dismount-DiskImage -InputObject $inputObject
    }
    while (Dismount-DiskImage -InputObject $inputObject)
    #He's dead Jim!
    Update-Log -data 'Dismount complete' -class Information
}

#Function to install CM Console extensions
Function Install-WWCMConsoleExtension {
    $UpdateWWXML = @"
<ActionDescription Class ="Executable" DisplayName="Update with WIM Witch" MnemonicDisplayName="Update with WIM Witch" Description="Click to update the image with WIM Witch">
	<ShowOn>
		<string>ContextMenu</string>
		<string>DefaultHomeTab</string>
	</ShowOn>
	<Executable>
		<FilePath>$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe</FilePath>
		<Parameters> -ExecutionPolicy Bypass -File "$PSCommandPath" -auto -autofile "$global:workdir\ConfigMgr\PackageInfo\##SUB:PackageID##"</Parameters>
	</Executable>
</ActionDescription>
"@

    $EditWWXML = @"
<ActionDescription Class ="Executable" DisplayName="Edit WIM Witch Image Config" MnemonicDisplayName="Edit WIM Witch Image Config" Description="Click to edit the WIM Witch image configuration">
	<ShowOn>
		<string>ContextMenu</string>
		<string>DefaultHomeTab</string>
	</ShowOn>
	<Executable>
		<FilePath>$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe</FilePath>
		<Parameters> -ExecutionPolicy Bypass -File "$PSCommandPath" -CM "Edit" -autofile "$global:workdir\ConfigMgr\PackageInfo\##SUB:PackageID##"</Parameters>
	</Executable>
</ActionDescription>
"@

    $NewWWXML = @"
<ActionDescription Class ="Executable" DisplayName="New WIM Witch Image" MnemonicDisplayName="New WIM Witch Image" Description="Click to create a new WIM Witch image">
	<ShowOn>
		<string>ContextMenu</string>
		<string>DefaultHomeTab</string>
	</ShowOn>
	<Executable>
		<FilePath>$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe</FilePath>
		<Parameters> -ExecutionPolicy Bypass -File "$PSCommandPath" -CM "New"</Parameters>
	</Executable>
</ActionDescription>
"@

    Update-Log -Data 'Installing ConfigMgr console extension...' -Class Information

    $ConsoleFolderImage = '828a154e-4c7d-4d7f-ba6c-268443cdb4e8' #folder for update and edit

    $ConsoleFolderRoot = 'ac16f420-2d72-4056-a8f6-aef90e66a10c' #folder for new

    $path = ($env:SMS_ADMIN_UI_PATH -replace 'bin\\i386', '') + 'XmlStorage\Extensions\Actions'

    Update-Log -Data 'Creating folders if needed...' -Class Information

    if ((Test-Path -Path (Join-Path -Path $path -ChildPath $ConsoleFolderImage)) -eq $false) { New-Item -Path $path -Name $ConsoleFolderImage -ItemType 'directory' | Out-Null }

    Update-Log -data 'Creating extension files...' -Class Information

    $UpdateWWXML | Out-File ((Join-Path -Path $path -ChildPath $ConsoleFolderImage) + '\UpdateWWImage.xml') -Force
    $EditWWXML | Out-File ((Join-Path -Path $path -ChildPath $ConsoleFolderImage) + '\EditWWImage.xml') -Force

    Update-Log -Data 'Creating folders if needed...' -Class Information

    if ((Test-Path -Path (Join-Path -Path $path -ChildPath $ConsoleFolderRoot)) -eq $false) { New-Item -Path $path -Name $ConsoleFolderRoot -ItemType 'directory' | Out-Null }
    Update-Log -data 'Creating extension files...' -Class Information

    $NewWWXML | Out-File ((Join-Path -Path $path -ChildPath $ConsoleFolderRoot) + '\NewWWImage.xml') -Force

    Update-Log -Data 'Console extension installation complete!' -Class Information
}

#Function to handle 32-Bit PowerSehell
Function Invoke-ArchitectureCheck {
    if ([Environment]::Is64BitProcess -ne [Environment]::Is64BitOperatingSystem) {

        Update-Log -Data 'This is 32-bit PowerShell session. Will relaunch as 64-bit...' -Class Warning

        #The following If statment was pilfered from Michael Niehaus
        if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {

            if (($auto -eq $false) -and ($CM -eq 'None')) { & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" }
            if (($auto -eq $true) -and ($null -ne $autofile)) { & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -auto -autofile $autofile }
            if (($CM -eq 'Edit') -and ($null -ne $autofile)) { & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -CM Edit -autofile $autofile }
            if ($CM -eq 'New') { & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -CM New }

            Exit $lastexitcode
        }
    } else {
        Update-Log -Data 'This is a 64 bit PowerShell session' -Class Information


    }
}

#Function to download and extract the SSU required for 2004/20H2 June '21 LCU
Function Invoke-2XXXPreReq {
    $KB_URI = 'http://download.windowsupdate.com/c/msdownload/update/software/secu/2021/05/windows10.0-kb5003173-x64_375062f9d88a5d9d11c5b99673792fdce8079e09.cab'
    $executable = "$env:windir\system32\expand.exe"
    $mountdir = $WPFMISMountTextBox.Text

    Update-Log -data 'Mounting offline registry and validating UBR / Patch level...' -class Information
    reg LOAD HKLM\OFFLINE $mountdir\Windows\System32\Config\SOFTWARE | Out-Null
    $regvalues = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\OFFLINE\Microsoft\Windows NT\CurrentVersion\' )


    Update-Log -data 'The UBR (Patch Level) is:' -class Information
    Update-Log -data $regvalues.ubr -class information
    reg UNLOAD HKLM\OFFLINE | Out-Null

    if ($null -eq $regvalues.ubr) {
        Update-Log -data "Registry key wasn't copied. Can't continue." -class Error
        return 1
    }

    if ($regvalues.UBR -lt '985') {

        Update-Log -data 'The image requires an additional required SSU.' -class Information
        Update-Log -data 'Checking to see if the required SSU exists...' -class Information
        if ((Test-Path "$global:workdir\updates\Windows 10\2XXX_prereq\SSU-19041.985-x64.cab") -eq $false) {
            Update-Log -data 'The required SSU does not exist. Downloading it now...' -class Information

            try {
                Invoke-WebRequest -Uri $KB_URI -OutFile "$global:workdir\staging\extract_me.cab" -ErrorAction stop
            } catch {
                Update-Log -data 'Failed to download the update' -class Error
                Update-Log -data $_.Exception.Message -Class Error
                return 1
            }

            if ((Test-Path "$global:workdir\updates\Windows 10\2XXX_prereq") -eq $false) {


                try {
                    Update-Log -data 'The folder for the required SSU does not exist. Creating it now...' -class Information
                    New-Item -Path "$global:workdir\updates\Windows 10" -Name '2XXX_prereq' -ItemType Directory -ErrorAction stop | Out-Null
                    Update-Log -data 'The folder has been created' -class information
                } catch {
                    Update-Log -data 'Could not create the required folder.' -class error
                    Update-Log -data $_.Exception.Message -Class Error
                    return 1
                }
            }

            try {
                Update-Log -data 'Extracting the SSU from the May 2021 LCU...' -class Information
                Start-Process $executable -args @("`"$global:workdir\staging\extract_me.cab`"", '/f:*SSU*.CAB', "`"$global:workdir\updates\Windows 10\2XXX_prereq`"") -Wait -ErrorAction Stop
                Update-Log 'Extraction of SSU was success' -class information
            } catch {
                Update-Log -data "Couldn't extract the SSU from the LCU" -class error
                Update-Log -data $_.Exception.Message -Class Error
                return 1

            }


            try {
                Update-Log -data 'Deleting the staged LCU file...' -class Information
                Remove-Item -Path $global:workdir\staging\extract_me.cab -Force -ErrorAction stop | Out-Null
                Update-Log -data 'The source file for the SSU has been Baleeted!' -Class Information
            } catch {
                Update-Log -data 'Could not delete the source package' -Class Error
                Update-Log -data $_.Exception.Message -Class Error
                return 1
            }
        } else {
            Update-Log -data 'The required SSU exists. No need to download' -Class Information
        }

        try {
            Update-Log -data 'Applying the SSU...' -class Information
            Add-WindowsPackage -PackagePath "$global:workdir\updates\Windows 10\2XXX_prereq" -Path $WPFMISMountTextBox.Text -ErrorAction Stop | Out-Null
            Update-Log -data 'SSU applied successfully' -class Information

        } catch {
            Update-Log -data "Couldn't apply the SSU update" -class error
            Update-Log -data $_.Exception.Message -Class Error
            return 1
        }
    } else {
        Update-Log -Data "Image doesn't require the prereq SSU" -Class Information
    }

    Update-Log -data 'SSU remdiation complete' -Class Information
    return 0
}

#Function to display text notification to end user
Function Invoke-TextNotification {
    Update-Log -data '*********************************' -class Comment
    Update-Log -data '*********************************' -class Comment
}

#Function to display Windows 10 v2XXX selection pop up
Function Invoke-19041Select {
    $inputXML = @'
<Window x:Class="popup.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:popup"
        mc:Ignorable="d"
        Title="Select Win10 Version" Height="170" Width="353">
    <Grid x:Name="Win10PU" Margin="0,0,10,6">
        <ComboBox x:Name="Win10PUCombo" HorizontalAlignment="Left" Margin="40,76,0,0" VerticalAlignment="Top" Width="120"/>
        <Button x:Name="Win10PUOK" Content="OK" HorizontalAlignment="Left" Margin="182,76,0,0" VerticalAlignment="Top" Width="50"/>
        <Button x:Name="Win10PUCancel" Content="Cancel" HorizontalAlignment="Left" Margin="248,76,0,0" VerticalAlignment="Top" Width="50"/>
        <TextBlock x:Name="Win10PUText" HorizontalAlignment="Left" Margin="24,27,0,0" Text="Please selet the correct version of Windows 10." TextWrapping="Wrap" VerticalAlignment="Top" Grid.ColumnSpan="2"/>

    </Grid>
</Window>

'@

    $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window'
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = $inputXML
    #Read XAML

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    try {
        $Form = [Windows.Markup.XamlReader]::Load( $reader )
    } catch {
        Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
        throw
    }

    $xaml.SelectNodes('//*[@Name]') | ForEach-Object { "trying item $($_.Name)" | Out-Null
        try { Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop }
        catch { throw }
    }

    Get-FormVariables | Out-Null

    #Combo Box population
    $Win10VerNums = @('20H2', '21H1', '21H2', '22H2')
    Foreach ($Win10VerNum in $Win10VerNums) { $WPFWin10PUCombo.Items.Add($Win10VerNum) | Out-Null }


    #Button_OK_Click
    $WPFWin10PUOK.Add_Click({
            $global:Win10VerDet = $WPFWin10PUCombo.SelectedItem
            $Form.Close()
            return
        })

    #Button_Cancel_Click
    $WPFWin10PUCancel.Add_Click({
            $global:Win10VerDet = $null
            Update-Log -data 'User cancelled the confirmation dialog box' -Class Warning
            $Form.Close()
            return
        })


    $Form.ShowDialog() | Out-Null

}

#Function for the Make it So button
Function Invoke-MakeItSo ($appx) {
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
        Export-WindowsImage -SourceImagePath $wimname -SourceIndex 1 -DestinationImagePath ($global:workdir + '\staging\media\sources\install.wim') -DestinationName ('WW - ' + $WPFSourceWIMImgDesTextBox.text) | Out-Null
    }

    #Export the wim file to various locations
    if ($WPFMISCBNoWIM.IsChecked -ne $true) {
        try {
            Update-Log -Data 'Exporting WIM file' -Class Information
            Export-WindowsImage -SourceImagePath $wimname -SourceIndex 1 -DestinationImagePath ($WPFMISWimFolderTextBox.Text + '\' + $WPFMISWimNameTextBox.Text) -DestinationName ('WW - ' + $WPFSourceWIMImgDesTextBox.text) | Out-Null
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

#endregion Functions