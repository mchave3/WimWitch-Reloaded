<#
.SYNOPSIS
    Select ConfigMgr distribution points.

.DESCRIPTION
    This function allows users to select ConfigMgr distribution points for image
    package distribution. It retrieves available distribution points from the
    ConfigMgr site and adds them to the selection list.

.NOTES
    Name:        Select-DistributionPoints.ps1
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
    Select-DistributionPoints
#>
function Select-DistributionPoints {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            $DPs = Get-CMDistributionPoint -SiteCode $global:SiteCode
            foreach ($DP in $DPs) {
                $WPFCMLBDPs.Items.Add($DP.NetworkOSPath)
            }
            Update-Log -Data 'Distribution points retrieved successfully' -Class Information
        }
        catch {
            Update-Log -Data 'Failed to retrieve distribution points' -Class Error
            Update-Log -Data $_.Exception.Message -Class Error
        }
    }
}
