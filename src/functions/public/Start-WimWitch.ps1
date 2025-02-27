<#
.SYNOPSIS
    Start the WimWitch-Reloaded GUI

.DESCRIPTION
    This function is used to start the WimWitch-Reloaded GUI. It will allow you to import WIM files, inject drivers, and more.

.NOTES
    Name:        Start-WimWitch.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-31
    Version:     1.0.0
    Repository:  [Wimwitch Reloaded](https://github.com/mchave3/WimWitch-Reloaded)
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    [Link](https://github.com/thenotoriousdrr/WIM-Witch)

.LINK
    [Wimwitch Reloaded](https://github.com/mchave3/WimWitch-Reloaded)

.EXAMPLE
    Start-WimWitch
#>
function Start-WimWitch {

    #Requires -Version 5.1
    #Requires -Modules OSDSUS, OSDUpdate
    #-- Requires -ShellId <ShellId>
    # Requires -RunAsAdministrator
    #-- Requires -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(mandatory = $false, HelpMessage = 'enable auto')]
        [switch]$auto,

        [parameter(mandatory = $false, HelpMessage = 'config file')]
        [string]$autofile,

        [parameter(mandatory = $false, HelpMessage = 'config path')]
        [string]$autopath,

        [parameter(mandatory = $false, HelpMessage = 'Update Modules')]
        [Switch]$UpdatePoShModules,

        [parameter(mandatory = $false, HelpMessage = 'Enable Downloading Updates')]
        [switch]$DownloadUpdates,

        [parameter(mandatory = $false, HelpMessage = 'Win10 Version')]
        [ValidateSet('all', '1809', '20H2', '21H1', '21H2', '22H2')]
        [string]$Win10Version = 'none',

        [parameter(mandatory = $false, HelpMessage = 'Win11 Version')]
        [ValidateSet('all', '21H2', '22H2', '23H2')]
        [string]$Win11Version = 'none',

        [parameter(mandatory = $false, HelpMessage = 'Windows Server 2016')]
        [switch]$Server2016,

        [parameter(mandatory = $false, HelpMessage = 'Windows Server 2019')]
        [switch]$Server2019,

        [parameter(mandatory = $false, HelpMessage = 'Windows Server 2022')]
        [switch]$Server2022,

        [parameter(mandatory = $false, HelpMessage = 'This is not helpful')]
        [switch]$HiHungryImDad,

        [parameter(mandatory = $false, HelpMessage = 'CM Option')]
        [ValidateSet('New', 'Edit')]
        [string]$CM = 'none'
    )

    process {
        # Retrieve available versions
        $module = Get-Module | Where-Object { $_.Name -match "WimWitch-Reloaded" } |
            Sort-Object Version -Descending |
            Select-Object -First 1

        # Check version and include pre-release if available
        if ($module) {
            $WWScriptVer = $module.Version.ToString()
            if ($module.PrivateData.PSData.PreRelease) {
                $WWScriptVer += "-$($module.PrivateData.PSData.PreRelease)"
            }
        } else {
            $WWScriptVer = "Version not found"
        }

        #region XAML
        #Your XAML goes here
        $inputXML = Get-Content -Path "$PSScriptRoot\resources\UI\MainWindow.xaml" -Raw

        $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window' -replace 'WWScriptVer', $WWScriptVer
        [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
        [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
        [xml]$XAML = $inputXML
        #Read XAML

        $reader = (New-Object System.Xml.XmlNodeReader $xaml)
        try {
        $form = [Windows.Markup.XamlReader]::Load($reader)
        } catch {
        Write-Warning @"
Unable to parse XML, with error: $($Error[0])
Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes
(PowerShell cannot process them)
"@
            throw
        }

        #===========================================================================

        # Load XAML Objects In PowerShell
        #===========================================================================

        $xaml.SelectNodes('//*[@Name]') | ForEach-Object { "trying item $($_.Name)" | Out-Null
            try { Set-Variable -Name "WPF$($_.Name)" -Value $form.FindName($_.Name) -ErrorAction Stop }
            catch { throw }
        }

        #Section to do the icon magic
        ###################################################
        $base64 = Get-Content -Path "$PSScriptRoot\resources\UI\icon_base64.txt" -Raw
        # Create a streaming image by streaming the base64 string to a bitmap streamsource
        $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
        $bitmap.BeginInit()
        $bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
        $bitmap.EndInit()
        $bitmap.Freeze()

        # This is the icon in the upper left hand corner of the app
        $form.Icon = $bitmap
        # This is the toolbar icon and description
        $form.TaskbarItemInfo.Overlay = $bitmap
        $form.TaskbarItemInfo.Description = "WimWitch-Reloaded - $wwscriptver"
        ###################################################

        #endregion XAML

        #region Main
        #===========================================================================

        # Run commands to set values of files and variables, etc.
        #===========================================================================

        # Calls fuction to display the opening text blurb

        Write-WWOpeningMessage

        # Sets the working directory
        Invoke-WWWorkingDirectory

        # Clears out old logs from previous builds and checks for other folders
        Initialize-WimWitchEnvironment

        # Test for admin and exit if not
        Test-WWAdministrator

        # Setting default values for the WPF form
        $WPFMISWimFolderTextBox.Text = "$script:workingDirectory\CompletedWIMs"
        $WPFMISMountTextBox.Text = "$script:workingDirectory\Mount"
        $WPFJSONTextBoxSavePath.Text = "$script:workingDirectory\Autopilot"


        ##################
        # Prereq Check segment

        #Check for installed PowerShell version
        if ($PSVersionTable.PSVersion.Major -ge 5) { Write-WimWitchLog -Data 'PowerShell v5 or greater installed.' -Class Information }
        else {
            Write-WimWitchLog -data 'PowerShell v5 or greater is required. Please upgrade PowerShell and try again.' -Class Error
            Write-WWClosingMessage
            exit 0
        }


        #Check for admin rights
        #Invoke-AdminCheck

        #Check for 32 bit architecture
        Invoke-WWArchitectureCheck

        #End Prereq segment
        ###################

        #===========================================================================

        # Set default values for certain variables
        #===========================================================================

        #Set the value of the JSON field in Make It So tab
        $WPFMISJSONTextBox.Text = 'False'

        #Set the value of the Driver field in the Make It So tab
        $WPFMISDriverTextBox.Text = 'False'

        #Set the value of the Updates field in the Make It So tab
        $WPFMISUpdatesTextBox.Text = 'False'

        $WPFMISAppxTextBox.Text = 'False'

        $script:Win10VerDet = ''

        #===========================================================================

        # Section for Combo box Functions
        #===========================================================================

        #Set the combo box values of the other import tab

        $ObjectTypes = @('Language Pack', 'Local Experience Pack', 'Feature On Demand')
        $WinOS = @('Windows Server', 'Windows 10', 'Windows 11')
        $script:WinSrvVer = @('2019', '21H2')
        $script:Win10Ver = @('1809', '2004')
        $script:Win11Ver = @('21H2', '22H2', '23H2')

        Foreach ($ObjectType in $ObjectTypes) { $WPFImportOtherCBType.Items.Add($ObjectType) | Out-Null }
        Foreach ($WinOS in $WinOS) { $WPFImportOtherCBWinOS.Items.Add($WinOS) | Out-Null }

        #Run Script Timing combox box
        $RunScriptActions = @('After image mount', 'Before image dismount', 'On build completion')
        Foreach ($RunScriptAction in $RunScriptActions) { $WPFCustomCBScriptTiming.Items.add($RunScriptAction) | Out-Null }

        #ConfigMgr Tab Combo boxes
        $ImageTypeCombos = @('Disabled', 'New Image', 'Update Existing Image')
        $DPTypeCombos = @('Distribution Points', 'Distribution Point Groups')
        foreach ($ImageTypeCombo in $ImageTypeCombos) { $WPFCMCBImageType.Items.Add($ImageTypeCombo) | Out-Null }
        foreach ($DPTypeCombo in $DPTypeCombos) { $WPFCMCBDPDPG.Items.Add($DPTypeCombo) | Out-Null }
        $WPFCMCBDPDPG.SelectedIndex = 0
        $WPFCMCBImageType.SelectedIndex = 0


        Enable-WWConfigManagerOption

        #Software Update Catalog Source combo box
        $UpdateSourceCombos = @('None', 'OSDSUS', 'ConfigMgr')
        foreach ($UpdateSourceCombo in $UpdateSourceCombos) { $WPFUSCBSelectCatalogSource.Items.Add($UpdateSourceCombo) | Out-Null }
        $WPFUSCBSelectCatalogSource.SelectedIndex = 0
        Update-WWTabOption

        #Check for ConfigMgr and set integration
        if ((Find-WWConfigManager) -eq $true) {

            if ((Import-WWConfigManagerModule) -eq $true) {
                $WPFUSCBSelectCatalogSource.SelectedIndex = 2
                Update-WWTabOption
            }
        } else
        { Write-WimWitchLog -Data 'Skipping ConfigMgr PowerShell module importation' }

        #Set OSDSUS to Patch Catalog if CM isn't integratedg

        if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 0) {
            Write-WimWitchLog -Data 'Setting OSDSUS as the Update Catalog' -Class Information
            $WPFUSCBSelectCatalogSource.SelectedIndex = 1
            Update-WWTabOption
        }

        #Function Get-WWWindowsPatch($build,$OS)

        if ($DownloadUpdates -eq $true) {
            #    If (($UpdatePoShModules -eq $true) -and ($WPFUpdatesOSDBOutOfDateTextBlock.Visibility -eq "Visible")) {
            If ($UpdatePoShModules -eq $true ) {
                Install-WWOSDeployment
                Install-WWOSDServiceUpdateStack
            }


            if ($Server2016 -eq $true) {
                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                    Test-WWSuperseded -action delete -OS 'Windows Server' -Build 1607
                    Get-WWWindowsPatch -OS 'Windows Server' -build 1607
                }


                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                    Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows Server' -Ver 1607
                    Invoke-WWConfigManagerUpdateCatalog -prod 'Windows Server' -Ver 1607
                }
            }

            if ($Server2019 -eq $true) {
                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                    Test-WWSuperseded -action delete -OS 'Windows Server' -Build 1809
                    Get-WWWindowsPatch -OS 'Windows Server' -build 1809
                }

                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                    Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows Server' -Ver 1809
                    Invoke-WWConfigManagerUpdateCatalog -prod 'Windows Server' -Ver 1809
                }
            }

            if ($Server2022 -eq $true) {
                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                    Test-WWSuperseded -action delete -OS 'Windows Server' -Build 21H2
                    Get-WWWindowsPatch -OS 'Windows Server' -build 21H2
                }


                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                    Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows Server' -Ver 21H2
                    Invoke-WWConfigManagerUpdateCatalog -prod 'Windows Server' -Ver 21H2
                }
            }


            if ($Win10Version -ne 'none') {
                if (($Win10Version -eq '1709')) {
                    # -or ($Win10Version -eq "all")){
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 10' -Build 1709
                        Get-WWWindowsPatch -OS 'Windows 10' -build 1709
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 10' -Ver 1709
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 10' -Ver 1709
                    }
                }

                if (($Win10Version -eq '1803')) {
                    # -or ($Win10Version -eq "all")){
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 10' -Build 1803
                        Get-WWWindowsPatch -OS 'Windows 10' -build 1803
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 10' -Ver 1803
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 10' -Ver 1803
                    }
                }

                if (($Win10Version -eq '1809') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 10' -Build 1809
                        Get-WWWindowsPatch -OS 'Windows 10' -build 1809
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 10' -Ver 1809
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 10' -Ver 1809
                    }
                }


                if (($Win10Version -eq '1903')) {
                    # -or ($Win10Version -eq "all")){
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 10' -Build 1903
                        Get-WWWindowsPatch -OS 'Windows 10' -build 1903
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 10' -Ver 1903
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 10' -Ver 1903
                    }
                }


                if (($Win10Version -eq '1909') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 10' -Build 1909
                        Get-WWWindowsPatch -OS 'Windows 10' -build 1909
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 10' -Ver 1909
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 10' -Ver 1909
                    }
                }

                if (($Win10Version -eq '2004') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 10' -Build 2004
                        Get-WWWindowsPatch -OS 'Windows 10' -build 2004
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 10' -Ver 2004
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 10' -Ver 2004
                    }
                }

                if (($Win10Version -eq '20H2') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 10' -Build 2009
                        Get-WWWindowsPatch -OS 'Windows 10' -build 2009
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 10' -Ver 2009
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 10' -Ver 2009
                    }
                }

                if (($Win10Version -eq '21H1') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 10' -Build 21H1
                        Get-WWWindowsPatch -OS 'Windows 10' -build 21H1
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 10' -Ver 21H1
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 10' -Ver 21H1
                    }
                }

                if (($Win10Version -eq '21H2') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 10' -Build 21H2
                        Get-WWWindowsPatch -OS 'Windows 10' -build 21H2
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 10' -Ver 21H2
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 10' -Ver 21H2
                    }
                }

                if ($Win11Version -eq '21H2') {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 11' -Build 21H2
                        Get-WWWindowsPatch -OS 'Windows 11' -build 21H2
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 11' -Ver 21H2
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 11' -Ver 21H2
                    }
                }
                if ($Win11Version -eq '22H2') {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 11' -Build 22H2
                        Get-WWWindowsPatch -OS 'Windows 11' -build 22H2
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 11' -Ver 22H2
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 11' -Ver 22H2
                    }
                }
                if ($Win11Version -eq '23H2') {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-WWSuperseded -action delete -OS 'Windows 11' -Build 23H2
                        Get-WWWindowsPatch -OS 'Windows 11' -build 23H2
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-WWConfigManagerUpdateSupersedence -prod 'Windows 11' -Ver 23H2
                        Invoke-WWConfigManagerUpdateCatalog -prod 'Windows 11' -Ver 23H2
                    }
                }

                Get-WWOneDrive
            }
        }

        #===========================================================================

        # Section for Buttons to call Functions
        #===========================================================================

        #Mount Dir Button
        $WPFMISMountSelectButton.Add_Click( { Select-WWMountDirectory })

        #Source WIM File Button
        $WPFSourceWIMSelectButton.Add_Click( { Select-WWSourceWIM })

        #JSON File selection Button
        $WPFJSONButton.Add_Click( { Select-WWJSONFile })

        #Target Folder selection Button
        $WPFMISFolderButton.Add_Click( { Select-WWTargetDirectory })

        #Driver Directory Buttons
        $WPFDriverDir1Button.Add_Click( { Select-WWDriverSource -DriverTextBoxNumber $WPFDriverDir1TextBox })
        $WPFDriverDir2Button.Add_Click( { Select-WWDriverSource -DriverTextBoxNumber $WPFDriverDir2TextBox })
        $WPFDriverDir3Button.Add_Click( { Select-WWDriverSource -DriverTextBoxNumber $WPFDriverDir3TextBox })
        $WPFDriverDir4Button.Add_Click( { Select-WWDriverSource -DriverTextBoxNumber $WPFDriverDir4TextBox })
        $WPFDriverDir5Button.Add_Click( { Select-WWDriverSource -DriverTextBoxNumber $WPFDriverDir5TextBox })

        #Make it So Button, which builds the WIM file
        $WPFMISMakeItSoButton.Add_Click( { Invoke-WWMakeItSo -appx $script:SelectedAppx })

        #Update OSDBuilder Button
        $WPFUpdateOSDBUpdateButton.Add_Click( {
                Install-WWOSDeployment
                Install-WWOSDServiceUpdateStack
            })

        #Update patch source
        $WPFUpdatesDownloadNewButton.Add_Click( { Sync-WWWindowsUpdateSource })

        #Select Appx packages to remove
        $WPFAppxButton.Add_Click( { $script:SelectedAppx = Select-WWAppx })

        #Select Autopilot path to save button
        $WPFJSONButtonSavePath.Add_Click( { Select-WWNewJSONDirectory })

        #retrieve autopilot profile from intune
        $WPFJSONButtonRetrieve.Add_click( { get-wwautopilotprofile -login $WPFJSONTextBoxAADID.Text -path $WPFJSONTextBoxSavePath.Text })

        #Button to save configuration file
        $WPFSLSaveButton.Add_click( { Save-WWSetting -filename $WPFSLSaveFileName.text })

        #Button to load configuration file
        $WPFSLLoadButton.Add_click( { Select-WWConfig })

        #Button to select ISO for importation
        $WPFImportImportSelectButton.Add_click( { Select-WWISO })

        #Button to import content from iso
        $WPFImportImportButton.Add_click( { Import-WWWindowsISO })

        #Combo Box dynamic change for Winver combo box
        $WPFImportOtherCBWinOS.add_SelectionChanged({ Import-WWVersionCallback })

        #Button to select the import path in the other components
        $WPFImportOtherBSelectPath.add_click({ Select-WWImportPath

            if ($WPFImportOtherCBType.SelectedItem -ne 'Feature On Demand') {
                if ($WPFImportOtherCBWinOS.SelectedItem -ne 'Windows 11') {
                    $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text |
                        Select-Object -Property Name |
                        Out-GridView -Title 'Select Objects' -PassThru)
                }
                if (($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') -and
                    ($WPFImportOtherCBType.SelectedItem -eq 'Language Pack')) {
                    $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text |
                        Select-Object -Property Name |
                        Where-Object { ($_.Name -like '*Windows-Client-Language-Pack*') } |
                        Out-GridView -Title 'Select Objects' -PassThru)
                }
                if (($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') -and
                    ($WPFImportOtherCBType.SelectedItem -eq 'Local Experience Pack')) {
                    $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text |
                        Select-Object -Property Name |
                        Out-GridView -Title 'Select Objects' -PassThru)
                }
            }

            if ($WPFImportOtherCBType.SelectedItem -eq 'Feature On Demand') {
                if ($WPFImportOtherCBWinOS.SelectedItem -ne 'Windows 11') {
                    $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text)
                }
                if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') {
                    $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text |
                        Select-Object -Property Name |
                        Where-Object { ($_.Name -notlike '*Windows-Client-Language-Pack*') } |
                        Out-GridView -Title 'Select Objects' -PassThru)
                }
            }

            $WPFImportOtherLBList.Items.Clear()
            $count = 0
            $path = $WPFImportOtherTBPath.text
            foreach ($item in $items) {
                $WPFImportOtherLBList.Items.Add($item.name)
                $count = $count + 1
            }

            if ($wpfImportOtherCBType.SelectedItem -eq 'Language Pack') {
                Write-WimWitchLog -data "$count Language Packs selected from $path" -Class Information
            }
            if ($wpfImportOtherCBType.SelectedItem -eq 'Local Experience Pack') {
                Write-WimWitchLog -data "$count Local Experience Packs selected from $path" -Class Information
            }
            if ($wpfImportOtherCBType.SelectedItem -eq 'Feature On Demand') {
                Write-WimWitchLog -data "Features On Demand source selected from $path" -Class Information
            }
        })

        #Button to import Other Components content
        $WPFImportOtherBImport.add_click({
                if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows Server') {
                    if ($WPFImportOtherCBWinVer.SelectedItem -eq '2019') { $WinVerConversion = '1809' }
                } else {
                    $WinVerConversion = $WPFImportOtherCBWinVer.SelectedItem
                }

                if ($WPFImportOtherCBType.SelectedItem -eq 'Language Pack') {
                    Import-WWLanguagePack -Winver $WinVerConversion -WinOS $WPFImportOtherCBWinOS.SelectedItem `
                        -LPSourceFolder $WPFImportOtherTBPath.text
                }
                if ($WPFImportOtherCBType.SelectedItem -eq 'Local Experience Pack') {
                    Import-WWLocalExperiencePack -Winver $WinVerConversion -WinOS $WPFImportOtherCBWinOS.SelectedItem `
                        -LPSourceFolder $WPFImportOtherTBPath.text
                }
                if ($WPFImportOtherCBType.SelectedItem -eq 'Feature On Demand') {
                    Import-WWFeatureOnDemand -Winver $WinVerConversion -WinOS $WPFImportOtherCBWinOS.SelectedItem `
                        -LPSourceFolder $WPFImportOtherTBPath.text
                }
        })

        #Button Select LP's for importation
        $WPFCustomBLangPacksSelect.add_click({ Select-WWLanguageFeature -type 'LP' })

        #Button to select FODs for importation
        $WPFCustomBFODSelect.add_click({ Select-WWLanguageFeature -type 'FOD' })

        #Button to select LXPs for importation
        $WPFCustomBLEPSelect.add_click({ Select-WWLanguageFeature -type 'LXP' })

        #Button to select PS1 script
        $WPFCustomBSelectPath.add_click({
                $Script = New-Object System.Windows.Forms.OpenFileDialog -Property @{
                    InitialDirectory = [Environment]::GetFolderPath('Desktop')
                    Filter           = 'PS1 (*.ps1)|'
                }
                $null = $Script.ShowDialog()
                $WPFCustomTBFile.text = $Script.FileName })

        #Button to Select ConfigMgr Image Package
        $WPFCMBSelectImage.Add_Click({
            $image = Get-CimInstance -Namespace "root\SMS\Site_$($script:SiteCode)" -ClassName SMS_ImagePackage `
                -ComputerName $script:SiteServer |
                Select-Object -Property Name, version, language, ImageOSVersion, PackageID, Description |
                Out-GridView -Title 'Pick an image' -PassThru

            $path = $workdir + '\ConfigMgr\PackageInfo\' + $image.packageid
            if ((Test-Path -Path $path ) -eq $True) {
                Get-WWConfiguration -filename $path
            } else {
                Get-WWImageInformation -PackID $image.PackageID
            }
        })

        #Button to select new file path (may not need)
        #$WPFCMBFilePathSelect.Add_Click({ })

        #Button to add DP/DPG to list box on ConfigMgr tab
        $WPFCMBAddDP.Add_Click({ Select-WWDistributionPoint })

        #Button to remove DP/DPG from list box on ConfigMgr tab
        $WPFCMBRemoveDP.Add_Click({

                while ($WPFCMLBDPs.SelectedItems) {
                    $WPFCMLBDPs.Items.Remove($WPFCMLBDPs.SelectedItems[0])
                }

            })

        #Combo Box dynamic change ConfigMgr type
        $WPFCMCBImageType.add_SelectionChanged({ Enable-WWConfigManagerOption })

        #Combo Box Software Update Catalog source
        $WPFUSCBSelectCatalogSource.add_SelectionChanged({ Update-WWTabOption })

        #Button to remove items from Language Packs List Box
        $WPFCustomBLangPacksRemove.Add_Click({

                while ($WPFCustomLBLangPacks.SelectedItems) {
                    $WPFCustomLBLangPacks.Items.Remove($WPFCustomLBLangPacks.SelectedItems[0])
                }
            })

        #Button to remove items from LXP List Box
        $WPFCustomBLEPSRemove.Add_Click({

                while ($WPFCustomLBLEP.SelectedItems) {
                    $WPFCustomLBLEP.Items.Remove($WPFCustomLBLEP.SelectedItems[0])
                }

            })

        #Button to remove items from FOD List Box
        $WPFCustomBFODRemove.Add_Click({

                while ($WPFCustomLBFOD.SelectedItems) {
                    $WPFCustomLBFOD.Items.Remove($WPFCustomLBFOD.SelectedItems[0])
                }

            })

        #Button to select default app association XML
        $WPFCustomBDefaultApp.Add_Click({ Select-WWDefaultApplicationAssociation })

        #Button to select start menu XML
        $WPFCustomBStartMenu.Add_Click({ Select-WWStartMenu })

        #Button to select registry files
        $WPFCustomBRegistryAdd.Add_Click({ Select-WWRegistryFile })

        #Button to remove registry files
        $WPFCustomBRegistryRemove.Add_Click({

                while ($WPFCustomLBRegistry.SelectedItems) {
                    $WPFCustomLBRegistry.Items.Remove($WPFCustomLBRegistry.SelectedItems[0])
                }

            })

        #Button to select ISO save folder
        $WPFMISISOSelectButton.Add_Click({ Select-WWISODirectory })

        #Button to install CM Console Extension
        $WPFCMBInstallExtensions.Add_Click({ Install-WWConfigManagerConsoleExtension })

        #Button to set CM Site and Server properties
        $WPFCMBSetCM.Add_Click({
                Get-WWConfigManagerConnection
                Import-WWConfigManagerModule

            })


        #===========================================================================

        # Section for Checkboxes to call Functions
        #===========================================================================

        #Enable JSON Selection
        $WPFJSONEnableCheckBox.Add_Click( {
                If ($WPFJSONEnableCheckBox.IsChecked -eq $true) {
                    $WPFJSONButton.IsEnabled = $True
                    $WPFMISJSONTextBox.Text = 'True'
                } else {
                    $WPFJSONButton.IsEnabled = $False
                    $WPFMISJSONTextBox.Text = 'False'
                }
            })

        #Enable Driver Selection
        $WPFDriverCheckBox.Add_Click( {
                If ($WPFDriverCheckBox.IsChecked -eq $true) {
                    $WPFDriverDir1Button.IsEnabled = $True
                    $WPFDriverDir2Button.IsEnabled = $True
                    $WPFDriverDir3Button.IsEnabled = $True
                    $WPFDriverDir4Button.IsEnabled = $True
                    $WPFDriverDir5Button.IsEnabled = $True
                    $WPFMISDriverTextBox.Text = 'True'
                } else {
                    $WPFDriverDir1Button.IsEnabled = $False
                    $WPFDriverDir2Button.IsEnabled = $False
                    $WPFDriverDir3Button.IsEnabled = $False
                    $WPFDriverDir4Button.IsEnabled = $False
                    $WPFDriverDir5Button.IsEnabled = $False
                    $WPFMISDriverTextBox.Text = 'False'
                }
            })

        #Enable Updates Selection
        $WPFUpdatesEnableCheckBox.Add_Click( {
                If ($WPFUpdatesEnableCheckBox.IsChecked -eq $true) {
                    $WPFMISUpdatesTextBox.Text = 'True'
                } else {
                    $WPFMISUpdatesTextBox.Text = 'False'
                }
            })

        #Enable AppX Selection
        $WPFAppxCheckBox.Add_Click( {
                If ($WPFAppxCheckBox.IsChecked -eq $true) {
                    $WPFAppxButton.IsEnabled = $True
                    $WPFMISAppxTextBox.Text = 'True'
                } else {
                    $WPFAppxButton.IsEnabled = $False
                }
            })

        #Enable install.wim selection in import
        $WPFImportWIMCheckBox.Add_Click( {
                If ($WPFImportWIMCheckBox.IsChecked -eq $true) {
                    $WPFImportNewNameTextBox.IsEnabled = $True
                    $WPFImportImportButton.IsEnabled = $True
                } else {
                    $WPFImportNewNameTextBox.IsEnabled = $False
                    if ($WPFImportDotNetCheckBox.IsChecked -eq $False) { $WPFImportImportButton.IsEnabled = $False }
                }
            })

        #Enable .Net binaries selection in import
        $WPFImportDotNetCheckBox.Add_Click( {
                If ($WPFImportDotNetCheckBox.IsChecked -eq $true) {
                    $WPFImportImportButton.IsEnabled = $True
                } else {
                    if ($WPFImportWIMCheckBox.IsChecked -eq $False) { $WPFImportImportButton.IsEnabled = $False }
                }
            })

        #Enable Win10 version selection
        $WPFUpdatesW10Main.Add_Click( {
                If ($WPFUpdatesW10Main.IsChecked -eq $true) {
                    #$WPFUpdatesW10_1909.IsEnabled = $True
                    $WPFUpdatesW10_1903.IsEnabled = $True
                    $WPFUpdatesW10_1809.IsEnabled = $True
                    $WPFUpdatesW10_1803.IsEnabled = $True
                    $WPFUpdatesW10_1709.IsEnabled = $True
                    $WPFUpdatesW10_2004.IsEnabled = $True
                    $WPFUpdatesW10_20H2.IsEnabled = $True
                    $WPFUpdatesW10_21H1.IsEnabled = $True
                    $WPFUpdatesW10_21H2.IsEnabled = $True
                    $WPFUpdatesW10_22H2.IsEnabled = $True
                } else {
                    #$WPFUpdatesW10_1909.IsEnabled = $False
                    $WPFUpdatesW10_1903.IsEnabled = $False
                    $WPFUpdatesW10_1809.IsEnabled = $False
                    $WPFUpdatesW10_1803.IsEnabled = $False
                    $WPFUpdatesW10_1709.IsEnabled = $False
                    $WPFUpdatesW10_2004.IsEnabled = $False
                    $WPFUpdatesW10_20H2.IsEnabled = $False
                    $WPFUpdatesW10_21H1.IsEnabled = $False
                    $WPFUpdatesW10_21H2.IsEnabled = $False
                    $WPFUpdatesW10_22H2.IsEnabled = $False
                }
            })

        #Enable Win11 version selection
        $WPFUpdatesW11Main.Add_Click( {
                If ($WPFUpdatesW11Main.IsChecked -eq $true) {
                    $WPFUpdatesW11_21H2.IsEnabled = $True
                    $WPFUpdatesW11_22H2.IsEnabled = $True
                    $WPFUpdatesW11_23H2.IsEnabled = $True
                } else {
                    $WPFUpdatesW11_21H2.IsEnabled = $False
                    $WPFUpdatesW11_22H2.IsEnabled = $False
                    $WPFUpdatesW11_23H2.IsEnabled = $False

                }
            })

        #Enable LP Selection
        $WPFCustomCBLangPacks.Add_Click({
                If ($WPFCustomCBLangPacks.IsChecked -eq $true) {
                    $WPFCustomBLangPacksSelect.IsEnabled = $True
                    $WPFCustomBLangPacksRemove.IsEnabled = $True
                } else {
                    $WPFCustomBLangPacksSelect.IsEnabled = $False
                    $WPFCustomBLangPacksRemove.IsEnabled = $False
                }
            })

        #ENable Language Experience Pack selection
        $WPFCustomCBLEP.Add_Click({
                If ($WPFCustomCBLEP.IsChecked -eq $true) {
                    $WPFCustomBLEPSelect.IsEnabled = $True
                    $WPFCustomBLEPSRemove.IsEnabled = $True
                } else {
                    $WPFCustomBLEPSelect.IsEnabled = $False
                    $WPFCustomBLEPSRemove.IsEnabled = $False
                }
            })

        #Enable Feature On Demand selection
        $WPFCustomCBFOD.Add_Click({
                If ($WPFCustomCBFOD.IsChecked -eq $true) {
                    $WPFCustomBFODSelect.IsEnabled = $True
                    $WPFCustomBFODRemove.IsEnabled = $True
                } else {
                    $WPFCustomBFODSelect.IsEnabled = $False
                    $WPFCustomBFODRemove.IsEnabled = $False
                }
            })

        #Enable Run Script settings
        $WPFCustomCBRunScript.Add_Click({
                If ($WPFCustomCBRunScript.IsChecked -eq $true) {
                    $WPFCustomTBFile.IsEnabled = $True
                    $WPFCustomBSelectPath.IsEnabled = $True
                    $WPFCustomTBParameters.IsEnabled = $True
                    $WPFCustomCBScriptTiming.IsEnabled = $True
                } else {
                    $WPFCustomTBFile.IsEnabled = $False
                    $WPFCustomBSelectPath.IsEnabled = $False
                    $WPFCustomTBParameters.IsEnabled = $False
                    $WPFCustomCBScriptTiming.IsEnabled = $False
                } })

        #Enable Default App Association
        $WPFCustomCBEnableApp.Add_Click({
                If ($WPFCustomCBEnableApp.IsChecked -eq $true) {
                    $WPFCustomBDefaultApp.IsEnabled = $True

                } else {
                    $WPFCustomBDefaultApp.IsEnabled = $False
                }
            })

        #Enable Start Menu Layout
        $WPFCustomCBEnableStart.Add_Click({
                If ($WPFCustomCBEnableStart.IsChecked -eq $true) {
                    $WPFCustomBStartMenu.IsEnabled = $True

                } else {
                    $WPFCustomBStartMenu.IsEnabled = $False
                }
            })

        #Enable Registry selection list box buttons
        $WPFCustomCBEnableRegistry.Add_Click({
                If ($WPFCustomCBEnableRegistry.IsChecked -eq $true) {
                    $WPFCustomBRegistryAdd.IsEnabled = $True
                    $WPFCustomBRegistryRemove.IsEnabled = $True
                    $WPFCustomLBRegistry.IsEnabled = $True

                } else {
                    $WPFCustomBRegistryAdd.IsEnabled = $False
                    $WPFCustomBRegistryRemove.IsEnabled = $False
                    $WPFCustomLBRegistry.IsEnabled = $False

                }
            })

        #Enable ISO/Upgrade Package selection in import
        $WPFImportISOCheckBox.Add_Click( {
                If ($WPFImportISOCheckBox.IsChecked -eq $true) {
                    $WPFImportImportButton.IsEnabled = $True
                } else {
                    if (($WPFImportWIMCheckBox.IsChecked -eq $False) -and
                    ($WPFImportDotNetCheckBox.IsChecked -eq $False)) {
                        $WPFImportImportButton.IsEnabled = $False
                    }
                }
            })

        #Enable not creating stand alone wim
        $WPFMISCBNoWIM.Add_Click( {
                If ($WPFMISCBNoWIM.IsChecked -eq $true) {
                    $WPFMISWimNameTextBox.IsEnabled = $False
                    $WPFMISWimFolderTextBox.IsEnabled = $False
                    $WPFMISFolderButton.IsEnabled = $False

                    $WPFMISWimNameTextBox.text = 'install.wim'
                } else {
                    $WPFMISWimNameTextBox.IsEnabled = $True
                    $WPFMISWimFolderTextBox.IsEnabled = $True
                    $WPFMISFolderButton.IsEnabled = $True
                }
            })

        #Enable ISO creation fields
        $WPFMISCBISO.Add_Click( {
                If ($WPFMISCBISO.IsChecked -eq $true) {
                    $WPFMISTBISOFileName.IsEnabled = $True
                    $WPFMISTBFilePath.IsEnabled = $True
                    $WPFMISCBDynamicUpdates.IsEnabled = $True
                    $WPFMISCBNoWIM.IsEnabled = $True
                    $WPFMISCBBootWIM.IsEnabled = $True
                    $WPFMISISOSelectButton.IsEnabled = $true

                } else {
                    $WPFMISTBISOFileName.IsEnabled = $False
                    $WPFMISTBFilePath.IsEnabled = $False
                    $WPFMISISOSelectButton.IsEnabled = $false

                }
                if (($WPFMISCBISO.IsChecked -eq $false) -and ($WPFMISCBUpgradePackage.IsChecked -eq $false)) {
                    $WPFMISCBDynamicUpdates.IsEnabled = $False
                    $WPFMISCBDynamicUpdates.IsChecked = $False
                    $WPFMISCBNoWIM.IsEnabled = $False
                    $WPFMISCBNoWIM.IsChecked = $False
                    $WPFMISWimNameTextBox.IsEnabled = $true
                    $WPFMISWimFolderTextBox.IsEnabled = $true
                    $WPFMISFolderButton.IsEnabled = $true
                    $WPFMISCBBootWIM.IsChecked = $false
                    $WPFMISCBBootWIM.IsEnabled = $false
                }
            })

        #Enable upgrade package path option
        $WPFMISCBUpgradePackage.Add_Click( {
                If ($WPFMISCBUpgradePackage.IsChecked -eq $true) {
                    $WPFMISTBUpgradePackage.IsEnabled = $True
                    $WPFMISCBDynamicUpdates.IsEnabled = $True
                    $WPFMISCBNoWIM.IsEnabled = $True
                    $WPFMISCBBootWIM.IsEnabled = $True

                } else {
                    $WPFMISTBUpgradePackage.IsEnabled = $False
                }
                if (($WPFMISCBISO.IsChecked -eq $false) -and ($WPFMISCBUpgradePackage.IsChecked -eq $false)) {
                    $WPFMISCBDynamicUpdates.IsEnabled = $False
                    $WPFMISCBDynamicUpdates.IsChecked = $False
                    $WPFMISCBNoWIM.IsEnabled = $False
                    $WPFMISCBNoWIM.IsChecked = $False
                    $WPFMISWimNameTextBox.IsEnabled = $true
                    $WPFMISWimFolderTextBox.IsEnabled = $true
                    $WPFMISFolderButton.IsEnabled = $true
                    $WPFMISCBBootWIM.IsChecked = $false
                    $WPFMISCBBootWIM.IsEnabled = $false
                }
            })

        #Enable option to include Optional Updates
        $WPFUpdatesEnableCheckBox.Add_Click({
                if ($WPFUpdatesEnableCheckBox.IsChecked -eq $true) { $WPFUpdatesOptionalEnableCheckBox.IsEnabled = $True }
                else {
                    $WPFUpdatesOptionalEnableCheckBox.IsEnabled = $False
                    $WPFUpdatesOptionalEnableCheckBox.IsChecked = $False
                }
            })

        #==========================================================

        #Run WIM Witch below
        #==========================================================

        #Runs WIM Witch from a single file, bypassing the GUI
        if (($auto -eq $true) -and ($autofile -ne '')) {
            Invoke-WWConfigFile -filename $autofile
            Write-WWClosingMessage
            exit 0
        }

        #Runs WIM from a path with multiple files, bypassing the GUI
        if (($auto -eq $true) -and ($autopath -ne '')) {
            Write-WimWitchLog -data "Running batch job from config folder $autopath" -Class Information
            $files = Get-ChildItem -Path $autopath
            Write-WimWitchLog -data 'Setting batch job for the folling configs:' -Class Information
            foreach ($file in $files) { Write-WimWitchLog -Data $file -Class Information }
            foreach ($file in $files) {
                $fullpath = $autopath + '\' + $file
                Invoke-WWConfigFile -filename $fullpath
            }
            Write-WimWitchLog -Data 'Work complete' -Class Information
            Write-WWClosingMessage
            exit 0
        }

        #Loads the specified ConfigMgr config file from CM Console
        if (($CM -eq 'Edit') -and ($autofile -ne '')) {
            Write-WimWitchLog -Data 'Loading ConfigMgr OS Image Package information...' -Class Information
            Get-WWConfiguration -filename $autofile
        }

        #Closing action for the WPF form
        Register-ObjectEvent -InputObject $form -EventName Closed -Action ( { Write-WWClosingMessage }) | Out-Null

        #display text information to the user
        Send-WWNotification

        if ($HiHungryImDad -eq $true) {
            $string = Invoke-WWDadJoke
            Write-WimWitchLog -Data $string -Class Comment
            $WPFImportBDJ.Visibility = 'Visible'
        }

        # Check for module updates automatically
        $form.Add_ContentRendered({
            $updateResult = Invoke-WimWitchUpgrade
            if ($updateResult -eq "restart") {
                # Close the form first
                $form.Close()

                # Start a new PowerShell process with WimWitch-Reloaded
                $startInfo = New-Object System.Diagnostics.ProcessStartInfo
                $startInfo.FileName = "powershell.exe"
                $startInfo.Arguments = "-NoProfile -Command Import-Module WimWitch-Reloaded; Start-WimWitch"
                $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal

                # Start the process
                [System.Diagnostics.Process]::Start($startInfo)

                # Exit current PowerShell session completely
                [Environment]::Exit(0)
            }
        })

        #Start GUI
        Write-WimWitchLog -data 'Starting WIM Witch GUI' -class Information
        $form.ShowDialog() | Out-Null #This starts the GUI

        #endregion Main
    }
}