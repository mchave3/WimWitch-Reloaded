<#
.SYNOPSIS
    Parse a JSON file and populate the WPF fields with the data.

.DESCRIPTION
    This function is used to parse a JSON file and populate the WPF fields with the data.

.NOTES
    Name:        Convert-WWJSONToObject.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-27
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Convert-WWJSONToObject
#>
function Convert-WWJSONToObject {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Write-WimWitchLog -Data 'Attempting to parse JSON file...' -Class Information
            $autopilotinfo = Get-Content $WPFJSONTextBox.Text | ConvertFrom-Json
            Write-WimWitchLog -Data 'Successfully parsed JSON file' -Class Information
            $WPFZtdCorrelationId.Text = $autopilotinfo.ZtdCorrelationId
            $WPFCloudAssignedTenantDomain.Text = $autopilotinfo.CloudAssignedTenantDomain
            $WPFComment_File.text = $autopilotinfo.Comment_File

        } catch {
            $WPFZtdCorrelationId.Text = 'Bad file. Try Again.'
            $WPFCloudAssignedTenantDomain.Text = 'Bad file. Try Again.'
            $WPFComment_File.text = 'Bad file. Try Again.'
            Write-WimWitchLog -Data 'Failed to parse JSON file. Try another'
            return
        }
    }
}



