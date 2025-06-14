param (
    [Parameter(Mandatory)]
    [ValidateSet("dev", "stg", "pef", "prd")]
    [string] $Env
)

$Role_Definition = Get-Content ./lockManager.json | ConvertFrom-Json

if ($Env -ieq "dev") {
    $spn_app_id = "57e5d825-18ba-4248-a6fe-c891ea297787"
    $subscription_id = "75d2fa14-67cf-41aa-9717-875861f4f0d7"
}
elseif ($Env -ieq "stg") {
    $spn_app_id = "4e54acf3-b616-434e-8c41-4b0a2ecbcda4"
    $subscription_id = "7b12ad1c-8c8d-45b7-ba98-4a5ebcc14576"
}
if ($Env -ieq "global") {
    $spn_app_id = "57e5d825-18ba-4248-a6fe-c891ea297787"
    $subscription_id = "d877ef00-ea85-4a82-816c-b437fb7b1ebc"
}
elseif ($Env -ieq "prd") {
    $spn_app_id = "257d1da3-cd5f-48a8-b469-afc829520e06" 
    $subscription_id = "af9d6bfd-3529-48cf-90d9-13e51e420a66"
    # UPDATE LOCK Manager JSON TO INCLUDE SUB ID
}

az account set -s $subscription_id

if ($LASTEXITCODE -ne 0) {
    Write-Error "Subscription not yet loaded, please login and logout again..."
    exit -1
}


try {
    az role definition update --role-definition "@LockManager.json"
}
catch {
    Write-Host "Creating role [Lock Manager]..."
    az role definition create --role-definition "@LockManager.json"
    Write-Host "Creating role [Lock Manager]...[DONE]"
    Write-Host "Sleep for two minutes to get role created"
    Start-Sleep 120
}

Write-Host "Add Lock Manager Role to SPN..."
az role assignment create --assignee $spn_app_id  --role "Lock Manager" --scope "/subscriptions/$subscription_id"
Write-Host "Add Lock Manager Role to SPN...[DONE]"
