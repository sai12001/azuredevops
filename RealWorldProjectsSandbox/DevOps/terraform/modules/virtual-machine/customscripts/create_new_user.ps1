
Param(
    [Parameter(Mandatory=$true)][string]$local_user_pwd
)

write-host 'Creating local user for external users to login'

$Password = "$local_user_pwd" | ConvertTo-SecureString -AsPlainText -Force


$user = Get-LocalUser | Where-Object {$_.Name -eq "localuser"}
if ( -not $user)
 {
    Write-Host 'Creating user'
    New-LocalUser "localuser" -Password $Password -FullName "local user" | Out-Null
    
    Write-Host 'Adding user to the Remote desktop Users group'
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member "localuser"
 }
 else {

    Write-Host 'Updating the passwor for local user'
    $user | Set-LocalUser -Password $Password
 }