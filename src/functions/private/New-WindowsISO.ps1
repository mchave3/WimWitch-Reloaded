<#
.SYNOPSIS
    Create a new Windows ISO file.

.DESCRIPTION
    This function creates a new Windows ISO file from the modified WIM file and staged content. 
    It handles the ISO creation process using oscdimg and manages any errors that occur during the process.

.NOTES
    Name:        New-WindowsISO.ps1
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
    New-WindowsISO
#>
function New-WindowsISO {
    [CmdletBinding()]
    param(

    )

    process {
        $oscdimgPath = "${env:ProgramFiles(x86)}" + 
            '\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe'
        if ((Test-Path -Path $oscdimgPath -PathType Leaf) -eq $false) {
            Write-WWLog -Data 'The file oscdimg.exe was not found. Skipping ISO creation...' -Class Error
            return
        }
    
        If ($WPFMISTBISOFileName.Text -notlike '*.iso') {
            $WPFMISTBISOFileName.Text = $WPFMISTBISOFileName.Text + '.iso'
            Write-WWLog -Data 'Appending new file name with an extension' -Class Information
        }
    
        $Location = ${env:ProgramFiles(x86)}
        $executable = $location + 
            '\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe'
        $bootbin = $Script:workdir + '\staging\media\efi\microsoft\boot\efisys.bin'
        $source = $Script:workdir + '\staging\media'
        $folder = $WPFMISTBFilePath.text
        $file = $WPFMISTBISOFileName.text
        $dest = "$folder\$file"
        $text = "-b$bootbin"
    
        if ((Test-Path -Path $dest) -eq $true) { Rename-Name -file $dest -extension '.iso' }
        try {
            Write-WWLog -Data 'Starting to build ISO...' -Class Information
            # write-host $executable
            Start-Process $executable -args @(
                "`"$text`"",
                '-pEF',
                '-u1',
                '-udfver102',
                "`"$source`"",
                "`"$dest`""
            ) -Wait -ErrorAction Stop
            Write-WWLog -Data 'ISO has been built' -Class Information
        } catch {
            Write-WWLog -Data "Couldn't create the ISO file" -Class Error
            Write-WWLog -data $_.Exception.Message -class Error
        }
    }
}
