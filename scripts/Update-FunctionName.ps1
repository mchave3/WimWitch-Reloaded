<#
.SYNOPSIS
    Updates function names across the WimWitch-Reloaded project files based on a CSV mapping.

.DESCRIPTION
    This script updates function names throughout the WimWitch-Reloaded project by reading a CSV file containing old-to-new function name mappings.
    It processes all PowerShell and XAML files in the project, replacing function names in both file contents and filenames according to the mapping.

.NOTES
    Name:        Update-FunctionName.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-10
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Update-FunctionName.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$CsvPath = ".\function-mapping.csv"
)

Clear-Host

#region Functions
function Write-WWLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success', 'Stage')]
        [string]$Type = 'Info'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $prefix = switch ($Type) {
        'Info'    { "[INFO]   " }
        'Warning' { "[WARN]   " }
        'Error'   { "[ERROR]  " }
        'Success' { "[SUCCESS]" }
        'Stage'   { "[STAGE]  " }
    }

    $color = switch ($Type) {
        'Info'    { 'White' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Success' { 'Green' }
        'Stage'   { 'Cyan' }
    }

    Write-Host "[$timestamp] $prefix $Message" -ForegroundColor $color
}

function Update-ProjectFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Mappings
    )

    $projectRoot = Split-Path -Parent $PSScriptRoot
    $sourceDir = Join-Path $projectRoot "src"

    # Get all PowerShell and XAML files recursively
    $files = Get-ChildItem -Path $sourceDir -Recurse -File -Include "*.ps1", "*.psm1", "*.psd1", "*.xaml"
    $totalFiles = $files.Count
    $currentFile = 0

    #region Content Parser
    function Update-FunctionNameInContent {
        [CmdletBinding(SupportsShouldProcess)]
        param (
            [Parameter(Mandatory = $true)]
            [string]$Content,
            [Parameter(Mandatory = $true)]
            [string]$OldName,
            [Parameter(Mandatory = $true)]
            [string]$NewName
        )

        $modified = $Content
        $positions = @()

        # Parser state
        $inSingleQuoteString = $false
        $inDoubleQuoteString = $false
        $inComment = $false
        $inMultilineComment = $false
        $length = $Content.Length
        $i = 0

        while ($i -lt $length) {
            $char = $Content[$i]
            $nextChar = if ($i + 1 -lt $length) { $Content[$i + 1] } else { $null }

            # Comment handling
            if (-not ($inSingleQuoteString -or $inDoubleQuoteString)) {
                # Single line comment
                if ($char -eq '#' -and -not $inMultilineComment) {
                    $inComment = $true
                    $i++
                    while ($i -lt $length -and $Content[$i] -ne "`n") {
                        $i++
                    }
                    continue
                }
                # Multi-line comment start
                elseif ($char -eq '<' -and $nextChar -eq '#') {
                    $inMultilineComment = $true
                    $i += 2
                    continue
                }
                # Multi-line comment end
                elseif ($inMultilineComment -and $char -eq '#' -and $nextChar -eq '>') {
                    $inMultilineComment = $false
                    $i += 2
                    continue
                }
            }

            # String handling
            if ($char -eq '"' -and -not $inSingleQuoteString -and -not $inMultilineComment) {
                $inDoubleQuoteString = -not $inDoubleQuoteString
            }
            elseif ($char -eq "'" -and -not $inDoubleQuoteString -and -not $inMultilineComment) {
                $inSingleQuoteString = -not $inSingleQuoteString
            }

            # Process code outside comments and strings
            if (-not ($inComment -or $inMultilineComment -or $inSingleQuoteString -or $inDoubleQuoteString)) {
                # Check for function name match
                if ($i + $OldName.Length -le $length) {
                    $potentialMatch = $Content.Substring($i, $OldName.Length)
                    if ($potentialMatch -eq $OldName) {
                        # Verify isolated function name
                        $prevChar = if ($i -gt 0) { $Content[$i - 1] } else { ' ' }
                        $nextCharAfterName = if ($i + $OldName.Length -lt $length) {
                            $Content[$i + $OldName.Length]
                        } else { ' ' }

                        # Ensure it's a complete word and not part of a variable
                        if (-not [char]::IsLetterOrDigit($prevChar) -and
                            -not ($prevChar -eq '_') -and
                            -not [char]::IsLetterOrDigit($nextCharAfterName) -and
                            -not ($nextCharAfterName -eq '_') -and
                            -not ($prevChar -eq '$')) {
                            $positions += @{
                                Start = $i
                                Length = $OldName.Length
                            }
                        }
                    }
                }
            }

            # Reset single-line comment state on newline
            if ($char -eq "`n") {
                $inComment = $false
            }

            $i++
        }

        # Apply replacements from end to start to preserve indexes
        [array]::Reverse($positions)
        if ($positions.Count -gt 0 -and $PSCmdlet.ShouldProcess($OldName, "Replace with $NewName")) {
            foreach ($pos in $positions) {
                $modified = $modified.Remove($pos.Start, $pos.Length).Insert($pos.Start, $NewName)
            }
        }

        return $modified
    }
    #endregion Content Parser

    #region File Processing
    foreach ($file in $files) {
        $currentFile++
        Write-Progress -Activity "Processing files" -Status "Processing: $($file.Name)" -PercentComplete (($currentFile / $totalFiles) * 100)

        $originalName = $file.Name
        $newName = $originalName
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $contentChanged = $false
        $nameChanged = $false

        foreach ($old in $Mappings.Keys) {
            $new = $Mappings[$old]

            # Process content with custom parser
            $newContent = Update-FunctionNameInContent -Content $content -OldName $old -NewName $new
            if ($newContent -ne $content) {
                $content = $newContent
                $contentChanged = $true
            }

            # Process filename
            if ($newName -like "*$old*") {
                $newName = $newName.Replace($old, $new)
                $nameChanged = $true
            }
        }

        # Apply changes if needed
        if ($contentChanged) {
            if ($PSCmdlet.ShouldProcess($file.FullName, "Update file content")) {
                Write-WWLog -Message "Updating content in: $($file.FullName)" -Type 'Info'
                Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -Force
            }
        }

        if ($nameChanged) {
            $newPath = Join-Path $file.Directory.FullName $newName
            if ($PSCmdlet.ShouldProcess($originalName, "Rename to $newName")) {
                Write-WWLog -Message "Renaming: $originalName -> $newName" -Type 'Info'
                Move-Item -Path $file.FullName -Destination $newPath -Force
            }
        }
    }
    Write-Progress -Activity "Processing files" -Status "Completed" -Completed
    #endregion File Processing
}
#endregion Functions

#region Main Execution
try {
    Write-WWLog -Message "Starting function name update process" -Type 'Stage'

    # Validate and read CSV file
    if (-not (Test-Path $CsvPath)) {
        throw "CSV file not found: $CsvPath"
    }

    $mappings = @{}
    $csvContent = Import-Csv $CsvPath -Header 'OldName','NewName'

    # Validate CSV content
    $invalidRows = $csvContent | Where-Object {
        [string]::IsNullOrWhiteSpace($_.OldName) -or
        [string]::IsNullOrWhiteSpace($_.NewName)
    }

    if ($invalidRows) {
        throw "Invalid CSV content detected. All rows must have both OldName and NewName values."
    }

    $csvContent | ForEach-Object {
        $mappings[$_.OldName] = $_.NewName
    }

    if ($mappings.Count -eq 0) {
        throw "No valid mappings found in CSV file"
    }

    Write-WWLog -Message "Loaded $($mappings.Count) name mappings" -Type 'Info'

    # Process all files
    Update-ProjectFile -Mappings $mappings

    Write-WWLog -Message "Function name update completed successfully" -Type 'Success'
}
catch {
    Write-WWLog -Message "Error: $_" -Type 'Error'
    Write-WWLog -Message "Stack trace: $($_.ScriptStackTrace)" -Type 'Error'
    exit 1
}
#endregion Main Execution