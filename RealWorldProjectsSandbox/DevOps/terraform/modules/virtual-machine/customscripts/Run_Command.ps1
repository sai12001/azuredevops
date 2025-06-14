Param(
    [Parameter(Mandatory=$true)][string]$resourceGroupName,
    [Parameter(Mandatory=$true)][string]$vmName,
    [Parameter(Mandatory=$true)][string]$scriptPath,
    [Parameter(Mandatory=$true)][string]$local_user_pwd,
    [Parameter(Mandatory=$true)][string]$need_local_user
)

Write-Host "$scriptPath"

if($need_local_user -eq $true)
{

    Write-Host "$need_local_user Creating local user"
    az vm run-command invoke --command-id 'RunPowerShellScript' --name "$vmName" --resource-group "$resourceGroupName" --scripts @$scriptPath'/create_new_user.ps1' --parameters "local_user_pwd=$local_user_pwd"
}

az vm run-command invoke --command-id 'DisableNLA' -g "$resourceGroupName" -n "$vmName" 