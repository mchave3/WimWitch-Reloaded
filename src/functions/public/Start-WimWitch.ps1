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
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Start-WimWitch
#>
function Start-WimWitch {

    #Requires -Version 5.1
    #Requires -Modules OSDSUS, OSDUpdate
    #-- Requires -ShellId <ShellId>
    # Requires -RunAsAdministrator
    #-- Requires -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]

    [CmdletBinding()]
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
        [string]$CM = 'none',

        [parameter(mandatory = $false, HelpMessage = 'Used to skip lengthy steps')]
        [switch]$demomode,

        [parameter(mandatory = $false, HelpMessage = 'Select working directory')]
        [string]$global:workdir
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
        $inputXML = @"
<Window x:Class="WIM_Witch_Tabbed.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WIM_Witch_Tabbed"
        mc:Ignorable="d"
        Title="WimWitch Reloaded - $WWScriptVer" 
        Width="800"
        Height="500"
        WindowStartupLocation="CenterScreen"
        WindowState="Normal"
        ResizeMode="CanMinimize">
    <Grid>
        <TabControl x:Name="TabControl" Margin="-3,-1,3,1" Background="#FFACACAC" 
            BorderBrush="#FF610536" >
            <TabItem Header="Import WIM + .Net" Height="20" MinWidth="100">
                <Grid>
                    <TextBox x:Name="ImportISOTextBox" HorizontalAlignment="Left" Height="42" 
                        Margin="26,85,0,0" Text="ISO to import from..." 
                        VerticalAlignment="Top" Width="500" IsEnabled="False" 
                        HorizontalScrollBarVisibility="Visible"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,56,0,0" TextWrapping="Wrap" 
                        Text="Select a Windows ISO:" VerticalAlignment="Top" Height="26" Width="353"/>
                    <Button x:Name="ImportImportSelectButton" Content="Select" HorizontalAlignment="Left" 
                        Margin="553,85,0,0" VerticalAlignment="Top" Width="75"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,149,0,0" TextWrapping="Wrap" 
                        Text="Select the item(s) to import:" VerticalAlignment="Top" Width="263"/>
                    <CheckBox x:Name="ImportWIMCheckBox" Content="Install.wim" HorizontalAlignment="Left" 
                        Margin="44,171,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="ImportDotNetCheckBox" Content=".Net Binaries" HorizontalAlignment="Left" 
                        Margin="44,191,0,0" VerticalAlignment="Top"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,240,0,0" TextWrapping="Wrap" 
                        Text="New name for the imported WIM:" VerticalAlignment="Top" Width="311"/>
                    <TextBox x:Name="ImportNewNameTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="26,261,0,0" TextWrapping="Wrap" Text="Name for the imported WIM" 
                        VerticalAlignment="Top" Width="500" IsEnabled="False"/>
                    <Button x:Name="ImportImportButton" Content="Import" HorizontalAlignment="Left" 
                        Margin="553,261,0,0" VerticalAlignment="Top" Width="75" IsEnabled="False"/>
                    <CheckBox x:Name="ImportISOCheckBox" Content="ISO / Upgrade Package Files" 
                        HorizontalAlignment="Left" Margin="44,212,0,0" VerticalAlignment="Top"/>
                    <Button x:Name="ImportBDJ" Content="Tell Me a Dad Joke" HorizontalAlignment="Left" 
                        Margin="639,383,0,0" VerticalAlignment="Top" Width="109" Visibility="Hidden"/>
                </Grid>
            </TabItem>
            <TabItem Header="Import LP+FOD" Margin="0" MinWidth="100">
                <Grid>
                    <TextBox x:Name="ImportOtherTBPath" HorizontalAlignment="Left" Height="23" 
                        Margin="49,92,0,0" TextWrapping="Wrap" Text="path to source" 
                        VerticalAlignment="Top" Width="339" IsEnabled="False"/>
                    <Button x:Name="ImportOtherBSelectPath" Content="Select" HorizontalAlignment="Left" 
                        Margin="413,94,0,0" VerticalAlignment="Top" Width="75"/>
                    <TextBlock HorizontalAlignment="Left" Margin="49,130,0,0" TextWrapping="Wrap" 
                        Text="Selected items" VerticalAlignment="Top"/>
                    <ComboBox x:Name="ImportOtherCBWinOS" HorizontalAlignment="Left" Margin="228,51,0,0" 
                        VerticalAlignment="Top" Width="120"/>
                    <ComboBox x:Name="ImportOtherCBWinVer" HorizontalAlignment="Left" Margin="371,50,0,0" 
                        VerticalAlignment="Top" Width="120"/>
                    <Button x:Name="ImportOtherBImport" Content="Import" HorizontalAlignment="Left" 
                        Margin="417,317,0,0" VerticalAlignment="Top" Width="75"/>
                    <ComboBox x:Name="ImportOtherCBType" HorizontalAlignment="Left" Margin="51,51,0,0" 
                        VerticalAlignment="Top" Width="160"/>
                    <TextBlock HorizontalAlignment="Left" Margin="51,26,0,0" TextWrapping="Wrap" 
                        Text="Object Type" VerticalAlignment="Top"/>
                    <TextBlock HorizontalAlignment="Left" Margin="230,32,0,0" TextWrapping="Wrap" 
                        Text="Windows OS" VerticalAlignment="Top"/>
                    <TextBlock HorizontalAlignment="Left" Margin="372,31,0,0" TextWrapping="Wrap" 
                        Text="Version" VerticalAlignment="Top"/>
                    <ListBox x:Name="ImportOtherLBList" HorizontalAlignment="Left" Height="149" 
                        Margin="49,151,0,0" VerticalAlignment="Top" Width="442"/>

                </Grid>

            </TabItem>
            <TabItem x:Name="CustomTab" Header="Pause + Scripts" MinWidth="100">
                <Grid>
                    <TextBox x:Name="CustomTBFile" HorizontalAlignment="Left" Height="23" 
                        Margin="49,157,0,0" TextWrapping="Wrap" Text="PowerShell Script" 
                        VerticalAlignment="Top" Width="501" IsEnabled="False"/>
                    <TextBox x:Name="CustomTBParameters" HorizontalAlignment="Left" Height="23" 
                        Margin="49,207,0,0" TextWrapping="Wrap" Text="Parameters" 
                        VerticalAlignment="Top" Width="501" IsEnabled="False"/>
                    <Button x:Name="CustomBSelectPath" Content="Select" HorizontalAlignment="Left" 
                        Margin="566,158,0,0" VerticalAlignment="Top" Width="75" IsEnabled="False"/>
                    <CheckBox x:Name="CustomCBRunScript" Content="Run Script" HorizontalAlignment="Left" 
                        Margin="49,102,0,0" VerticalAlignment="Top"/>
                    <ComboBox x:Name="CustomCBScriptTiming" HorizontalAlignment="Left" Margin="163,102,0,0" 
                        VerticalAlignment="Top" Width="172" IsEnabled="False"/>
                    <CheckBox x:Name="MISCBPauseMount" Content="Pause after mounting" 
                        HorizontalAlignment="Left" Margin="49,42,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="MISCBPauseDismount" Content="Pause before dismounting" 
                        HorizontalAlignment="Left" Margin="49,71,0,0" VerticalAlignment="Top"/>
                </Grid>
            </TabItem>
            <TabItem Header="Drivers" Height="20" MinWidth="100">
                <Grid>
                    <TextBox x:Name="DriverDir1TextBox" HorizontalAlignment="Left" Height="25" 
                        Margin="26,144,0,0" TextWrapping="Wrap" Text="Select Driver Source Folder" 
                        VerticalAlignment="Top" Width="500" IsEnabled="False"/>
                    <Label x:Name="DirverDirLabel" Content="Driver Source" HorizontalAlignment="Left" 
                        Height="25" Margin="26,114,0,0" VerticalAlignment="Top" Width="100"/>
                    <Button x:Name="DriverDir1Button" Content="Select" HorizontalAlignment="Left" 
                        Height="25" Margin="562,144,0,0" VerticalAlignment="Top" Width="75" 
                        IsEnabled="False"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,20,0,0" TextWrapping="Wrap" 
                        Text="Select the path to the driver source(s) that contains the drivers that will be injected." 
                        VerticalAlignment="Top" Height="42" Width="353"/>
                    <CheckBox x:Name="DriverCheckBox" Content="Enable Driver Injection" 
                        HorizontalAlignment="Left" Margin="26,80,0,0" VerticalAlignment="Top"/>
                    <TextBox x:Name="DriverDir2TextBox" HorizontalAlignment="Left" Height="25" 
                        Margin="26,189,0,0" TextWrapping="Wrap" Text="Select Driver Source Folder" 
                        VerticalAlignment="Top" Width="500" IsEnabled="False"/>
                    <Button x:Name="DriverDir2Button" Content="Select" HorizontalAlignment="Left" 
                        Height="25" Margin="562,189,0,0" VerticalAlignment="Top" Width="75" 
                        IsEnabled="False"/>
                    <TextBox x:Name="DriverDir3TextBox" HorizontalAlignment="Left" Height="25" 
                        Margin="26,234,0,0" TextWrapping="Wrap" Text="Select Driver Source Folder" 
                        VerticalAlignment="Top" Width="500" IsEnabled="False"/>
                    <Button x:Name="DriverDir3Button" Content="Select" HorizontalAlignment="Left" 
                        Height="25" Margin="562,234,0,0" VerticalAlignment="Top" Width="75" 
                        IsEnabled="False"/>
                    <TextBox x:Name="DriverDir4TextBox" HorizontalAlignment="Left" Height="25" 
                        Margin="26,281,0,0" TextWrapping="Wrap" Text="Select Driver Source Folder" 
                        VerticalAlignment="Top" Width="500" IsEnabled="False"/>
                    <Button x:Name="DriverDir4Button" Content="Select" HorizontalAlignment="Left" 
                        Height="25" Margin="562,281,0,0" VerticalAlignment="Top" Width="75" 
                        IsEnabled="False"/>
                    <TextBox x:Name="DriverDir5TextBox" HorizontalAlignment="Left" Height="25" 
                        Margin="26,328,0,0" TextWrapping="Wrap" Text="Select Driver Source Folder" 
                        VerticalAlignment="Top" Width="500" IsEnabled="False"/>
                    <Button x:Name="DriverDir5Button" Content="Select" HorizontalAlignment="Left" 
                        Height="25" Margin="562,328,0,0" VerticalAlignment="Top" Width="75" 
                        IsEnabled="False"/>
                </Grid>
            </TabItem>
            <TabItem x:Name="AutopilotTab" Header="Autopilot" MinWidth="100">
                <Grid>
                    <TextBox x:Name="JSONTextBox" HorizontalAlignment="Left" Height="25" 
                        Margin="26,130,0,0" TextWrapping="Wrap" Text="Select JSON File" 
                        VerticalAlignment="Top" Width="500" IsEnabled="False"/>
                    <Label x:Name="JSONLabel" Content="Source JSON" HorizontalAlignment="Left" 
                        Height="25" Margin="26,104,0,0" VerticalAlignment="Top" Width="100"/>
                    <Button x:Name="JSONButton" Content="Select" HorizontalAlignment="Left" 
                        Height="25" Margin="451,165,0,0" VerticalAlignment="Top" Width="75" 
                        IsEnabled="False"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,20,0,0" TextWrapping="Wrap" 
                        Text="Select a JSON file for use in deploying Autopilot systems. The file will be copied to processing folder during the build" 
                        VerticalAlignment="Top" Height="42" Width="353"/>
                    <CheckBox x:Name="JSONEnableCheckBox" Content="Enable Autopilot " 
                        HorizontalAlignment="Left" Margin="26,80,0,0" VerticalAlignment="Top" 
                        ClickMode="Press"/>
                    <TextBox x:Name="ZtdCorrelationId" HorizontalAlignment="Left" Height="23" 
                        Margin="129,176,0,0" TextWrapping="Wrap" Text="Select JSON File..." 
                        VerticalAlignment="Top" Width="236" IsEnabled="False"/>
                    <TextBox x:Name="CloudAssignedTenantDomain" HorizontalAlignment="Left" 
                        Height="23" Margin="129,204,0,0" TextWrapping="Wrap" Text="Select JSON File..." 
                        VerticalAlignment="Top" Width="236" IsEnabled="False"/>
                    <TextBox x:Name="Comment_File" HorizontalAlignment="Left" Height="23" 
                        Margin="129,232,0,0" TextWrapping="Wrap" Text="Select JSON File..." 
                        VerticalAlignment="Top" Width="236" IsEnabled="False"/>
                    <TextBlock HorizontalAlignment="Left" Margin="24,178,0,0" TextWrapping="Wrap" 
                        Text="ZTD ID#" VerticalAlignment="Top"/>
                    <TextBlock HorizontalAlignment="Left" Margin="24,204,0,0" TextWrapping="Wrap" 
                        Text="Tenant Name" VerticalAlignment="Top"/>
                    <TextBlock HorizontalAlignment="Left" Margin="24,233,0,0" TextWrapping="Wrap" 
                        Text="Deployment Profile" VerticalAlignment="Top"/>
                    <TextBox x:Name="JSONTextBoxSavePath" HorizontalAlignment="Left" Height="23" 
                        Margin="26,345,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" 
                        Width="499" IsEnabled="False"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,275,0,0" TextWrapping="Wrap" 
                        Text="To download a new Autopilot profile from Intune, click select to choose the folder to save the file to. Then click Retrieve Profile." 
                        VerticalAlignment="Top" Height="48" Width="331"/>
                    <TextBlock HorizontalAlignment="Left" Margin="27,328,0,0" TextWrapping="Wrap" 
                        Text="Path to save file:" VerticalAlignment="Top"/>
                    <Button x:Name="JSONButtonSavePath" Content="Select" HorizontalAlignment="Left" 
                        Margin="450,373,0,0" VerticalAlignment="Top" Width="75"/>
                    <Button x:Name="JSONButtonRetrieve" Content="Retrieve Profile" 
                        HorizontalAlignment="Left" Margin="382,275,0,0" VerticalAlignment="Top" 
                        Width="130"/>
                </Grid>
            </TabItem>
            <TabItem Header="Save/Load" Height="20" MinWidth="102">
                <Grid>
                    <TextBox x:Name="SLSaveFileName" HorizontalAlignment="Left" Height="25" 
                        Margin="26,85,0,0" TextWrapping="Wrap" Text="Name for saved configuration..." 
                        VerticalAlignment="Top" Width="500"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,38,0,0" TextWrapping="Wrap" 
                        Text="Provide a name for the saved configuration" VerticalAlignment="Top" 
                        Height="42" Width="353"/>
                    <Button x:Name="SLSaveButton" Content="Save" HorizontalAlignment="Left" 
                        Margin="451,127,0,0" VerticalAlignment="Top" Width="75"/>
                    <Border BorderBrush="Black" BorderThickness="1" HorizontalAlignment="Left" 
                        Height="1" Margin="0,216,0,0" VerticalAlignment="Top" Width="785"/>
                    <TextBox x:Name="SLLoadTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="26,308,0,0" TextWrapping="Wrap" Text="Select configuration file to load" 
                        VerticalAlignment="Top" Width="500"/>
                    <Button x:Name="SLLoadButton" Content="Load" HorizontalAlignment="Left" 
                        Margin="451,351,0,0" VerticalAlignment="Top" Width="75"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,279,0,0" TextWrapping="Wrap" 
                        Text="Select configuration file to load" VerticalAlignment="Top" Width="353"/>
                </Grid>
            </TabItem>
            <TabItem Header="Source WIM" Margin="0" MinWidth="100">
                <Grid>
                    <TextBox x:Name="SourceWIMSelectWIMTextBox" HorizontalAlignment="Left" 
                        Height="25" Margin="26,98,0,0" TextWrapping="Wrap" Text="Select WIM File" 
                        VerticalAlignment="Top" Width="500" IsEnabled="False" Grid.ColumnSpan="2"/>
                    <Label Content="Source Wim " HorizontalAlignment="Left" Height="25" 
                        Margin="26,70,0,0" VerticalAlignment="Top" Width="100"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,20,0,0" TextWrapping="Wrap" 
                        Text="Select the WIM file, and then Edition, that will serve as the base for the custom WIM." 
                        VerticalAlignment="Top" Height="42" Width="353" Grid.ColumnSpan="2"/>
                    <Button x:Name="SourceWIMSelectButton" Content="Select" HorizontalAlignment="Left" 
                        Height="25" Margin="450,153,0,0" VerticalAlignment="Top" Width="75"/>
                    <TextBox x:Name="SourceWIMImgDesTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="94,155,0,0" TextWrapping="Wrap" Text="ImageDescription" 
                        VerticalAlignment="Top" Width="339" IsEnabled="False"/>
                    <TextBox x:Name="SourceWimArchTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="94,183,0,0" TextWrapping="Wrap" Text="Architecture" 
                        VerticalAlignment="Top" Width="225" IsEnabled="False"/>
                    <TextBox x:Name="SourceWimVerTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="94,211,0,0" TextWrapping="Wrap" Text="Build" VerticalAlignment="Top" 
                        Width="225" IsEnabled="False"/>
                    <TextBox x:Name="SourceWimSPBuildTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="94,239,0,0" TextWrapping="Wrap" Text="SPBuild" VerticalAlignment="Top" 
                        Width="225" IsEnabled="False"/>
                    <TextBox x:Name="SourceWimLangTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="94,267,0,0" TextWrapping="Wrap" Text="Languages" 
                        VerticalAlignment="Top" Width="225" IsEnabled="False"/>
                    <Label Content="Edition" HorizontalAlignment="Left" Height="30" Margin="22,151,0,0" 
                        VerticalAlignment="Top" Width="68"/>
                    <Label Content="Arch" HorizontalAlignment="Left" Height="30" Margin="22,183,0,0" 
                        VerticalAlignment="Top" Width="68"/>
                    <Label Content="Build" HorizontalAlignment="Left" Height="30" Margin="22,211,0,0" 
                        VerticalAlignment="Top" Width="68"/>
                    <Label Content="Patch Level" HorizontalAlignment="Left" Height="30" 
                        Margin="22,239,0,0" VerticalAlignment="Top" Width="68"/>
                    <Label Content="Languages" HorizontalAlignment="Left" Height="30" 
                        Margin="22,267,0,0" VerticalAlignment="Top" Width="68"/>
                    <TextBox x:Name="SourceWimIndexTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="94,297,0,0" TextWrapping="Wrap" Text="Index" VerticalAlignment="Top" 
                        Width="225" IsEnabled="False"/>
                    <Label Content="Index" HorizontalAlignment="Left" Height="30" Margin="22,297,0,0" 
                        VerticalAlignment="Top" Width="68"/>
                    <TextBox x:Name="SourceWimTBVersionNum" HorizontalAlignment="Left" Height="23" 
                        Margin="94,325,0,0" TextWrapping="Wrap" Text="Version Number" 
                        VerticalAlignment="Top" Width="225" IsEnabled="False"/>
                    <Label Content="Version" HorizontalAlignment="Left" Height="30" Margin="22,321,0,0" 
                        VerticalAlignment="Top" Width="68"/>
                </Grid>
            </TabItem>
            <TabItem Header="Update Catalog" Height="20" MinWidth="100" Margin="-2,0,-2,0" 
                VerticalAlignment="Top">
                <Grid>
                    <ComboBox x:Name="USCBSelectCatalogSource"  HorizontalAlignment="Left" 
                        Margin="26,48,0,0" VerticalAlignment="Top" Width="160" />
                    <TextBlock HorizontalAlignment="Left" Margin="91,275,0,0" TextWrapping="Wrap" 
                        Text="Installed version " VerticalAlignment="Top"/>
                    <TextBox x:Name="UpdatesOSDBVersion" HorizontalAlignment="Left" Height="23" 
                        Margin="91,297,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120" 
                        IsEnabled="False"/>
                    <Button x:Name="UpdateOSDBUpdateButton" Content="Install / Update" 
                        HorizontalAlignment="Left" Margin="218,362,0,0" VerticalAlignment="Top" 
                        Width="120"/>
                    <TextBlock HorizontalAlignment="Left" Height="42" Margin="31,85,0,0" 
                        TextWrapping="Wrap" Text="Select which versions of Windows to download current patches for. Downloading will also purge superseded updates." 
                        VerticalAlignment="Top" Width="335"/>
                    <CheckBox x:Name="UpdatesW10_1903" Content="1903" HorizontalAlignment="Left" 
                        Margin="67,183,0,0" VerticalAlignment="Top" IsEnabled="False" Visibility="Hidden"/>
                    <CheckBox x:Name="UpdatesW10_1809" Content="1809" HorizontalAlignment="Left" 
                        Margin="282,190,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                    <CheckBox x:Name="UpdatesW10_1803" Content="1803" HorizontalAlignment="Left" 
                        Margin="194,182,0,0" VerticalAlignment="Top" IsEnabled="False" 
                        Visibility="Hidden"/>
                    <CheckBox x:Name="UpdatesW10_1709" Content="1709" HorizontalAlignment="Left" 
                        Margin="251,182,0,0" VerticalAlignment="Top" IsEnabled="False" 
                        Visibility="Hidden"/>
                    <Button x:Name="UpdatesDownloadNewButton" Content="Download" 
                        HorizontalAlignment="Left" Margin="291,239,0,0" VerticalAlignment="Top" 
                        Width="75"/>
                    <TextBox x:Name="UpdatesOSDBCurrentVerTextBox" HorizontalAlignment="Left" 
                        Height="23" Margin="218,296,0,0" TextWrapping="Wrap" VerticalAlignment="Top" 
                        Width="120" IsEnabled="False"/>
                    <TextBlock HorizontalAlignment="Left" Margin="218,275,0,0" TextWrapping="Wrap" 
                        Text="Current Version" VerticalAlignment="Top"/>
                    <TextBlock x:Name="UpdatesOSDBOutOfDateTextBlock" HorizontalAlignment="Left" 
                        Margin="417,364,0,0" TextWrapping="Wrap" Text="A software update module is out of date. Please click the &quot;Install / Update&quot; button to update it." 
                        VerticalAlignment="Top" RenderTransformOrigin="0.493,0.524" Width="321" 
                        Visibility="Hidden"  />
                    <TextBlock x:Name="UpdatesOSDBSupercededExistTextBlock" HorizontalAlignment="Left" 
                        Margin="417,328,0,0" TextWrapping="Wrap" Text="Superceded updates discovered. Please select the versions of Windows 10 you are supporting and click &quot;Update&quot;" 
                        VerticalAlignment="Top" Width="375" Visibility="Hidden" />
                    <TextBlock x:Name="UpdatesOSDBClosePowerShellTextBlock" HorizontalAlignment="Left" 
                        Margin="417,292,0,0" TextWrapping="Wrap" Text="Please close all PowerShell windows, including WIM Witch, then relaunch app to continue" 
                        VerticalAlignment="Top" RenderTransformOrigin="0.493,0.524" Width="321" 
                        Visibility="Hidden"/>
                    <TextBlock HorizontalAlignment="Left" Margin="24,297,0,0" TextWrapping="Wrap" 
                        Text="OSDUpdate" VerticalAlignment="Top"/>
                    <TextBlock HorizontalAlignment="Left" Margin="26,334,0,0" TextWrapping="Wrap" 
                        Text="OSDSUS" VerticalAlignment="Top"/>
                    <TextBox x:Name="UpdatesOSDSUSVersion" HorizontalAlignment="Left" Height="23" 
                        Margin="91,330,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120" 
                        IsEnabled="False"/>
                    <TextBox x:Name="UpdatesOSDSUSCurrentVerTextBox" HorizontalAlignment="Left" 
                        Height="23" Margin="218,330,0,0" TextWrapping="Wrap" VerticalAlignment="Top" 
                        Width="120" IsEnabled="False"/>
                    <CheckBox x:Name="UpdatesW10Main" Content="Windows 10" HorizontalAlignment="Left" 
                        Margin="46,172,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="UpdatesS2016" Content="Windows Server 2016" 
                        HorizontalAlignment="Left" Margin="44,251,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="UpdatesS2019" Content="Windows Server 2019" 
                        HorizontalAlignment="Left" Margin="44,232,0,0" VerticalAlignment="Top"/>
                    <TextBlock x:Name="UpdatesOSDBClosePowerShellTextBlock_Copy" 
                        HorizontalAlignment="Left" Margin="26,27,0,0" TextWrapping="Wrap" 
                        Text="Select Update Catalog Source" VerticalAlignment="Top" 
                        RenderTransformOrigin="0.493,0.524" Width="321"/>
                    <ListBox x:Name="UpdatesOSDListBox" HorizontalAlignment="Left" Height="107" 
                        Margin="391,275,0,0" VerticalAlignment="Top" Width="347"/>
                    <CheckBox x:Name="UpdatesW10_2004" Content="2004" HorizontalAlignment="Left" 
                        Margin="193,175,0,0" VerticalAlignment="Top" IsEnabled="False" 
                        Visibility="Hidden"/>
                    <TextBlock HorizontalAlignment="Left" Margin="391,35,0,0" TextWrapping="Wrap" 
                        Text="Download Additional Update Types" VerticalAlignment="Top"/>
                    <CheckBox x:Name="UpdatesCBEnableOptional" Content="Optional Updates" 
                        HorizontalAlignment="Left" Margin="421,55,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="UpdatesCBEnableDynamic" Content="Dynamic Updates" 
                        HorizontalAlignment="Left" Margin="421,77,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="UpdatesW10_20H2" Content="20H2" HorizontalAlignment="Left" 
                        Margin="225,190,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                    <CheckBox x:Name="UpdatesW10_21h1" Content="21H1" HorizontalAlignment="Left" 
                        Margin="169,190,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                    <CheckBox x:Name="UpdatesW11Main" Content="Windows 11" HorizontalAlignment="Left" 
                        Margin="46,135,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="UpdatesS2022" Content="Windows Server 2022" 
                        HorizontalAlignment="Left" Margin="44,215,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="UpdatesW10_21h2" Content="21H2" HorizontalAlignment="Left" 
                        Margin="112,190,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                    <CheckBox x:Name="UpdatesW11_22h2" Content="22H2" HorizontalAlignment="Left" 
                        Margin="112,152,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                    <CheckBox x:Name="UpdatesW11_21h2" Content="21H2" HorizontalAlignment="Left" 
                        Margin="168,153,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                    <CheckBox x:Name="UpdatesW10_22h2" Content="22H2" HorizontalAlignment="Left" 
                        Margin="58,190,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                    <CheckBox x:Name="UpdatesW11_23h2" Content="23H2" HorizontalAlignment="Left" 
                        Margin="58,152,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                </Grid>
            </TabItem>
            <TabItem Header="Customizations" Height="20" MinWidth="100">
                <Grid>
                    <CheckBox x:Name="CustomCBLangPacks" Content="Inject Language Packs" 
                        HorizontalAlignment="Left" Margin="29,37,0,0" VerticalAlignment="Top"/>
                    <Button x:Name="CustomBLangPacksSelect" Content="Select" HorizontalAlignment="Left" 
                        Margin="251,27,0,0" VerticalAlignment="Top" Width="132" IsEnabled="False"/>
                    <ListBox x:Name="CustomLBLangPacks" HorizontalAlignment="Left" Height="135" 
                        Margin="29,74,0,0" VerticalAlignment="Top" Width="355"/>
                    <TextBlock HorizontalAlignment="Left" Margin="32,55,0,0" TextWrapping="Wrap" 
                        Text="Selected LP's" VerticalAlignment="Top" Width="206"/>
                    <CheckBox x:Name="CustomCBFOD" Content="Inject Features on Demand" 
                        HorizontalAlignment="Left" Margin="419,126,0,0" VerticalAlignment="Top"/>
                    <Button x:Name="CustomBFODSelect" Content="Select" HorizontalAlignment="Left" 
                        Margin="625,120,0,0" VerticalAlignment="Top" Width="133" IsEnabled="False"/>
                    <ListBox x:Name="CustomLBFOD" HorizontalAlignment="Left" Height="224" 
                        Margin="419,171,0,0" VerticalAlignment="Top" Width="340"/>
                    <TextBlock HorizontalAlignment="Left" Margin="421,147,0,0" TextWrapping="Wrap" 
                        Text="Select from imported Features" VerticalAlignment="Top" Width="206"/>
                    <CheckBox x:Name="CustomCBLEP" Content="Inject Local Experience Packs" 
                        HorizontalAlignment="Left" Margin="32,217,0,0" VerticalAlignment="Top"/>
                    <Button x:Name="CustomBLEPSelect" Content="Select" HorizontalAlignment="Left" 
                        Margin="251,212,0,0" VerticalAlignment="Top" Width="132" IsEnabled="False"/>
                    <ListBox x:Name="CustomLBLEP" HorizontalAlignment="Left" Height="137" 
                        Margin="29,258,0,0" VerticalAlignment="Top" Width="355"/>
                    <TextBlock HorizontalAlignment="Left" Margin="32,237,0,0" TextWrapping="Wrap" 
                        Text="Selected LXP's" VerticalAlignment="Top" Width="206"/>
                    <CheckBox x:Name="MISDotNetCheckBox" Content="Inject .Net 3.5" 
                        HorizontalAlignment="Left" Margin="418,49,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="MISOneDriveCheckBox" Content="Update OneDrive client" 
                        HorizontalAlignment="Left" Margin="418,74,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="UpdatesEnableCheckBox" Content="Enable Updates" 
                        HorizontalAlignment="Left" Margin="580,49,0,0" VerticalAlignment="Top" 
                        ClickMode="Press"/>
                    <Button x:Name="CustomBLangPacksRemove" Content="Remove" HorizontalAlignment="Left" 
                        Margin="251,49,0,0" VerticalAlignment="Top" Width="132" IsEnabled="False"/>
                    <Button x:Name="CustomBLEPSRemove" Content="Remove" HorizontalAlignment="Left" 
                        Margin="251,235,0,0" VerticalAlignment="Top" Width="132" IsEnabled="False"/>
                    <Button x:Name="CustomBFODRemove" Content="Remove" HorizontalAlignment="Left" 
                        Margin="625,144,0,0" VerticalAlignment="Top" Width="133" IsEnabled="False"/>
                    <CheckBox x:Name="UpdatesOptionalEnableCheckBox" Content="Include Optional" 
                        HorizontalAlignment="Left" Margin="596,65,0,0" VerticalAlignment="Top" 
                        ClickMode="Press" IsEnabled="False"/>
                </Grid>
            </TabItem>
            <TabItem Header="Other Custom" Height="20" MinWidth="100">
                <Grid>
                    <ListBox x:Name="CustomLBRegistry" HorizontalAlignment="Left" Height="100" 
                        Margin="31,247,0,0" VerticalAlignment="Top" Width="440" IsEnabled="False"/>
                    <Button x:Name="CustomBRegistryAdd" Content="Add" HorizontalAlignment="Left" 
                        Margin="296,362,0,0" VerticalAlignment="Top" Width="75" IsEnabled="False"/>
                    <Button x:Name="CustomBRegistryRemove" Content="Remove" HorizontalAlignment="Left" 
                        Margin="391,362,0,0" VerticalAlignment="Top" Width="75" IsEnabled="False"/>
                    <CheckBox x:Name="CustomCBEnableRegistry" Content="Enable Registry Files" 
                        HorizontalAlignment="Left" Margin="31,227,0,0" VerticalAlignment="Top"/>
                    <TextBox x:Name="CustomTBStartMenu" HorizontalAlignment="Left" Height="23" 
                        Margin="31,174,0,0" TextWrapping="Wrap" Text="Select Start Menu XML" 
                        VerticalAlignment="Top" Width="440" IsEnabled="False"/>
                    <Button x:Name="CustomBStartMenu" Content="Select" HorizontalAlignment="Left" 
                        Margin="396,202,0,0" VerticalAlignment="Top" Width="75" IsEnabled="False"/>
                    <CheckBox x:Name="CustomCBEnableStart" Content="Enable Start Menu Layout" 
                        HorizontalAlignment="Left" Margin="30,152,0,0" VerticalAlignment="Top"/>
                    <TextBox x:Name="CustomTBDefaultApp" HorizontalAlignment="Left" Height="23" 
                        Margin="31,92,0,0" TextWrapping="Wrap" Text="Select Default App XML" 
                        VerticalAlignment="Top" Width="440" IsEnabled="False"/>
                    <Button x:Name="CustomBDefaultApp" Content="Select" HorizontalAlignment="Left" 
                        Margin="396,120,0,0" VerticalAlignment="Top" Width="75" IsEnabled="False"/>
                    <CheckBox x:Name="CustomCBEnableApp" Content="Enable Default App Association" 
                        HorizontalAlignment="Left" Margin="30,70,0,0" VerticalAlignment="Top"/>
                </Grid>
            </TabItem>
            <TabItem x:Name="AppTab" Header ="App Removal" Height="20" MinWidth="100">
                <Grid>
                    <TextBox x:Name="AppxTextBox" TextWrapping="Wrap" Text="Select the apps to remove..." 
                        Margin="21,85,252.2,22.8" VerticalScrollBarVisibility="Visible"/>
                    <TextBlock HorizontalAlignment="Left" Margin="21,65,0,0" TextWrapping="Wrap" 
                        Text="Selected app packages to remove:" VerticalAlignment="Top" Height="15" 
                        Width="194"/>
                    <CheckBox x:Name="AppxCheckBox" Content="Enable app removal" 
                        HorizontalAlignment="Left" Margin="21,33,0,0" VerticalAlignment="Top"/>
                    <Button x:Name="AppxButton" Content="Select" HorizontalAlignment="Left" 
                        Margin="202,33,0,0" VerticalAlignment="Top" Width="75"/>
                </Grid>
            </TabItem>
            <TabItem Header="ConfigMgr" Height="20" MinWidth="102">
                <Grid>
                    <ComboBox x:Name="CMCBImageType" HorizontalAlignment="Left" Margin="39,37,0,0" 
                        VerticalAlignment="Top" Width="165"/>
                    <TextBox x:Name="CMTBPackageID" HorizontalAlignment="Left" Height="23" 
                        Margin="39,80,0,0" TextWrapping="Wrap" Text="Package ID" VerticalAlignment="Top" 
                        Width="120"/>
                    <TextBox x:Name="CMTBImageName" HorizontalAlignment="Left" Height="23" 
                        Margin="39,111,0,0" TextWrapping="Wrap" Text="Image Name" VerticalAlignment="Top" 
                        Width="290"/>
                    <ListBox x:Name="CMLBDPs" HorizontalAlignment="Left" Height="100" 
                        Margin="444,262,0,0" VerticalAlignment="Top" Width="285"/>
                    <TextBox x:Name="CMTBWinBuildNum" HorizontalAlignment="Left" Height="23" 
                        Margin="40,142,0,0" TextWrapping="Wrap" Text="Window Build Number" 
                        VerticalAlignment="Top" Width="290"/>
                    <TextBox x:Name="CMTBImageVer" HorizontalAlignment="Left" Height="23" 
                        Margin="41,187,0,0" TextWrapping="Wrap" Text="Image Version" 
                        VerticalAlignment="Top" Width="290"/>
                    <TextBox x:Name="CMTBDescription" HorizontalAlignment="Left" Height="91" 
                        Margin="41,216,0,0" TextWrapping="Wrap" Text="Description" 
                        VerticalAlignment="Top" Width="290"/>
                    <CheckBox x:Name="CMCBBinDirRep" Content="Enable Binary Differential Replication" 
                        HorizontalAlignment="Left" Margin="39,313,0,0" VerticalAlignment="Top"/>
                    <Button x:Name="CMBSelectImage" Content="Select Image" HorizontalAlignment="Left" 
                        Margin="230,80,0,0" VerticalAlignment="Top" Width="99"/>
                    <TextBox x:Name="CMTBSitecode" HorizontalAlignment="Left" Height="23" 
                        Margin="444,112,0,0" TextWrapping="Wrap" Text="Site Code" VerticalAlignment="Top" 
                        Width="120"/>
                    <TextBox x:Name="CMTBSiteServer" HorizontalAlignment="Left" Height="23" 
                        Margin="444,153,0,0" TextWrapping="Wrap" Text="Site Server" 
                        VerticalAlignment="Top" Width="228"/>
                    <Button x:Name="CMBAddDP" Content="Add" HorizontalAlignment="Left" 
                        Margin="444,370,0,0" VerticalAlignment="Top" Width="75"/>
                    <Button x:Name="CMBRemoveDP" Content="Remove" HorizontalAlignment="Left" 
                        Margin="532,370,0,0" VerticalAlignment="Top" Width="75"/>
                    <ComboBox x:Name="CMCBDPDPG" HorizontalAlignment="Left" Margin="444,234,0,0" 
                        VerticalAlignment="Top" Width="228"/>
                    <CheckBox x:Name="CMCBDeploymentShare" Content="Enable Package Share" 
                        HorizontalAlignment="Left" Margin="39,333,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="CMCBImageVerAuto" Content="Auto Fill" HorizontalAlignment="Left" 
                        Margin="336,187,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="CMCBDescriptionAuto" Content="Auto Fill" 
                        HorizontalAlignment="Left" Margin="336,217,0,0" VerticalAlignment="Top"/>
                    <Button x:Name="CMBInstallExtensions" Content="Install" HorizontalAlignment="Left" 
                        Margin="444,55,0,0" VerticalAlignment="Top" Width="75"/>
                    <TextBlock HorizontalAlignment="Left" Margin="445,36,0,0" TextWrapping="Wrap" 
                        Text="Click to install CM Console Extension" VerticalAlignment="Top"/>
                    <TextBlock HorizontalAlignment="Left" Margin="445,94,0,0" TextWrapping="Wrap" 
                        Text="Site Code" VerticalAlignment="Top"/>
                    <TextBlock HorizontalAlignment="Left" Margin="445,136,0,0" TextWrapping="Wrap" 
                        Text="Site Server" VerticalAlignment="Top"/>
                    <Button x:Name="CMBSetCM" Content="Set" HorizontalAlignment="Left" 
                        Margin="444,180,0,0" VerticalAlignment="Top" Width="75"/>

                </Grid>
            </TabItem>
            <TabItem Header="Make It So" Height="20" MinWidth="100">
                <Grid>
                    <CheckBox x:Name="MISCBCheckForUpdates" Margin="544,19,15,376" 
                        Content="Check for updates when running" />
                    <Button x:Name="MISFolderButton" Content="Select" HorizontalAlignment="Left" 
                        Margin="444,144,0,0" VerticalAlignment="Top" Width="75" 
                        RenderTransformOrigin="0.39,-2.647"/>
                    <TextBox x:Name="MISWimNameTextBox" HorizontalAlignment="Left" Height="25" 
                        Margin="20,85,0,0" TextWrapping="Wrap" Text="Enter Target WIM Name" 
                        VerticalAlignment="Top" Width="500"/>
                    <TextBox x:Name="MISDriverTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="658,345,0,0" TextWrapping="Wrap" Text="Driver Y/N" 
                        VerticalAlignment="Top" Width="120" IsEnabled="False"/>
                    <Label Content="Driver injection?" HorizontalAlignment="Left" Height="30" 
                        Margin="551,343,0,0" VerticalAlignment="Top" Width="101"/>
                    <TextBox x:Name="MISJSONTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="658,374,0,0" TextWrapping="Wrap" Text="JSON Select Y/N" 
                        VerticalAlignment="Top" Width="120" IsEnabled="False"/>
                    <Label Content="JSON injection?" HorizontalAlignment="Left" Margin="551,372,0,0" 
                        VerticalAlignment="Top" Width="102"/>
                    <TextBox x:Name="MISWimFolderTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="20,115,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" 
                        Width="500"/>
                    <TextBlock HorizontalAlignment="Left" Margin="20,20,0,0" TextWrapping="Wrap" 
                        Text="Enter a name, and select a destination folder, for the  image to be created. Once complete, and build parameters verified, click &quot;Make it so!&quot; to start the build." 
                        VerticalAlignment="Top" Height="60" Width="353"/>
                    <Button x:Name="MISMakeItSoButton" Content="Make it so!" HorizontalAlignment="Left" 
                        Margin="400,20,0,0" VerticalAlignment="Top" Width="120" Height="29" FontSize="16"/>
                    <TextBox x:Name="MISMountTextBox" HorizontalAlignment="Left" Height="25" 
                        Margin="19,191,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" 
                        Width="500" IsEnabled="False"/>
                    <Label Content="Mount Path" HorizontalAlignment="Left" Margin="19,166,0,0" 
                        VerticalAlignment="Top" Height="25" Width="100"/>
                    <Button x:Name="MISMountSelectButton" Content="Select" HorizontalAlignment="Left" 
                        Margin="444,221,0,0" VerticalAlignment="Top" Width="75" Height="25"/>
                    <Label Content="Update injection?" HorizontalAlignment="Left" 
                        Margin="551,311,0,0" VerticalAlignment="Top" Width="109"/>
                    <TextBox x:Name="MISUpdatesTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="658,314,0,0" TextWrapping="Wrap" Text="Updates Y/N" 
                        VerticalAlignment="Top" Width="120" RenderTransformOrigin="0.171,0.142" 
                        IsEnabled="False"/>
                    <Label Content="App removal?" HorizontalAlignment="Left" Margin="551,280,0,0" 
                        VerticalAlignment="Top" Width="109"/>
                    <TextBox x:Name="MISAppxTextBox" HorizontalAlignment="Left" Height="23" 
                        Margin="658,283,0,0" TextWrapping="Wrap" Text="Updates Y/N" 
                        VerticalAlignment="Top" Width="120" RenderTransformOrigin="0.171,0.142" 
                        IsEnabled="False"/>
                    <CheckBox x:Name="MISCBDynamicUpdates" Margin="544,40,15,355" 
                        Content="Apply Dynamic Update" IsEnabled="False" />
                    <CheckBox x:Name="MISCBBootWIM" Margin="544,62,15,337" Content="Update Boot.WIM" 
                        IsEnabled="False" />
                    <TextBox x:Name="MISTBISOFileName" HorizontalAlignment="Left" Height="23" 
                        Margin="21,268,0,0" TextWrapping="Wrap" Text="ISO File Name" 
                        VerticalAlignment="Top" Width="498" IsEnabled="False"/>
                    <TextBox x:Name="MISTBFilePath" HorizontalAlignment="Left" Height="23" 
                        Margin="21,296,0,0" TextWrapping="Wrap" Text="ISO File Path" 
                        VerticalAlignment="Top" Width="498" IsEnabled="False"/>
                    <CheckBox x:Name="MISCBISO" Content="Create ISO" HorizontalAlignment="Left" 
                        Margin="21,248,0,0" VerticalAlignment="Top"/>
                    <CheckBox x:Name="MISCBNoWIM" Margin="544,85,15,312" 
                        Content="Do Not Create Stand Alone WIM" IsEnabled="False"/>
                    <TextBox x:Name="MISTBUpgradePackage" HorizontalAlignment="Left" Height="23" 
                        Margin="23,368,0,0" TextWrapping="Wrap" Text="Upgrade Package Path" 
                        VerticalAlignment="Top" Width="494" IsEnabled="False"/>
                    <CheckBox x:Name="MISCBUpgradePackage" Content="Upgrade Package Path" 
                        HorizontalAlignment="Left" Margin="22,347,0,0" VerticalAlignment="Top"/>
                    <Button x:Name="MISISOSelectButton" Content="Select" HorizontalAlignment="Left" 
                        Margin="444,324,0,0" VerticalAlignment="Top" Width="75" Height="25" 
                        IsEnabled="False"/>
                </Grid>
            </TabItem>
        </TabControl>
    </Grid>
    <Window.TaskbarItemInfo>
        <TaskbarItemInfo/>
    </Window.TaskbarItemInfo>
</Window>
"@

        $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window'
        [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
        [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
        [xml]$XAML = $inputXML
        #Read XAML

        $reader = (New-Object System.Xml.XmlNodeReader $xaml)
        try {
            $Form = [Windows.Markup.XamlReader]::Load( $reader )
        } catch {
            Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
            throw
        }

        #===========================================================================
        # Load XAML Objects In PowerShell
        #===========================================================================

        $xaml.SelectNodes('//*[@Name]') | ForEach-Object { "trying item $($_.Name)" | Out-Null
            try { Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop }
            catch { throw }
        }

        #Section to do the icon magic
        ###################################################
        $base64 = "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"
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
        $form.TaskbarItemInfo.Description = "WIM Witch - $wwscriptver"
        ###################################################

        #endregion XAML

        #region Main
        #===========================================================================
        # Run commands to set values of files and variables, etc.
        #===========================================================================

        # Calls fuction to display the opening text blurb

        Show-OpeningText

        # Get-FormVariables #lists all WPF variables
        $global:workdir = Select-WorkingDirectory
        Test-WorkingDirectory

        # Set the path and name for logging
        $Log = "$global:workdir\logging\WIMWitch.log"

        # Clears out old logs from previous builds and checks for other folders
        Set-Logging

        # Test for admin and exit if not
        Test-Admin

        # Setting default values for the WPF form
        $WPFMISWimFolderTextBox.Text = "$global:workdir\CompletedWIMs"
        $WPFMISMountTextBox.Text = "$global:workdir\Mount"
        $WPFJSONTextBoxSavePath.Text = "$global:workdir\Autopilot"


        ##################
        # Prereq Check segment

        #Check for installed PowerShell version
        if ($PSVersionTable.PSVersion.Major -ge 5) { Update-Log -Data 'PowerShell v5 or greater installed.' -Class Information }
        else {
            Update-Log -data 'PowerShell v5 or greater is required. Please upgrade PowerShell and try again.' -Class Error
            Show-ClosingText
            exit 0
        }


        #Check for admin rights
        #Invoke-AdminCheck

        #Check for 32 bit architecture
        Invoke-ArchitectureCheck

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

        $global:Win10VerDet = ''

        #===========================================================================
        # Section for Combo box Functions
        #===========================================================================

        #Set the combo box values of the other import tab

        $ObjectTypes = @('Language Pack', 'Local Experience Pack', 'Feature On Demand')
        $WinOS = @('Windows Server', 'Windows 10', 'Windows 11')
        $WinSrvVer = @('2019', '21H2')
        $Win10Ver = @('1809', '2004')
        $Win11Ver = @('21H2', '22H2', '23H2')

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


        Enable-ConfigMgrOptions

        #Software Update Catalog Source combo box
        $UpdateSourceCombos = @('None', 'OSDSUS', 'ConfigMgr')
        foreach ($UpdateSourceCombo in $UpdateSourceCombos) { $WPFUSCBSelectCatalogSource.Items.Add($UpdateSourceCombo) | Out-Null }
        $WPFUSCBSelectCatalogSource.SelectedIndex = 0
        Invoke-UpdateTabOptions

        #Check for ConfigMgr and set integration
        if ((Find-ConfigManager) -eq 0) {

            if ((Import-CMModule) -eq 0) {
                $WPFUSCBSelectCatalogSource.SelectedIndex = 2
                Invoke-UpdateTabOptions
            }
        } else
        { Update-Log -Data 'Skipping ConfigMgr PowerShell module importation' }

        #Set OSDSUS to Patch Catalog if CM isn't integratedg

        if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 0) {
            Update-Log -Data 'Setting OSDSUS as the Update Catalog' -Class Information
            $WPFUSCBSelectCatalogSource.SelectedIndex = 1
            Invoke-UpdateTabOptions
        }

        #Function Get-WindowsPatches($build,$OS)

        if ($DownloadUpdates -eq $true) {
            #    If (($UpdatePoShModules -eq $true) -and ($WPFUpdatesOSDBOutOfDateTextBlock.Visibility -eq "Visible")) {
            If ($UpdatePoShModules -eq $true ) {
                Update-OSDB
                Update-OSDSUS
            }


            if ($Server2016 -eq $true) {
                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                    Test-Superceded -action delete -OS 'Windows Server' -Build 1607
                    Get-WindowsPatches -OS 'Windows Server' -build 1607
                }


                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows Server' -Ver 1607
                    Invoke-MEMCMUpdatecatalog -prod 'Windows Server' -Ver 1607
                }
            }

            if ($Server2019 -eq $true) {
                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                    Test-Superceded -action delete -OS 'Windows Server' -Build 1809
                    Get-WindowsPatches -OS 'Windows Server' -build 1809
                }

                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows Server' -Ver 1809
                    Invoke-MEMCMUpdatecatalog -prod 'Windows Server' -Ver 1809
                }
            }

            if ($Server2022 -eq $true) {
                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                    Test-Superceded -action delete -OS 'Windows Server' -Build 21H2
                    Get-WindowsPatches -OS 'Windows Server' -build 21H2
                }


                if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                    Invoke-MEMCMUpdateSupersedence -prod 'Windows Server' -Ver 21H2
                    Invoke-MEMCMUpdatecatalog -prod 'Windows Server' -Ver 21H2
                }
            }


            if ($Win10Version -ne 'none') {
                if (($Win10Version -eq '1709')) {
                    # -or ($Win10Version -eq "all")){
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 10' -Build 1709
                        Get-WindowsPatches -OS 'Windows 10' -build 1709
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver 1709
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -Ver 1709
                    }
                }

                if (($Win10Version -eq '1803')) {
                    # -or ($Win10Version -eq "all")){
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 10' -Build 1803
                        Get-WindowsPatches -OS 'Windows 10' -build 1803
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver 1803
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -Ver 1803
                    }
                }

                if (($Win10Version -eq '1809') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 10' -Build 1809
                        Get-WindowsPatches -OS 'Windows 10' -build 1809
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver 1809
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -Ver 1809
                    }
                }


                if (($Win10Version -eq '1903')) {
                    # -or ($Win10Version -eq "all")){
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 10' -Build 1903
                        Get-WindowsPatches -OS 'Windows 10' -build 1903
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver 1903
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -Ver 1903
                    }
                }


                if (($Win10Version -eq '1909') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 10' -Build 1909
                        Get-WindowsPatches -OS 'Windows 10' -build 1909
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver 1909
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -Ver 1909
                    }
                }

                if (($Win10Version -eq '2004') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 10' -Build 2004
                        Get-WindowsPatches -OS 'Windows 10' -build 2004
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver 2004
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -Ver 2004
                    }
                }

                if (($Win10Version -eq '20H2') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 10' -Build 2009
                        Get-WindowsPatches -OS 'Windows 10' -build 2009
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver 2009
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -Ver 2009
                    }
                }

                if (($Win10Version -eq '21H1') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 10' -Build 21H1
                        Get-WindowsPatches -OS 'Windows 10' -build 21H1
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver 21H1
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -Ver 21H1
                    }
                }

                if (($Win10Version -eq '21H2') -or ($Win10Version -eq 'all')) {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 10' -Build 21H2
                        Get-WindowsPatches -OS 'Windows 10' -build 21H2
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 10' -Ver 21H2
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 10' -Ver 21H2
                    }
                }

                if ($Win11Version -eq '21H2') {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 11' -Build 21H2
                        Get-WindowsPatches -OS 'Windows 11' -build 21H2
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 11' -Ver 21H2
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 11' -Ver 21H2
                    }
                }
                if ($Win11Version -eq '22H2') {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 11' -Build 22H2
                        Get-WindowsPatches -OS 'Windows 11' -build 22H2
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 11' -Ver 22H2
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 11' -Ver 22H2
                    }
                }
                if ($Win11Version -eq '23H2') {
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 1) {
                        Test-Superceded -action delete -OS 'Windows 11' -Build 23H2
                        Get-WindowsPatches -OS 'Windows 11' -build 23H2
                    }
                    if ($WPFUSCBSelectCatalogSource.SelectedIndex -eq 2) {
                        Invoke-MEMCMUpdateSupersedence -prod 'Windows 11' -Ver 23H2
                        Invoke-MEMCMUpdatecatalog -prod 'Windows 11' -Ver 23H2
                    }
                }

                Get-OneDrive
            }
        }

        #===========================================================================
        # Section for Buttons to call Functions
        #===========================================================================

        #Mount Dir Button
        $WPFMISMountSelectButton.Add_Click( { Select-Mountdir })

        #Source WIM File Button
        $WPFSourceWIMSelectButton.Add_Click( { Select-SourceWIM })

        #JSON File selection Button
        $WPFJSONButton.Add_Click( { Select-JSONFile })

        #Target Folder selection Button
        $WPFMISFolderButton.Add_Click( { Select-TargetDir })

        #Driver Directory Buttons
        $WPFDriverDir1Button.Add_Click( { Select-DriverSource -DriverTextBoxNumber $WPFDriverDir1TextBox })
        $WPFDriverDir2Button.Add_Click( { Select-DriverSource -DriverTextBoxNumber $WPFDriverDir2TextBox })
        $WPFDriverDir3Button.Add_Click( { Select-DriverSource -DriverTextBoxNumber $WPFDriverDir3TextBox })
        $WPFDriverDir4Button.Add_Click( { Select-DriverSource -DriverTextBoxNumber $WPFDriverDir4TextBox })
        $WPFDriverDir5Button.Add_Click( { Select-DriverSource -DriverTextBoxNumber $WPFDriverDir5TextBox })

        #Make it So Button, which builds the WIM file
        $WPFMISMakeItSoButton.Add_Click( { Invoke-MakeItSo -appx $global:SelectedAppx })

        #Update OSDBuilder Button
        $WPFUpdateOSDBUpdateButton.Add_Click( {
                Update-OSDB
                Update-OSDSUS
            })

        #Update patch source
        $WPFUpdatesDownloadNewButton.Add_Click( { Update-PatchSource })

        #Select Appx packages to remove
        $WPFAppxButton.Add_Click( { $global:SelectedAppx = Select-Appx })

        #Select Autopilot path to save button
        $WPFJSONButtonSavePath.Add_Click( { Select-NewJSONDir })

        #retrieve autopilot profile from intune
        $WPFJSONButtonRetrieve.Add_click( { get-wwautopilotprofile -login $WPFJSONTextBoxAADID.Text -path $WPFJSONTextBoxSavePath.Text })

        #Button to save configuration file
        $WPFSLSaveButton.Add_click( { Save-Configuration -filename $WPFSLSaveFileName.text })

        #Button to load configuration file
        $WPFSLLoadButton.Add_click( { Select-Config })

        #Button to select ISO for importation
        $WPFImportImportSelectButton.Add_click( { Select-ISO })

        #Button to import content from iso
        $WPFImportImportButton.Add_click( { Import-ISO })

        #Combo Box dynamic change for Winver combo box
        $WPFImportOtherCBWinOS.add_SelectionChanged({ Update-ImportVersionCB })

        #Button to select the import path in the other components
        $WPFImportOtherBSelectPath.add_click({ Select-ImportOtherPath

                if ($WPFImportOtherCBType.SelectedItem -ne 'Feature On Demand') {
                    if ($WPFImportOtherCBWinOS.SelectedItem -ne 'Windows 11') { $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text | Select-Object -Property Name | Out-GridView -Title 'Select Objects' -PassThru) }
                    if (($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') -and ($WPFImportOtherCBType.SelectedItem -eq 'Language Pack')) { $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text | Select-Object -Property Name | Where-Object { ($_.Name -like '*Windows-Client-Language-Pack*') } | Out-GridView -Title 'Select Objects' -PassThru) }
                    if (($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') -and ($WPFImportOtherCBType.SelectedItem -eq 'Local Experience Pack')) { $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text | Select-Object -Property Name | Out-GridView -Title 'Select Objects' -PassThru) }

                }

                if ($WPFImportOtherCBType.SelectedItem -eq 'Feature On Demand') {
                    if ($WPFImportOtherCBWinOS.SelectedItem -ne 'Windows 11') { $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text) }
                    if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows 11') { $items = (Get-ChildItem -Path $WPFImportOtherTBPath.text | Select-Object -Property Name | Where-Object { ($_.Name -notlike '*Windows-Client-Language-Pack*') } | Out-GridView -Title 'Select Objects' -PassThru) }

                }


                $WPFImportOtherLBList.Items.Clear()
                $count = 0
                $path = $WPFImportOtherTBPath.text
                foreach ($item in $items) {
                    $WPFImportOtherLBList.Items.Add($item.name)
                    $count = $count + 1
                }

                if ($wpfImportOtherCBType.SelectedItem -eq 'Language Pack') { Update-Log -data "$count Language Packs selected from $path" -Class Information }
                if ($wpfImportOtherCBType.SelectedItem -eq 'Local Experience Pack') { Update-Log -data "$count Local Experience Packs selected from $path" -Class Information }
                if ($wpfImportOtherCBType.SelectedItem -eq 'Feature On Demand') { Update-Log -data "Features On Demand source selected from $path" -Class Information }

            })

        #Button to import Other Components content
        $WPFImportOtherBImport.add_click({
                if ($WPFImportOtherCBWinOS.SelectedItem -eq 'Windows Server') {
                    if ($WPFImportOtherCBWinVer.SelectedItem -eq '2019') { $WinVerConversion = '1809' }
                } else {
                    $WinVerConversion = $WPFImportOtherCBWinVer.SelectedItem
                }

                if ($WPFImportOtherCBType.SelectedItem -eq 'Language Pack') { Import-LanguagePacks -Winver $WinVerConversion -WinOS $WPFImportOtherCBWinOS.SelectedItem -LPSourceFolder $WPFImportOtherTBPath.text }
                if ($WPFImportOtherCBType.SelectedItem -eq 'Local Experience Pack') { Import-LocalExperiencePack -Winver $WinVerConversion -WinOS $WPFImportOtherCBWinOS.SelectedItem -LPSourceFolder $WPFImportOtherTBPath.text }
                if ($WPFImportOtherCBType.SelectedItem -eq 'Feature On Demand') { Import-FeatureOnDemand -Winver $WinVerConversion -WinOS $WPFImportOtherCBWinOS.SelectedItem -LPSourceFolder $WPFImportOtherTBPath.text } })

        #Button Select LP's for importation
        $WPFCustomBLangPacksSelect.add_click({ Select-LPFODCriteria -type 'LP' })

        #Button to select FODs for importation
        $WPFCustomBFODSelect.add_click({ Select-LPFODCriteria -type 'FOD' })

        #Button to select LXPs for importation
        $WPFCustomBLEPSelect.add_click({ Select-LPFODCriteria -type 'LXP' })

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
                $image = (Get-WmiObject -Namespace "root\SMS\Site_$($global:SiteCode)" -Class SMS_ImagePackage -ComputerName $global:SiteServer) | Select-Object -Property Name, version, language, ImageOSVersion, PackageID, Description | Out-GridView -Title 'Pick an image' -PassThru
                $path = $workdir + '\ConfigMgr\PackageInfo\' + $image.packageid
                if ((Test-Path -Path $path ) -eq $True) {
                    # write-host "True"
                    Get-Configuration -filename $path
                } else {
                    Get-ImageInfo -PackID $image.PackageID
                }
            })

        #Button to select new file path (may not need)
        #$WPFCMBFilePathSelect.Add_Click({ })

        #Button to add DP/DPG to list box on ConfigMgr tab
        $WPFCMBAddDP.Add_Click({ Select-DistributionPoints })

        #Button to remove DP/DPG from list box on ConfigMgr tab
        $WPFCMBRemoveDP.Add_Click({

                while ($WPFCMLBDPs.SelectedItems) {
                    $WPFCMLBDPs.Items.Remove($WPFCMLBDPs.SelectedItems[0])
                }

            })

        #Combo Box dynamic change ConfigMgr type
        $WPFCMCBImageType.add_SelectionChanged({ Enable-ConfigMgrOptions })

        #Combo Box Software Update Catalog source
        $WPFUSCBSelectCatalogSource.add_SelectionChanged({ Invoke-UpdateTabOptions })

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
        $WPFCustomBDefaultApp.Add_Click({ Select-DefaultApplicationAssociations })

        #Button to select start menu XML
        $WPFCustomBStartMenu.Add_Click({ Select-StartMenu })

        #Button to select registry files
        $WPFCustomBRegistryAdd.Add_Click({ Select-RegFiles })

        #Button to remove registry files
        $WPFCustomBRegistryRemove.Add_Click({

                while ($WPFCustomLBRegistry.SelectedItems) {
                    $WPFCustomLBRegistry.Items.Remove($WPFCustomLBRegistry.SelectedItems[0])
                }

            })

        #Button to select ISO save folder
        $WPFMISISOSelectButton.Add_Click({ Select-ISODirectory })

        #Button to install CM Console Extension
        $WPFCMBInstallExtensions.Add_Click({ Install-WWCMConsoleExtension })

        #Button to set CM Site and Server properties
        $WPFCMBSetCM.Add_Click({
                Set-ConfigMgr
                Import-CMModule

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
                    if (($WPFImportWIMCheckBox.IsChecked -eq $False) -and ($WPFImportDotNetCheckBox.IsChecked -eq $False)) { $WPFImportImportButton.IsEnabled = $False }
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
            Invoke-RunConfigFile -filename $autofile
            Show-ClosingText
            exit 0
        }

        #Runs WIM from a path with multiple files, bypassing the GUI
        if (($auto -eq $true) -and ($autopath -ne '')) {
            Update-Log -data "Running batch job from config folder $autopath" -Class Information
            $files = Get-ChildItem -Path $autopath
            Update-Log -data 'Setting batch job for the folling configs:' -Class Information
            foreach ($file in $files) { Update-Log -Data $file -Class Information }
            foreach ($file in $files) {
                $fullpath = $autopath + '\' + $file
                Invoke-RunConfigFile -filename $fullpath
            }
            Update-Log -Data 'Work complete' -Class Information
            Show-ClosingText
            exit 0
        }

        #Loads the specified ConfigMgr config file from CM Console
        if (($CM -eq 'Edit') -and ($autofile -ne '')) {
            Update-Log -Data 'Loading ConfigMgr OS Image Package information...' -Class Information
            Get-Configuration -filename $autofile
        }

        #Closing action for the WPF form
        Register-ObjectEvent -InputObject $form -EventName Closed -Action ( { Show-ClosingText }) | Out-Null

        #display text information to the user
        Invoke-TextNotification

        if ($HiHungryImDad -eq $true) {
            $string = Invoke-DadJoke
            Update-Log -Data $string -Class Comment
            $WPFImportBDJ.Visibility = 'Visible'
        }

        #Start GUI
        Update-Log -data 'Starting WIM Witch GUI' -class Information
        $Form.ShowDialog() | Out-Null #This starts the GUI

        #endregion Main
    }
}