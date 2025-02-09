<#
.SYNOPSIS
    Copy the updated OneDrive client x64 to the mounted image.

.DESCRIPTION
    This function is used to copy the updated OneDrive client x64 to the mounted image.
    It will also set the ACLs on the original OneDriveSetup.exe file to allow the copy to be successful.

.NOTES
    Name:        Copy-OneDrivex64.ps1
    Author:      Mickaël CHAVE
    Created:     2025-01-30
    Version:     1.0.0
    Repository:  https://github.com/mchave3/WimWitch-Reloaded
    License:     MIT License

    Based on original WIM-Witch by TheNotoriousDRR :
    https://github.com/thenotoriousdrr/WIM-Witch

.LINK
    https://github.com/mchave3/WimWitch-Reloaded

.EXAMPLE
    Copy-OneDrivex64
#>
function Copy-OneDrivex64 {
    [CmdletBinding()]
    param(

    )

    process {
        Write-WWLog -data 'Updating OneDrive x64 client' -class information
        try {
            Write-WWLog -Data 'Setting ACL on the original OneDriveSetup.exe file' -Class Information
            $mountpath = $WPFMISMountTextBox.text
            $AclBAK = Get-Acl "$mountpath\Windows\System32\OneDriveSetup.exe"
            $user = $env:USERDOMAIN + '\' + $env:USERNAME
            $Account = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList $user
            $item = Get-Item "$mountpath\Windows\System32\OneDriveSetup.exe"
            $Acl = $null # Reset the $Acl variable to $null
            $Acl = Get-Acl -Path $Item.FullName # Get the ACL from the item
            $Acl.SetOwner($Account) # Update the in-memory ACL
            Set-Acl -Path $Item.FullName -AclObject $Acl -ErrorAction Stop  # Set the updated ACL on the target item
            Write-WWLog -Data 'Ownership of OneDriveSetup.exe siezed' -Class Information
            $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($user, 'FullControl', 'Allow')
            $Acl.SetAccessRule($Ar)
            Set-Acl "$mountpath\Windows\System32\OneDriveSetup.exe" $Acl -ErrorAction Stop | Out-Null
            Write-WWLog -Data 'ACL successfully updated. Continuing...'
        } catch {
            Write-WWLog -data "Couldn't set the ACL on the original file" -Class Error
            return
        }
        try {
            Write-WWLog -data 'Copying updated OneDrive agent installer...' -Class Information
            Copy-Item "$Script:workdir\updates\OneDrive\x64\OneDriveSetup.exe" -Destination "$mountpath\Windows\System32" -Force -ErrorAction Stop
            Write-WWLog -Data 'OneDrive installer successfully copied.' -Class Information
        } catch {
            Write-WWLog -data "Couldn't copy the OneDrive installer file." -class Error
            Write-WWLog -data $_.Exception.Message -Class Error
            return
        }
        try {
            Write-WWLog -data 'Restoring original ACL to OneDrive installer.' -Class Information
            Set-Acl "$mountpath\Windows\System32\OneDriveSetup.exe" $AclBAK -ErrorAction Stop | Out-Null
            Write-WWLog -data 'Restoration complete' -Class Information
        } catch {
            Write-WWLog "Couldn't restore original ACLs. Continuing." -Class Error
        }
    }
}
