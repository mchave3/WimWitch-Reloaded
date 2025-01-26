<#
.SYNOPSIS
.DESCRIPTION
    This function is used to update the log file and write to the console.
#>
function Update-Log {
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
        $global:ScriptLogFilePath = $Log
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
