<#
.SYNOPSIS

.DESCRIPTION

.NOTES
    Name:        powershellVersion.ps1
    Author:      Mickaël CHAVE
    Created:     2025-02-27
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded
#>

$script:powershellVersion = if ($PSVersionTable.PSVersion.Major -ge 7) {
    "Core"
}
else {
    "Desktop"
}