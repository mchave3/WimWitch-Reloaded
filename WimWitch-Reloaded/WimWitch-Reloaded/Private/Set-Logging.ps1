<#
.SYNOPSIS
    Initializes the required folder structure and logging for WIMWitch.
.DESCRIPTION
    This function creates and manages the essential folders and log file for WIMWitch operations:
    - Logging folder and WIMWitch.log file
    - Updates folder for storing Windows updates
    - Staging folder for temporary files
    - Mount folder for mounting WIM files
    - CompletedWIMs folder for output files
    - Configs folder for XML configurations
#>
function Set-Logging {
    [CmdletBinding()]
    param(

    )

    process {
        # Initialize or reset the log file
        if (!(Test-Path -Path "$global:workdir\logging\WIMWitch.Log" -PathType Leaf)) {
            New-Item -ItemType Directory -Force -Path "$global:workdir\Logging" | Out-Null
            New-Item -Path "$global:workdir\logging" -Name 'WIMWitch.log' -ItemType 'file' -Value '***Logging Started***' | Out-Null
        } Else {
            Remove-Item -Path "$global:workdir\logging\WIMWitch.log"
            New-Item -Path "$global:workdir\logging" -Name 'WIMWitch.log' -ItemType 'file' -Value '***Logging Started***' | Out-Null
        }

        # Create and verify required folders
        $requiredFolders = @(
            @{Path = "updates"; Description = "Updates"},
            @{Path = "Staging"; Description = "Staging"},
            @{Path = "Mount"; Description = "Mount"},
            @{Path = "CompletedWIMs"; Description = "CompletedWIMs"},
            @{Path = "Configs"; Description = "Configs"}
        )

        foreach ($folder in $requiredFolders) {
            $FileExist = Test-Path -Path "$global:workdir\$($folder.Path)"
            if (-not $FileExist) {
                Update-Log -Data "$($folder.Description) folder does not exist. Creating..." -Class Warning
                New-Item -ItemType Directory -Force -Path "$global:workdir\$($folder.Path)" | Out-Null
                Update-Log -Data "$($folder.Description) folder created" -Class Information
            } else {
                Update-Log -Data "$($folder.Description) folder exists" -Class Information
            }
        }
    }
}
