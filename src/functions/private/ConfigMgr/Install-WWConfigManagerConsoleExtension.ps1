<#
.SYNOPSIS
    Install WimWitch ConfigMgr console extension.

.DESCRIPTION
    This function installs the WimWitch extension for the Configuration Manager console.
    It handles the installation process and validates the results.

.NOTES
    Name:        Install-WWConfigManagerConsoleExtension.ps1
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
    Install-WWConfigManagerConsoleExtension
#>
function Install-WWConfigManagerConsoleExtension {
    [CmdletBinding()]
    param(

    )

    process {
        $UpdateWWXML = @"
<ActionDescription Class ="Executable" DisplayName="Update with WIM Witch" MnemonicDisplayName="Update with WIM Witch"
    Description="Click to update the image with WIM Witch">
	<ShowOn>
		<string>ContextMenu</string>
		<string>DefaultHomeTab</string>
	</ShowOn>
	<Executable>
		<FilePath>$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe</FilePath>
		<Parameters> -ExecutionPolicy Bypass -File "$PSCommandPath" -auto -autofile
            "$script:workingDirectory\ConfigMgr\PackageInfo\##SUB:PackageID##"</Parameters>
	</Executable>
</ActionDescription>
"@

        $EditWWXML = @"
<ActionDescription Class ="Executable" DisplayName="Edit WIM Witch Image Config"
    MnemonicDisplayName="Edit WIM Witch Image Config" Description="Click to edit the WIM Witch image configuration">
	<ShowOn>
		<string>ContextMenu</string>
		<string>DefaultHomeTab</string>
	</ShowOn>
	<Executable>
		<FilePath>$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe</FilePath>
		<Parameters> -ExecutionPolicy Bypass -File "$PSCommandPath" -CM "Edit" -autofile
            "$script:workingDirectory\ConfigMgr\PackageInfo\##SUB:PackageID##"</Parameters>
	</Executable>
</ActionDescription>
"@

        $NewWWXML = @"
<ActionDescription Class ="Executable" DisplayName="New WIM Witch Image"
    MnemonicDisplayName="New WIM Witch Image" Description="Click to create a new WIM Witch image">
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

        Write-WimWitchLog -Data 'Installing ConfigMgr console extension...' -Class Information

        $ConsoleFolderImage = '828a154e-4c7d-4d7f-ba6c-268443cdb4e8' #folder for update and edit

        $ConsoleFolderRoot = 'ac16f420-2d72-4056-a8f6-aef90e66a10c' #folder for new

        $path = ($env:SMS_ADMIN_UI_PATH -replace 'bin\\i386', '') + 'XmlStorage\Extensions\Actions'

        Write-WimWitchLog -Data 'Creating folders if needed...' -Class Information

        if ((Test-Path -Path (Join-Path -Path $path -ChildPath $ConsoleFolderImage)) -eq $false) {
            New-Item -Path $path -Name $ConsoleFolderImage -ItemType 'directory' | Out-Null
        }

        Write-WimWitchLog -data 'Creating extension files...' -Class Information

        $UpdateWWXML | Out-File ((Join-Path -Path $path -ChildPath $ConsoleFolderImage) + '\UpdateWWImage.xml') -Force
        $EditWWXML | Out-File ((Join-Path -Path $path -ChildPath $ConsoleFolderImage) + '\EditWWImage.xml') -Force

        Write-WimWitchLog -Data 'Creating folders if needed...' -Class Information

        if ((Test-Path -Path (Join-Path -Path $path -ChildPath $ConsoleFolderRoot)) -eq $false) {
            New-Item -Path $path -Name $ConsoleFolderRoot -ItemType 'directory' | Out-Null
        }
        Write-WimWitchLog -data 'Creating extension files...' -Class Information

        $NewWWXML | Out-File ((Join-Path -Path $path -ChildPath $ConsoleFolderRoot) + '\NewWWImage.xml') -Force

        Write-WimWitchLog -Data 'Console extension installation complete!' -Class Information
    }
}

