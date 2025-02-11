<#
.SYNOPSIS
    Update the log file and write to the console.

.DESCRIPTION
    This function is used to update the log file and write to the console.

.NOTES
    Name:        Write-WimWitchLog.ps1
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
    Write-WimWitchLog -Data "This is a test log entry" # Default class is Information
    Write-WimWitchLog -Data "This is a test log entry" -Class "Warning"
    Write-WimWitchLog -Data "This is a test log entry" -Class "Error"
    Write-WimWitchLog -Data "This is a test log entry" -Class "Comment"
#>
function Write-WimWitchLog {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]$Data,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]$Solution = $Solution,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [validateset('Information', 'Warning', 'Error', 'Comment')]
        [string]$Class = 'Information'
    )

    process {
        $Log = "$Script:workdir\logging\WIMWitch.log"
        $LogString = "$(Get-Date) $Class  -  $Data"
        $HostString = "$(Get-Date) $Class  -  $Data"

        Add-Content -Path $Log -Value $LogString
        switch ($Class) {
            'Information' {
                Write-Host $HostString -ForegroundColor Gray
            }
            'Warning' {
                Write-Host $HostString -ForegroundColor Yellow
            }
            'Error' {
                Write-Host $HostString -ForegroundColor Red
            }
            'Comment' {
                Write-Host $HostString -ForegroundColor Green
            }

            Default { }
        }
    }
}


