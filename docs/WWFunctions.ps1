#region Functions

#Function to apply selected FODs to the mounted WIM
Function Install-FeaturesOnDemand {
    Update-Log -data 'Applying Features On Demand...' -Class Information

    $mountdir = $WPFMISMountTextBox.text

    $WinOS = Get-WindowsType
    $Winver = Get-WinVersionNumber

    if (($WinOS -eq 'Windows 10') -and (($winver -eq '20H2') -or ($winver -eq '21H1') -or ($winver -eq '2009') -or ($winver -eq '21H2') -or ($winver -eq '22H2'))) { $winver = '2004' }


    $FODsource = $global:workdir + '\imports\FODs\' + $winOS + '\' + $Winver + '\'
    $items = $WPFCustomLBFOD.items

    foreach ($item in $items) {
        $text = 'Applying ' + $item
        Update-Log -Data $text -Class Information

        try {
            Add-WindowsCapability -Path $mountdir -Name $item -Source $FODsource -ErrorAction Stop | Out-Null
            Update-Log -Data 'Injection Successful' -Class Information
        } catch {
            Update-Log -data 'Failed to apply Feature On Demand' -Class Error
            Update-Log -data $_.Exception.Message -Class Error
        }


    }
    Update-Log -Data 'Feature on Demand injections complete' -Class Information
}

#Function to import the selected LP's in to the Imports folder
Function Import-LanguagePacks($Winver, $LPSourceFolder, $WinOS) {
    Update-Log -Data 'Importing Language Packs...' -Class Information

    #Note To Donna - Make a step that checks if $winver -eq 1903, and if so, set $winver to 1909
    if ($winver -eq '1903') {
        Update-Log -Data 'Changing version variable because 1903 and 1909 use the same packages' -Class Information
        $winver = '1909'
    }

    if ((Test-Path -Path $global:workdir\imports\Lang\$WinOS\$winver\LanguagePacks) -eq $False) {
        Update-Log -Data 'Destination folder does not exist. Creating...' -Class Warning
        $path = $global:workdir + '\imports\Lang\' + $WinOS + '\' + $winver + '\LanguagePacks'
        $text = 'Creating folder ' + $path
        Update-Log -data $text -Class Information
        New-Item -Path $global:workdir\imports\Lang\$WinOS\$winver -Name LanguagePacks -ItemType Directory
        Update-Log -Data 'Folder created successfully' -Class Information
    }

    $items = $WPFImportOtherLBList.items
    foreach ($item in $items) {
        $source = $LPSourceFolder + $item
        $text = 'Importing ' + $item
        Update-Log -Data $text -Class Information
        Copy-Item $source -Destination $global:workdir\imports\Lang\$WinOS\$Winver\LanguagePacks -Force
    }
    Update-Log -Data 'Importation Complete' -Class Information
}

#Function to import the selected LXP's into the imports forlder
Function Import-LocalExperiencePack($Winver, $LPSourceFolder, $WinOS) {

    if ($winver -eq '1903') {
        Update-Log -Data 'Changing version variable because 1903 and 1909 use the same packages' -Class Information
        $winver = '1909'
    }

    Update-Log -Data 'Importing Local Experience Packs...' -Class Information

    if ((Test-Path -Path $global:workdir\imports\Lang\$WinOS\$winver\localexperiencepack) -eq $False) {
        Update-Log -Data 'Destination folder does not exist. Creating...' -Class Warning
        $path = $global:workdir + '\imports\Lang\' + $WinOS + '\' + $winver + '\localexperiencepack'
        $text = 'Creating folder ' + $path
        Update-Log -data $text -Class Information
        New-Item -Path $global:workdir\imports\Lang\$WinOS\$winver -Name localexperiencepack -ItemType Directory
        Update-Log -Data 'Folder created successfully' -Class Information
    }

    $items = $WPFImportOtherLBList.items
    foreach ($item in $items) {
        $name = $item
        $source = $LPSourceFolder + $name
        $text = 'Creating destination folder for ' + $item
        Update-Log -Data $text -Class Information

        if ((Test-Path -Path $global:workdir\imports\lang\$WinOS\$winver\localexperiencepack\$name) -eq $False) { New-Item -Path $global:workdir\imports\lang\$WinOS\$winver\localexperiencepack -Name $name -ItemType Directory }
        else {
            $text = 'The folder for ' + $item + ' already exists. Skipping creation...'
            Update-Log -Data $text -Class Warning
        }

        Update-Log -Data 'Copying source to destination folders...' -Class Information
        Get-ChildItem -Path $source | Copy-Item -Destination $global:workdir\imports\Lang\$WinOS\$Winver\LocalExperiencePack\$name -Force
    }
    Update-log -Data 'Importation complete' -Class Information
}

#Function to import the contents of the selected FODs into the imports forlder
Function Import-FeatureOnDemand($Winver, $LPSourceFolder, $WinOS) {

    if ($winver -eq '1903') {
        Update-Log -Data 'Changing version variable because 1903 and 1909 use the same packages' -Class Information
        $winver = '1909'
    }

    $path = $WPFImportOtherTBPath.text
    $text = 'Starting importation of Feature On Demand binaries from ' + $path
    Update-Log -Data $text -Class Information

    $langpacks = Get-ChildItem -Path $LPSourceFolder

    if ((Test-Path -Path $global:workdir\imports\FODs\$WinOS\$Winver) -eq $False) {
        Update-Log -Data 'Destination folder does not exist. Creating...' -Class Warning
        $path = $global:workdir + '\imports\FODs\' + $WinOS + '\' + $winver
        $text = 'Creating folder ' + $path
        Update-Log -data $text -Class Information
        New-Item -Path $global:workdir\imports\fods\$WinOS -Name $winver -ItemType Directory
        Update-Log -Data 'Folder created successfully' -Class Information
    }
    #If Windows 11

    if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') {
        $items = $WPFImportOtherLBList.items
        foreach ($item in $items) {
            $source = $LPSourceFolder + $item
            $text = 'Importing ' + $item
            Update-Log -Data $text -Class Information
            Copy-Item $source -Destination $global:workdir\imports\FODs\$WinOS\$Winver\ -Force
        }

    }


    #If not Windows 11
    if ($WPFImportOtherCBWinOS.SelectedItem -ne 'Windows 11') {
        foreach ($langpack in $langpacks) {
            $source = $LPSourceFolder + $langpack.name

            Copy-Item $source -Destination $global:workdir\imports\FODs\$WinOS\$Winver\ -Force
            $name = $langpack.name
            $text = 'Copying ' + $name
            Update-Log -Data $text -Class Information

        }
    }

    Update-Log -Data 'Importing metadata subfolder...' -Class Information
    Get-ChildItem -Path ($LPSourceFolder + '\metadata\') | Copy-Item -Destination $global:workdir\imports\FODs\$WinOS\$Winver\metadata -Force
    Update-Log -data 'Feature On Demand imporation complete.'
}

#Function to update winver cobmo box
Function Update-ImportVersionCB {
    $WPFImportOtherCBWinVer.Items.Clear()
    if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows Server') { Foreach ($WinSrvVer in $WinSrvVer) { $WPFImportOtherCBWinVer.Items.Add($WinSrvVer) } }
    if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 10') { Foreach ($Win10Ver in $Win10ver) { $WPFImportOtherCBWinVer.Items.Add($Win10Ver) } }
    if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') { Foreach ($Win11Ver in $Win11ver) { $WPFImportOtherCBWinVer.Items.Add($Win11Ver) } }
}

#Function to select other object import source path
Function Select-ImportOtherPath {
    Add-Type -AssemblyName System.Windows.Forms
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog
    $browser.Description = 'Source folder'
    $null = $browser.ShowDialog()
    $ImportPath = $browser.SelectedPath + '\'
    $WPFImportOtherTBPath.text = $ImportPath

}

#Function to allow user to pause MAke it so process
Function Suspend-MakeItSo {
    $MISPause = ([System.Windows.MessageBox]::Show('Click Yes to continue the image build. Click No to cancel and discard the wim file.', 'WIM Witch Paused', 'YesNo', 'Warning'))
    if ($MISPause -eq 'Yes') { return 'Yes' }

    if ($MISPause -eq 'No') { return 'No' }
}

#Function to run a powershell script with supplied paramenters
Function Start-Script($file, $parameter) {
    $string = "$file $parameter"
    try {
        Update-Log -Data 'Running script' -Class Information
        Invoke-Expression -Command $string -ErrorAction Stop
        Update-Log -data 'Script complete' -Class Information
    } catch {
        Update-Log -Data 'Script failed' -Class Error
    }
}

#Function to select existing configMgr image package
Function Get-ImageInfo {
    Param(
        [parameter(mandatory = $true)]
        [string]$PackID

    )


    #set-ConfigMgrConnection
    Set-Location $CMDrive
    $image = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_ImagePackage -ComputerName $global:SiteServer) | Where-Object { ($_.PackageID -eq $PackID) }

    $WPFCMTBImageName.text = $image.name
    $WPFCMTBWinBuildNum.text = $image.ImageOSversion
    $WPFCMTBPackageID.text = $image.PackageID
    $WPFCMTBImageVer.text = $image.version
    $WPFCMTBDescription.text = $image.Description

    $text = 'Image ' + $WPFCMTBImageName.text + ' selected'
    Update-Log -data $text -class Information

    $text = 'Package ID is ' + $image.PackageID
    Update-Log -data $text -class Information

    $text = 'Image build number is ' + $image.ImageOSversion
    Update-Log -data $text -class Information

    $packageID = (Get-CMOperatingSystemImage -Id $image.PackageID)
    # $packageID.PkgSourcePath

    $WPFMISWimFolderTextBox.text = (Split-Path -Path $packageID.PkgSourcePath)
    $WPFMISWimNameTextBox.text = (Split-Path -Path $packageID.PkgSourcePath -Leaf)

    $Package = $packageID.PackageID
    $DPs = Get-CMDistributionPoint
    $NALPaths = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -ComputerName $global:SiteServer -Query "SELECT * FROM SMS_DistributionPoint WHERE PackageID='$Package'")

    Update-Log -Data 'Retrieving Distrbution Point Information' -Class Information
    foreach ($NALPath in $NALPaths) {
        foreach ($dp in $dps) {
            $DPPath = $dp.NetworkOSPath
            if ($NALPath.ServerNALPath -like ("*$DPPath*")) {
                Update-Log -data "Image has been previously distributed to $DPPath" -class Information
                $WPFCMLBDPs.Items.Add($DPPath)

            }
        }
    }

    #Detect Binary Diff Replication
    Update-Log -data 'Checking Binary Differential Replication setting' -Class Information
    if ($image.PkgFlags -eq ($image.PkgFlags -bor 0x04000000)) {
        $WPFCMCBBinDirRep.IsChecked = $True
    } else {
        $WPFCMCBBinDirRep.IsChecked = $False
    }

    #Detect Package Share Enabled
    Update-Log -data 'Checking package share settings' -Class Information
    if ($image.PkgFlags -eq ($image.PkgFlags -bor 0x80)) {
        $WPFCMCBDeploymentShare.IsChecked = $true
    } else
    { $WPFCMCBDeploymentShare.IsChecked = $false }

    Set-Location $global:workdir
}

#Function to select DP's from ConfigMgr
Function Select-DistributionPoints {
    #set-ConfigMgrConnection
    Set-Location $CMDrive

    if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Points') {

        $SelectedDPs = (Get-CMDistributionPoint -SiteCode $global:sitecode).NetworkOSPath | Out-GridView -Title 'Select Distribution Points' -PassThru
        foreach ($SelectedDP in $SelectedDPs) { $WPFCMLBDPs.Items.Add($SelectedDP) }
    }
    if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Point Groups') {
        $SelectedDPs = (Get-CMDistributionPointGroup).Name | Out-GridView -Title 'Select Distribution Point Groups' -PassThru
        foreach ($SelectedDP in $SelectedDPs) { $WPFCMLBDPs.Items.Add($SelectedDP) }
    }
    Set-Location $global:workdir
}

#Function to create the new image in ConfigMgr
Function New-CMImagePackage {
    #set-ConfigMgrConnection
    Set-Location $CMDrive
    $Path = $WPFMISWimFolderTextBox.text + '\' + $WPFMISWimNameTextBox.text

    try {
        New-CMOperatingSystemImage -Name $WPFCMTBImageName.text -Path $Path -ErrorAction Stop
        Update-Log -data 'Image was created. Check ConfigMgr console' -Class Information
    } catch {
        Update-Log -data 'Failed to create the image' -Class Error
        Update-Log -data $_.Exception.Message -Class Error
    }

    $PackageID = (Get-CMOperatingSystemImage -Name $WPFCMTBImageName.text).PackageID
    Update-Log -Data "The Package ID of the new image is $PackageID" -Class Information

    Set-ImageProperties -PackageID $PackageID

    Update-Log -Data 'Retriveing Distribution Point information...' -Class Information
    $DPs = $WPFCMLBDPs.Items

    foreach ($DP in $DPs) {
        # Hello! This line was written on 3/3/2020.
        $DP = $DP -replace '\\', ''

        Update-Log -Data 'Distributiong image package content...' -Class Information
        if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Points') {
            Start-CMContentDistribution -OperatingSystemImageId $PackageID -DistributionPointName $DP
        }
        if ($WPFCMCBDPDPG.SelectedItem -eq 'Distribution Point Groups') {
            Start-CMContentDistribution -OperatingSystemImageId $PackageID -DistributionPointGroupName $DP
        }

        Update-Log -Data 'Content has been distributed.' -Class Information
    }

    Save-Configuration -CM $PackageID
    Set-Location $global:workdir
}

#Function to enable/disable options on ConfigMgr tab
Function Enable-ConfigMgrOptions {

    #"Disabled","New Image","Update Existing Image"
    if ($WPFCMCBImageType.SelectedItem -eq 'New Image') {
        $WPFCMBAddDP.IsEnabled = $True
        $WPFCMBRemoveDP.IsEnabled = $True
        $WPFCMBSelectImage.IsEnabled = $False
        $WPFCMCBBinDirRep.IsEnabled = $True
        $WPFCMCBDPDPG.IsEnabled = $True
        $WPFCMLBDPs.IsEnabled = $True
        $WPFCMTBDescription.IsEnabled = $True
        $WPFCMTBImageName.IsEnabled = $True
        $WPFCMTBImageVer.IsEnabled = $True
        $WPFCMTBPackageID.IsEnabled = $False
        #        $WPFCMTBSitecode.IsEnabled = $True
        #        $WPFCMTBSiteServer.IsEnabled = $True
        $WPFCMTBWinBuildNum.IsEnabled = $False
        $WPFCMCBImageVerAuto.IsEnabled = $True
        $WPFCMCBDescriptionAuto.IsEnabled = $True
        $WPFCMCBDeploymentShare.IsEnabled = $True


        # $MEMCMsiteinfo = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification"
        # $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
        # $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'
        Update-Log -data 'ConfigMgr feature enabled. New Image selected' -class Information
        #    Update-Log -data $WPFCMTBSitecode.text -class Information
        #    Update-Log -data $WPFCMTBSiteServer.text -class Information
    }

    if ($WPFCMCBImageType.SelectedItem -eq 'Update Existing Image') {
        $WPFCMBAddDP.IsEnabled = $False
        $WPFCMBRemoveDP.IsEnabled = $False
        $WPFCMBSelectImage.IsEnabled = $True
        $WPFCMCBBinDirRep.IsEnabled = $True
        $WPFCMCBDPDPG.IsEnabled = $False
        $WPFCMLBDPs.IsEnabled = $False
        $WPFCMTBDescription.IsEnabled = $True
        $WPFCMTBImageName.IsEnabled = $False
        $WPFCMTBImageVer.IsEnabled = $True
        $WPFCMTBPackageID.IsEnabled = $True
        $WPFCMTBSitecode.IsEnabled = $True
        $WPFCMTBSiteServer.IsEnabled = $True
        $WPFCMTBWinBuildNum.IsEnabled = $False
        $WPFCMCBImageVerAuto.IsEnabled = $True
        $WPFCMCBDescriptionAuto.IsEnabled = $True
        $WPFCMCBDeploymentShare.IsEnabled = $True

        #  $MEMCMsiteinfo = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification"
        #  $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
        #  $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'
        Update-Log -data 'ConfigMgr feature enabled. Update an existing image selected' -class Information
        #   Update-Log -data $WPFCMTBSitecode.text -class Information
        #   Update-Log -data $WPFCMTBSiteServer.text -class Information
    }

    if ($WPFCMCBImageType.SelectedItem -eq 'Disabled') {
        $WPFCMBAddDP.IsEnabled = $False
        $WPFCMBRemoveDP.IsEnabled = $False
        $WPFCMBSelectImage.IsEnabled = $False
        $WPFCMCBBinDirRep.IsEnabled = $False
        $WPFCMCBDPDPG.IsEnabled = $False
        $WPFCMLBDPs.IsEnabled = $False
        $WPFCMTBDescription.IsEnabled = $False
        $WPFCMTBImageName.IsEnabled = $False
        $WPFCMTBImageVer.IsEnabled = $False
        $WPFCMTBPackageID.IsEnabled = $False
        #       $WPFCMTBSitecode.IsEnabled = $False
        #       $WPFCMTBSiteServer.IsEnabled = $False
        $WPFCMTBWinBuildNum.IsEnabled = $False
        $WPFCMCBImageVerAuto.IsEnabled = $False
        $WPFCMCBDescriptionAuto.IsEnabled = $False
        $WPFCMCBDeploymentShare.IsEnabled = $False
        Update-Log -data 'ConfigMgr feature disabled' -class Information

    }

}

#Function to update DP's when updating existing image file in ConfigMgr
Function Update-CMImage {
    #set-ConfigMgrConnection
    Set-Location $CMDrive
    $wmi = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_ImagePackage -ComputerName $global:SiteServer) | Where-Object { $_.PackageID -eq $WPFCMTBPackageID.text }



    Update-Log -Data 'Updating images on the Distribution Points...'
    $WMI.RefreshPkgSource() | Out-Null

    Update-Log -Data 'Refreshing image proprties from the WIM' -Class Information
    $WMI.ReloadImageProperties() | Out-Null

    Set-ImageProperties -PackageID $WPFCMTBPackageID.Text
    Save-Configuration -CM -filename $WPFCMTBPackageID.Text

    Set-Location $global:workdir
}

#Function to enable disable & options on the Software Update Catalog tab
Function Invoke-UpdateTabOptions {

    if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'None' ) {

        $WPFUpdateOSDBUpdateButton.IsEnabled = $false
        $WPFUpdatesDownloadNewButton.IsEnabled = $false
        $WPFUpdatesW10Main.IsEnabled = $false
        $WPFUpdatesS2019.IsEnabled = $false
        $WPFUpdatesS2016.IsEnabled = $false

        $WPFMISCBCheckForUpdates.IsEnabled = $false
        $WPFMISCBCheckForUpdates.IsChecked = $false

    }

    if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'OSDSUS') {
        $WPFUpdateOSDBUpdateButton.IsEnabled = $true
        $WPFUpdatesDownloadNewButton.IsEnabled = $true
        $WPFUpdatesW10Main.IsEnabled = $true
        $WPFUpdatesS2019.IsEnabled = $true
        $WPFUpdatesS2016.IsEnabled = $true

        $WPFMISCBCheckForUpdates.IsEnabled = $false
        $WPFMISCBCheckForUpdates.IsChecked = $false
        Update-Log -data 'OSDSUS selected as update catalog' -class Information
        Invoke-OSDCheck

    }

    if ($WPFUSCBSelectCatalogSource.SelectedItem -eq 'ConfigMgr') {
        $WPFUpdateOSDBUpdateButton.IsEnabled = $false
        $WPFUpdatesDownloadNewButton.IsEnabled = $true
        $WPFUpdatesW10Main.IsEnabled = $true
        $WPFUpdatesS2019.IsEnabled = $true
        $WPFUpdatesS2016.IsEnabled = $true
        $WPFMISCBCheckForUpdates.IsEnabled = $true
        #        $MEMCMsiteinfo = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification"

        #   $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
        #   $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'
        Update-Log -data 'ConfigMgr is selected as the update catalog' -Class Information

    }

}

Function Invoke-MSUpdateItemDownload {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [parameter(Mandatory = $true, HelpMessage = 'Specify the path to where the update item will be downloaded.')]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        $UpdateName
    )
    #write-host $updatename
    #write-host $filepath

    $OptionalUpdateCheck = 0

    #Adding in optional updates


    if ($UpdateName -like '*Adobe*') {
        $UpdateClass = 'AdobeSU'
        $OptionalUpdateCheck = 1
    }
    if ($UpdateName -like '*Microsoft .NET Framework*') {
        $UpdateClass = 'DotNet'
        $OptionalUpdateCheck = 1
    }
    if ($UpdateName -like '*Cumulative Update for .NET Framework*') {
        $OptionalUpdateCheck = 1
        $UpdateClass = 'DotNetCU'
    }
    if ($UpdateName -like '*Cumulative Update for Windows*') {
        $UpdateClass = 'LCU'
        $OptionalUpdateCheck = 1
    }
    if ($UpdateName -like '*Cumulative Update for Microsoft*') {
        $UpdateClass = 'LCU'
        $OptionalUpdateCheck = 1
    }
    if ($UpdateName -like '*Servicing Stack Update*') {
        $OptionalUpdateCheck = 1
        $UpdateClass = 'SSU'
    }
    if ($UpdateName -like '*Dynamic*') {
        $OptionalUpdateCheck = 1
        $UpdateClass = 'Dynamic'
    }

    if ($OptionalUpdateCheck -eq '0') {

        #Update-Log -data "This update appears to be optional. Skipping..." -Class Warning
        #return
        if ($WPFUpdatesCBEnableOptional.IsChecked -eq $True) { Update-Log -data 'This update appears to be optional. Downloading...' -Class Information }
        else {
            Update-Log -data 'This update appears to be optional, but are not enabled for download. Skipping...' -Class Information
            return
        }
        #Update-Log -data "This update appears to be optional. Downloading..." -Class Information

        $UpdateClass = 'Optional'

    }

    if ($UpdateName -like '*Windows 10*') {
        #here
        #if (($UpdateName -like "* 1903 *") -or ($UpdateName -like "* 1909 *") -or ($UpdateName -like "* 2004 *") -or ($UpdateName -like "* 20H2 *") -or ($UpdateName -like "* 21H1 *") -or ($UpdateName -like "* 21H2 *") -or ($UpdateName -like "* 22H2 *")){$WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10, version 1903 and later'"}

        if (($UpdateName -like '* 1903 *') -or ($UpdateName -like '* 1909 *') -or ($UpdateName -like '* 2004 *') -or ($UpdateName -like '* 20H2 *') -or ($UpdateName -like '* 21H1 *') -or ($UpdateName -like '* 21H2 *') -or ($UpdateName -like '* 22H2 *')) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10, version 1903 and later'" }
        else { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10'" }
        if ($updateName -like '*Dynamic*') {
            if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10 Dynamic Update'" }
        }
        #else{
        #Update-Log -data "Dynamic updates have not been selected for downloading. Skipping..." -Class Information
        #return
        #}
    }

    if ($UpdateName -like '*Windows 11*') {
        { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 11'" }

        if ($updateName -like '*Dynamic*') {
            if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 11 Dynamic Update'" }
        }

    }



    if (($UpdateName -like '*Windows Server*') -and ($ver -eq '1607')) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2016'" }
    if (($UpdateName -like '*Windows Server*') -and ($ver -eq '1809')) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2019'" }
    if (($UpdateName -like '*Windows Server*') -and ($ver -eq '21H2')) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Microsoft Server operating system-21H2'" }


    $UpdateItem = Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | Where-Object { ($_.LocalizedDisplayName -eq $UpdateName) }

    if ($null -ne $UpdateItem) {

        # Determine the ContentID instances associated with the update instance
        $UpdateItemContentIDs = Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_CIToContent -ComputerName $global:SiteServer -Filter "CI_ID = $($UpdateItem.CI_ID)" -ErrorAction Stop
        if ($null -ne $UpdateItemContentIDs) {

            # Account for multiple content ID items
            foreach ($UpdateItemContentID in $UpdateItemContentIDs) {
                # Get the content files associated with current Content ID
                $UpdateItemContent = Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_CIContentFiles -ComputerName $global:SiteServer -Filter "ContentID = $($UpdateItemContentID.ContentID)" -ErrorAction Stop
                if ($null -ne $UpdateItemContent) {
                    # Create new custom object for the update content
                    #write-host $UpdateItemContent.filename
                    $PSObject = [PSCustomObject]@{
                        'DisplayName' = $UpdateItem.LocalizedDisplayName
                        'ArticleID'   = $UpdateItem.ArticleID
                        'FileName'    = $UpdateItemContent.filename
                        'SourceURL'   = $UpdateItemContent.SourceURL
                        'DateRevised' = [System.Management.ManagementDateTimeConverter]::ToDateTime($UpdateItem.DateRevised)
                    }

                    $variable = $FilePath + $UpdateClass + '\' + $UpdateName

                    if ((Test-Path -Path $variable) -eq $false) {
                        Update-Log -Data "Creating folder $variable" -Class Information
                        New-Item -Path $variable -ItemType Directory | Out-Null
                        Update-Log -data 'Created folder' -Class Information
                    } else {
                        $testpath = $variable + '\' + $PSObject.FileName

                        if ((Test-Path -Path $testpath) -eq $true) {
                            Update-Log -Data 'Update already exists. Skipping the download...' -Class Information
                            return
                        }
                    }

                    try {
                        Update-Log -Data "Downloading update item content from: $($PSObject.SourceURL)" -Class Information

                        $DNLDPath = $variable + '\' + $PSObject.FileName

                        $WebClient = New-Object -TypeName System.Net.WebClient
                        $WebClient.DownloadFile($PSObject.SourceURL, $DNLDPath)

                        Update-Log -Data "Download completed successfully, renamed file to: $($PSObject.FileName)" -Class Information
                        $ReturnValue = 0
                    } catch [System.Exception] {
                        Update-Log -data "Unable to download update item content. Error message: $($_.Exception.Message)" -Class Error
                        $ReturnValue = 1
                    }
                } else {
                    Update-Log -data "Unable to determine update content instance for CI_ID: $($UpdateItemContentID.ContentID)" -Class Error
                    $ReturnValue = 1
                }
            }
        } else {
            Update-Log -Data "Unable to determine ContentID instance for CI_ID: $($UpdateItem.CI_ID)" -Class Error
            $ReturnValue = 1
        }
    } else {
        Update-Log -data "Unable to locate update item from SMS Provider for update type: $($UpdateType)" -Class Error
        $ReturnValue = 2
    }


    # Handle return value from Function
    return $ReturnValue | Out-Null
}

#Function to check for updates against ConfigMgr
Function Invoke-MEMCMUpdatecatalog($prod, $ver) {

    #set-ConfigMgrConnection
    Set-Location $CMDrive
    $Arch = 'x64'

    if ($prod -eq 'Windows 10') {
        #        if (($ver -ge '1903') -or ($ver -eq "21H1")){$WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10, version 1903 and later'"}
        #        if (($ver -ge '1903') -or ($ver -eq "21H1") -or ($ver -eq "20H2") -or ($ver -eq "21H2") -or ($ver -eq "22H2")){$WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10, version 1903 and later'"}
        #here
        if (($ver -ge '1903') -or ($ver -like '2*')) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10, version 1903 and later'" }


        if ($ver -le '1809') { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10'" }

        $Updates = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$($ver)*$($Arch)*") } )
    }


    if (($prod -like '*Windows Server*') -and ($ver -eq '1607')) {
        $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2016'"
        $Updates = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -notlike '* Next *') -and ($_.LocalizedDisplayName -notlike '*(1703)*') -and ($_.LocalizedDisplayName -notlike '*(1709)*') -and ($_.LocalizedDisplayName -notlike '*(1803)*') })
    }

    if (($prod -like '*Windows Server*') -and ($ver -eq '1809')) {
        $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2019'"
        $Updates = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$($Arch)*") } )
    }

    if (($prod -like '*Windows Server*') -and ($ver -eq '21H2')) {
        $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Microsoft Server operating system-21H2'"
        $Updates = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$($Arch)*") } )
    }

    if ($prod -eq 'Windows 11') {
        $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 11'"
        #$Updates = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$($Arch)*") } )
        if ($ver -eq '21H2') { $Updates = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*Windows 11 for $($Arch)*") } ) }
        else { $Updates = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$($ver)*$($Arch)*") } ) }


    }

    if ($WPFUpdatesCBEnableDynamic.IsChecked -eq $True) {

        if ($prod -eq 'Windows 10') { $Updates = $Updates + (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter "LocalizedCategoryInstanceNames = 'Windows 10 Dynamic Update'" -ErrorAction Stop | Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$($ver)*$($Arch)*") } ) }
        if ($prod -eq 'Windows 11') { $Updates = $Updates + (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter "LocalizedCategoryInstanceNames = 'Windows 11 Dynamic Update'" -ErrorAction Stop | Where-Object { ($_.IsSuperseded -eq $false) -and ($_.LocalizedDisplayName -like "*$prod*") -and ($_.LocalizedDisplayName -like "*$arch*") } ) }


    }


    if ($null -eq $updates) {
        Update-Log -data 'No updates found. Product is likely not synchronized. Continuing with build...' -class Warning
        Set-Location $global:workdir
        return
    }


    foreach ($update in $updates) {
        if ((($update.localizeddisplayname -notlike 'Feature update*') -and ($update.localizeddisplayname -notlike 'Upgrade to Windows 11*' )) -and ($update.localizeddisplayname -notlike '*Language Pack*') -and ($update.localizeddisplayname -notlike '*editions),*')) {
            Update-Log -Data 'Checking the following update:' -Class Information
            Update-Log -data $update.localizeddisplayname -Class Information
            #write-host "Display Name"
            #write-host $update.LocalizedDisplayName
            #            if ($ver -eq  "20H2"){$ver = "2009"} #Another 20H2 naming work around
            Invoke-MSUpdateItemDownload -FilePath "$global:workdir\updates\$Prod\$ver\" -UpdateName $update.LocalizedDisplayName
        }
    }

    Set-Location $global:workdir
}

#Function to check for supersedence against ConfigMgr
Function Invoke-MEMCMUpdateSupersedence($prod, $Ver) {
    #set-ConfigMgrConnection
    Set-Location $CMDrive
    $Arch = 'x64'

    if (($prod -eq 'Windows 10') -and (($ver -ge '1903') -or ($ver -eq '20H2') -or ($ver -eq '21H1') -or ($ver -eq '21H2')  )) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10, version 1903 and later'" }
    if (($prod -eq 'Windows 10') -and ($ver -le '1809')) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10'" }
    if (($prod -eq 'Windows Server') -and ($ver = '1607')) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2016'" }
    if (($prod -eq 'Windows Server') -and ($ver -eq '1809')) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2019'" }
    if (($prod -eq 'Windows Server') -and ($ver -eq '21H2')) { $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Microsoft Server operating system-21H2'" }

    Update-Log -data 'Checking files for supersedense...' -Class Information

    if ((Test-Path -Path "$global:workdir\updates\$Prod\$ver\") -eq $False) {
        Update-Log -Data 'Folder doesnt exist. Skipping supersedence check...' -Class Warning
        return
    }

    #For every folder under updates\prod\ver
    $FolderFirstLevels = Get-ChildItem -Path "$global:workdir\updates\$Prod\$ver\"
    foreach ($FolderFirstLevel in $FolderFirstLevels) {

        #For every folder under updates\prod\ver\class
        $FolderSecondLevels = Get-ChildItem -Path "$global:workdir\updates\$Prod\$ver\$FolderFirstLevel"
        foreach ($FolderSecondLevel in $FolderSecondLevels) {

            #for every cab under updates\prod\ver\class\update
            $UpdateCabs = (Get-ChildItem -Path "$global:workdir\updates\$Prod\$ver\$FolderFirstLevel\$FolderSecondLevel")
            foreach ($UpdateCab in $UpdateCabs) {
                Update-Log -data "Checking update file name $UpdateCab" -Class Information
                $UpdateItem = Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_SoftwareUpdate -ComputerName $global:SiteServer -Filter $WMIQueryFilter -ErrorAction Stop | Where-Object { ($_.LocalizedDisplayName -eq $FolderSecondLevel) }

                if ($UpdateItem.IsSuperseded -eq $false) {

                    Update-Log -data "Update $FolderSecondLevel is current" -Class Information
                } else {
                    Update-Log -Data "Update $UpdateCab is superseded. Deleting file..." -Class Warning
                    Remove-Item -Path "$global:workdir\updates\$Prod\$ver\$FolderFirstLevel\$FolderSecondLevel\$UpdateCab"
                }
            }
        }
    }

    Update-Log -Data 'Cleaning folders...' -Class Information
    $FolderFirstLevels = Get-ChildItem -Path "$global:workdir\updates\$Prod\$ver\"
    foreach ($FolderFirstLevel in $FolderFirstLevels) {

        #For every folder under updates\prod\ver\class
        $FolderSecondLevels = Get-ChildItem -Path "$global:workdir\updates\$Prod\$ver\$FolderFirstLevel"
        foreach ($FolderSecondLevel in $FolderSecondLevels) {

            #for every cab under updates\prod\ver\class\update
            $UpdateCabs = (Get-ChildItem -Path "$global:workdir\updates\$Prod\$ver\$FolderFirstLevel\$FolderSecondLevel")

            if ($null -eq $UpdateCabs) {
                Update-Log -Data "$FolderSecondLevel is empty. Deleting...." -Class Warning
                Remove-Item -Path "$global:workdir\updates\$Prod\$ver\$FolderFirstLevel\$FolderSecondLevel"
            }
        }
    }

    Set-Location $global:workdir
    Update-Log -data 'Supersedence check complete' -class Information
}

#Function to update source from ConfigMgr when Making It So
Function Invoke-MISUpdates {

    $OS = get-Windowstype
    $ver = Get-WinVersionNumber

    if ($ver -eq '2009') { $ver = '20H2' }

    Invoke-MEMCMUpdateSupersedence -prod $OS -Ver $ver
    Invoke-MEMCMUpdatecatalog -prod $OS -ver $ver

    #fucking 2009 to 20h2

}

#Function to run the osdsus and osdupdate update check Functions
Function Invoke-OSDCheck {

    Get-OSDBInstallation #Sets OSDUpate version info
    Get-OSDBCurrentVer #Discovers current version of OSDUpdate
    Compare-OSDBuilderVer #determines if an update of OSDUpdate can be applied
    get-osdsusinstallation #Sets OSDSUS version info
    Get-OSDSUSCurrentVer #Discovers current version of OSDSUS
    Compare-OSDSUSVer #determines if an update of OSDSUS can be applied
}

#Function to update image version, properties, and binary delta replication
Function Set-ImageProperties($PackageID) {
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

#Function to detect and set CM site properties
Function Find-ConfigManager() {

    If ((Test-Path -Path HKLM:\SOFTWARE\Microsoft\SMS\Identification) -eq $true) {
        Update-Log -Data 'Site Information found in Registry' -Class Information
        try {

            $MEMCMsiteinfo = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification' -ErrorAction Stop

            $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
            $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'

            #$WPFCMTBSiteServer.text = "nt-tpmemcm.notorious.local"
            #$WPFCMTBSitecode.text = "NTP"

            $global:SiteCode = $WPFCMTBSitecode.text
            $global:SiteServer = $WPFCMTBSiteServer.Text
            $global:CMDrive = $WPFCMTBSitecode.text + ':'

            Update-Log -Data 'ConfigMgr detected and properties set' -Class Information
            Update-Log -Data 'ConfigMgr feature enabled' -Class Information
            $sitecodetext = 'Site Code - ' + $WPFCMTBSitecode.text
            Update-Log -Data $sitecodetext -Class Information
            $siteservertext = 'Site Server - ' + $WPFCMTBSiteServer.text
            Update-Log -Data $siteservertext -Class Information
            if ($CM -eq 'New') {
                $WPFCMCBImageType.SelectedIndex = 1
                Enable-ConfigMgrOptions
            }

            return 0
        } catch {
            Update-Log -Data 'ConfigMgr not detected' -Class Information
            $WPFCMTBSiteServer.text = 'Not Detected'
            $WPFCMTBSitecode.text = 'Not Detected'
            return 1
        }
    }

    if ((Test-Path -Path $global:workdir\ConfigMgr\SiteInfo.XML) -eq $true) {
        Update-Log -data 'ConfigMgr Site info XML found' -class Information

        $settings = Import-Clixml -Path $global:workdir\ConfigMgr\SiteInfo.xml -ErrorAction Stop

        $WPFCMTBSitecode.text = $settings.SiteCode
        $WPFCMTBSiteServer.text = $settings.SiteServer

        Update-Log -Data 'ConfigMgr detected and properties set' -Class Information
        Update-Log -Data 'ConfigMgr feature enabled' -Class Information
        $sitecodetext = 'Site Code - ' + $WPFCMTBSitecode.text
        Update-Log -Data $sitecodetext -Class Information
        $siteservertext = 'Site Server - ' + $WPFCMTBSiteServer.text
        Update-Log -Data $siteservertext -Class Information

        $global:SiteCode = $WPFCMTBSitecode.text
        $global:SiteServer = $WPFCMTBSiteServer.Text
        $global:CMDrive = $WPFCMTBSitecode.text + ':'

        return 0
    }

    Update-Log -Data 'ConfigMgr not detected' -Class Information
    $WPFCMTBSiteServer.text = 'Not Detected'
    $WPFCMTBSitecode.text = 'Not Detected'
    Return 1

}

#Function to manually set the CM site properties
Function Set-ConfigMgr() {

    try {

        # $MEMCMsiteinfo = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Identification" -ErrorAction Stop

        # $WPFCMTBSiteServer.text = $MEMCMsiteinfo.'Site Server'
        # $WPFCMTBSitecode.text = $MEMCMsiteinfo.'Site Code'

        #$WPFCMTBSiteServer.text = "nt-tpmemcm.notorious.local"
        #$WPFCMTBSitecode.text = "NTP"

        $global:SiteCode = $WPFCMTBSitecode.text
        $global:SiteServer = $WPFCMTBSiteServer.Text
        $global:CMDrive = $WPFCMTBSitecode.text + ':'

        Update-Log -Data 'ConfigMgr detected and properties set' -Class Information
        Update-Log -Data 'ConfigMgr feature enabled' -Class Information
        $sitecodetext = 'Site Code - ' + $WPFCMTBSitecode.text
        Update-Log -Data $sitecodetext -Class Information
        $siteservertext = 'Site Server - ' + $WPFCMTBSiteServer.text
        Update-Log -Data $siteservertext -Class Information

        $CMConfig = @{
            SiteCode   = $WPFCMTBSitecode.text
            SiteServer = $WPFCMTBSiteServer.text
        }
        Update-Log -data 'Saving ConfigMgr site information...'
        $CMConfig | Export-Clixml -Path $global:workdir\ConfigMgr\SiteInfo.xml -ErrorAction Stop

        if ($CM -eq 'New') {
            $WPFCMCBImageType.SelectedIndex = 1
            Enable-ConfigMgrOptions
        }

        return 0
    }

    catch {
        Update-Log -Data 'ConfigMgr not detected' -Class Information
        $WPFCMTBSiteServer.text = 'Not Detected'
        $WPFCMTBSitecode.text = 'Not Detected'
        return 1
    }


}

#Function to detect and import CM PowerShell module
Function Import-CMModule() {
    try {
        $path = (($env:SMS_ADMIN_UI_PATH -replace 'i386', '') + 'ConfigurationManager.psd1')

        #           $path = "C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1"
        Import-Module $path -ErrorAction Stop
        Update-Log -Data 'ConfigMgr PowerShell module imported' -Class Information
        return 0
    }

    catch {
        Update-Log -Data 'Could not import CM PowerShell module.' -Class Warning
        return 1
    }
}

#Function to apply the start menu layout
Function Install-StartLayout {
    try {
        $startpath = $WPFMISMountTextBox.Text + '\users\default\appdata\local\microsoft\windows\shell'
        Update-Log -Data 'Copying the start menu file...' -Class Information
        Copy-Item $WPFCustomTBStartMenu.Text -Destination $startpath -ErrorAction Stop
        $filename = (Split-Path -Path $WPFCustomTBStartMenu.Text -Leaf)

        $OS = $Windowstype

        if ($os -eq 'Windows 11') {
            if ($filename -ne 'LayoutModification.json') {
                $newpath = $startpath + '\' + $filename
                Update-Log -Data 'Renaming json file...' -Class Warning
                Rename-Item -Path $newpath -NewName 'LayoutModification.json'
                Update-Log -Data 'file renamed to LayoutModification.json' -Class Information
            }
        }

        if ($os -ne 'Windows 11') {
            if ($filename -ne 'LayoutModification.xml') {
                $newpath = $startpath + '\' + $filename
                Update-Log -Data 'Renaming xml file...' -Class Warning
                Rename-Item -Path $newpath -NewName 'LayoutModification.xml'
                Update-Log -Data 'file renamed to LayoutModification.xml' -Class Information
            }
        }



    } catch {
        Update-Log -Data "Couldn't apply the start menu XML" -Class Error
        Update-Log -data $_.Exception.Message -Class Error
    }
}

#Function to apply the default application association
Function Install-DefaultApplicationAssociations {
    try {
        Update-Log -Data 'Applying Default Application Association XML...'
        "Dism.exe /image:$WPFMISMountTextBox.text /Import-DefaultAppAssociations:$WPFCustomTBDefaultApp.text"
        Update-log -data 'Default Application Association applied' -Class Information

    } catch {
        Update-Log -Data 'Could not apply Default Appklication Association XML...' -Class Error
        Update-Log -data $_.Exception.Message -Class Error
    }
}

#Function to select default app association xml
Function Select-DefaultApplicationAssociations {

    $Sourcexml = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
        Filter           = 'XML (*.xml)|'
    }
    $null = $Sourcexml.ShowDialog()
    $WPFCustomTBDefaultApp.text = $Sourcexml.FileName


    if ($Sourcexml.FileName -notlike '*.xml') {
        Update-Log -Data 'A XML file not selected. Please select a valid file to continue.' -Class Warning
        return
    }
    $text = $WPFCustomTBDefaultApp.text + ' selected as the default application XML'
    Update-Log -Data $text -class Information
}

#Function to select start menu xml
Function Select-StartMenu {

    $OS = Get-WindowsType

    if ($OS -ne 'Windows 11') {
        $Sourcexml = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Filter           = 'XML (*.xml)|'
        }
    }

    if ($OS -eq 'Windows 11') {
        $Sourcexml = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Filter           = 'JSON (*.JSON)|'
        }
    }

    $null = $Sourcexml.ShowDialog()
    $WPFCustomTBStartMenu.text = $Sourcexml.FileName

    if ($OS -ne 'Windows 11') {
        if ($Sourcexml.FileName -notlike '*.xml') {
            Update-Log -Data 'A XML file not selected. Please select a valid file to continue.' -Class Warning
            return
        }
    }

    if ($OS -eq 'Windows 11') {
        if ($Sourcexml.FileName -notlike '*.json') {
            Update-Log -Data 'A JSON file not selected. Please select a valid file to continue.' -Class Warning
            return
        }
    }




    $text = $WPFCustomTBStartMenu.text + ' selected as the start menu file'
    Update-Log -Data $text -class Information
}

#Function to select registry files
Function Select-RegFiles {

    $Regfiles = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
        Multiselect      = $true # Multiple files can be chosen
        Filter           = 'REG (*.reg)|'
    }
    $null = $Regfiles.ShowDialog()

    $filepaths = $regfiles.FileNames
    Update-Log -data 'Importing REG files...' -class information
    foreach ($filepath in $filepaths) {
        if ($filepath -notlike '*.reg') {
            Update-Log -Data $filepath -Class Warning
            Update-Log -Data 'Ignoring this file as it is not a .REG file....' -Class Warning
            return
        }
        Update-Log -Data $filepath -Class Information
        $WPFCustomLBRegistry.Items.Add($filepath)
    }
    Update-Log -data 'REG file importation complete' -class information

    #Fix this shit, then you can release her.
}

#Function to apply registry files to mounted image
Function Install-RegistryFiles {

    #mount offline hives
    Update-Log -Data 'Mounting the offline registry hives...' -Class Information

    try {
        $Path = $WPFMISMountTextBox.text + '\Users\Default\NTUser.dat'
        Update-Log -Data $path -Class Information
        Invoke-Command { reg load HKLM\OfflineDefaultUser $Path } -ErrorAction Stop | Out-Null

        $Path = $WPFMISMountTextBox.text + '\Windows\System32\Config\DEFAULT'
        Update-Log -Data $path -Class Information
        Invoke-Command { reg load HKLM\OfflineDefault $Path } -ErrorAction Stop | Out-Null

        $Path = $WPFMISMountTextBox.text + '\Windows\System32\Config\SOFTWARE'
        Update-Log -Data $path -Class Information
        Invoke-Command { reg load HKLM\OfflineSoftware $Path } -ErrorAction Stop | Out-Null

        $Path = $WPFMISMountTextBox.text + '\Windows\System32\Config\SYSTEM'
        Update-Log -Data $path -Class Information
        Invoke-Command { reg load HKLM\OfflineSystem $Path } -ErrorAction Stop | Out-Null
    } catch {
        Update-Log -Data "Failed to mount $Path" -Class Error
        Update-Log -data $_.Exception.Message -Class Error
    }

    #get reg files from list box
    $RegFiles = $WPFCustomLBRegistry.items

    #For Each to process Reg Files and Apply
    Update-Log -Data 'Processing Reg Files...' -Class Information
    foreach ($RegFile in $Regfiles) {

        Update-Log -Data $RegFile -Class Information
        #write-host $RegFile

        Try {
            $Destination = $global:workdir + '\staging\'
            Update-Log -Data 'Copying file to staging folder...' -Class Information
            Copy-Item -Path $regfile -Destination $Destination -Force -ErrorAction Stop  #Copy Source Registry File to staging
        } Catch {
            Update-Log -Data "Couldn't copy reg file" -Class Error
            Update-Log -data $_.Exception.Message -Class Error
        }

        $regtemp = Split-Path $regfile -Leaf #get file name
        $regpath = $global:workdir + '\staging' + '\' + $regtemp

        # Write-Host $regpath
        Try {
            Update-Log -Data 'Parsing reg file...'
           ((Get-Content -Path $regpath -Raw) -replace 'HKEY_CURRENT_USER', 'HKEY_LOCAL_MACHINE\OfflineDefaultUser') | Set-Content -Path $regpath -ErrorAction Stop
           ((Get-Content -Path $regpath -Raw) -replace 'HKEY_LOCAL_MACHINE\\SOFTWARE', 'HKEY_LOCAL_MACHINE\OfflineSoftware') | Set-Content -Path $regpath -ErrorAction Stop
           ((Get-Content -Path $regpath -Raw) -replace 'HKEY_LOCAL_MACHINE\\SYSTEM', 'HKEY_LOCAL_MACHINE\OfflineSystem') | Set-Content -Path $regpath -ErrorAction Stop
           ((Get-Content -Path $regpath -Raw) -replace 'HKEY_USERS\\.DEFAULT', 'HKEY_LOCAL_MACHINE\OfflineDefault') | Set-Content -Path $regpath -ErrorAction Stop
        } Catch {
            Update-log -Data "Couldn't read or update reg file $regpath" -Class Error
            Update-Log -data $_.Exception.Message -Class Error
        }

        Update-Log -Data 'Reg file has been parsed' -Class Information

        #import the registry file

        Try {
            Update-Log -Data 'Importing registry file into mounted wim' -Class Information
            Start-Process reg -ArgumentList ('import', "`"$RegPath`"") -Wait -WindowStyle Hidden -ErrorAction stop
            Update-Log -Data 'Import successful' -Class Information
        } Catch {
            Update-Log -Data "Couldn't import $Regpath" -Class Error
            Update-Log -data $_.Exception.Message -Class Error

        }
    }


    #dismount offline hives
    try {
        Update-Log -Data 'Dismounting registry...' -Class Information
        Invoke-Command { reg unload HKLM\OfflineDefaultUser } -ErrorAction Stop | Out-Null
        Invoke-Command { reg unload HKLM\OfflineDefault } -ErrorAction Stop | Out-Null
        Invoke-Command { reg unload HKLM\OfflineSoftware } -ErrorAction Stop | Out-Null
        Invoke-Command { reg unload HKLM\OfflineSystem } -ErrorAction Stop | Out-Null
        Update-Log -Data 'Dismount complete' -Class Information
    } catch {
        Update-Log -Data "Couldn't dismount the registry hives" -Class Error
        Update-Log -Data 'This will prevent the Windows image from properly dismounting' -Class Error
        Update-Log -data $_.Exception.Message -Class Error

    }

}

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