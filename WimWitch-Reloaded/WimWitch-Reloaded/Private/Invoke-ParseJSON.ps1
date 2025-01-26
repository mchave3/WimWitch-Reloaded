<#
.SYNOPSIS
.DESCRIPTION
    This function is used to parse a JSON file and populate the WPF fields with the data.
#>
function Invoke-ParseJSON {
    [CmdletBinding()]
    param(

    )

    process {
        try {
            Update-Log -Data 'Attempting to parse JSON file...' -Class Information
            $autopilotinfo = Get-Content $WPFJSONTextBox.Text | ConvertFrom-Json
            Update-Log -Data 'Successfully parsed JSON file' -Class Information
            $WPFZtdCorrelationId.Text = $autopilotinfo.ZtdCorrelationId
            $WPFCloudAssignedTenantDomain.Text = $autopilotinfo.CloudAssignedTenantDomain
            $WPFComment_File.text = $autopilotinfo.Comment_File
    
        } catch {
            $WPFZtdCorrelationId.Text = 'Bad file. Try Again.'
            $WPFCloudAssignedTenantDomain.Text = 'Bad file. Try Again.'
            $WPFComment_File.text = 'Bad file. Try Again.'
            Update-Log -Data 'Failed to parse JSON file. Try another'
            return
        }
    }
}
