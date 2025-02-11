<#
.SYNOPSIS
    Check for update supersedence against ConfigMgr.

.DESCRIPTION
    This function will check for update supersedence against ConfigMgr.

.NOTES
    Name:        Invoke-WWConfigManagerUpdateSupersedence.ps1
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
    Invoke-WWConfigManagerUpdateSupersedence -prod "Windows 10" -Ver "21H2"
#>
function Invoke-WWConfigManagerUpdateSupersedence {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$prod,

        [Parameter(Mandatory = $true)]
        [string]$Ver
    )

    process {
        #set-ConfigMgrConnection
        Set-Location $CMDrive

        if (($prod -eq 'Windows 10') -and (
            ($ver -ge '1903') -or
            ($ver -eq '20H2') -or
            ($ver -eq '21H1') -or
            ($ver -eq '21H2')
        )) {
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10, version 1903 and later'"
        }
        if (($prod -eq 'Windows 10') -and ($ver -le '1809')) {
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows 10'"
        }
        if (($prod -eq 'Windows Server') -and ($ver = '1607')) {
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2016'"
        }
        if (($prod -eq 'Windows Server') -and ($ver -eq '1809')) {
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Windows Server 2019'"
        }
        if (($prod -eq 'Windows Server') -and ($ver -eq '21H2')) {
            $WMIQueryFilter = "LocalizedCategoryInstanceNames = 'Microsoft Server operating system-21H2'"
        }

        Write-WimWitchLog -data 'Checking files for supersedense...' -Class Information

        if ((Test-Path -Path "$Script:workdir\updates\$Prod\$ver\") -eq $False) {
            Write-WimWitchLog -Data 'Folder doesnt exist. Skipping supersedence check...' -Class Warning
            return
        }

        #For every folder under updates\prod\ver
        $FolderFirstLevels = Get-ChildItem -Path "$Script:workdir\updates\$Prod\$ver\"
        foreach ($FolderFirstLevel in $FolderFirstLevels) {

            #For every folder under updates\prod\ver\class
            $FolderSecondLevels = Get-ChildItem -Path "$Script:workdir\updates\$Prod\$ver\$FolderFirstLevel"
            foreach ($FolderSecondLevel in $FolderSecondLevels) {

                #for every cab under updates\prod\ver\class\update
                $UpdateCabs = (Get-ChildItem -Path (
                    "$Script:workdir\updates\$Prod\$ver\$FolderFirstLevel\$FolderSecondLevel"
                ))
                foreach ($UpdateCab in $UpdateCabs) {
                    Write-WimWitchLog -data "Checking update file name $UpdateCab" -Class Information
                    $UpdateItem = Get-CimInstance `
                        -Namespace "root\SMS\Site_$($Script:SiteCode)" `
                        -ClassName SMS_SoftwareUpdate `
                        -ComputerName $Script:SiteServer `
                        -Filter $WMIQueryFilter `
                        -ErrorAction Stop |
                        Where-Object { ($_.LocalizedDisplayName -eq $FolderSecondLevel) }

                    if ($UpdateItem.IsSuperseded -eq $false) {

                        Write-WimWitchLog -data "Update $FolderSecondLevel is current" -Class Information
                    } else {
                        Write-WimWitchLog -Data "Update $UpdateCab is superseded. Deleting file..." -Class Warning
                        Remove-Item -Path (
                            "$Script:workdir\updates\$Prod\$ver\$FolderFirstLevel\$FolderSecondLevel\$UpdateCab"
                        )
                    }
                }
            }
        }

        Write-WimWitchLog -Data 'Cleaning folders...' -Class Information
        $FolderFirstLevels = Get-ChildItem -Path "$Script:workdir\updates\$Prod\$ver\"
        foreach ($FolderFirstLevel in $FolderFirstLevels) {

            #For every folder under updates\prod\ver\class
            $FolderSecondLevels = Get-ChildItem -Path "$Script:workdir\updates\$Prod\$ver\$FolderFirstLevel"
            foreach ($FolderSecondLevel in $FolderSecondLevels) {

                #for every cab under updates\prod\ver\class\update
                $UpdateCabs = (Get-ChildItem -Path "$Script:workdir\updates\$Prod\$ver\$FolderFirstLevel\$FolderSecondLevel")

                if ($null -eq $UpdateCabs) {
                    Write-WimWitchLog -Data "$FolderSecondLevel is empty. Deleting...." -Class Warning
                    Remove-Item -Path "$Script:workdir\updates\$Prod\$ver\$FolderFirstLevel\$FolderSecondLevel"
                }
            }
        }

        Set-Location $Script:workdir
        Write-WimWitchLog -data 'Supersedence check complete' -class Information
    }
}




