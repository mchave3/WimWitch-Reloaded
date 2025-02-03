<#
.SYNOPSIS
    Display a dialog box to select the correct version of Windows 10 v2XXX.

.DESCRIPTION
    This function displays a dialog box to select the correct version of Windows 10 v2XXX.

.NOTES
    Name:        Invoke-19041Select.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-03
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Invoke-19041Select
#>
function Invoke-19041Select {
    [CmdletBinding()]
    param(

    )

    process {
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
}
