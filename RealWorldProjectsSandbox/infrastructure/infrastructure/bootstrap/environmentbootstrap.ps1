param (
    [Parameter(Mandatory)]
    [ValidateSet("dev", "stg", "pef", "prd")]
    [string] $Environment,

    [Parameter(Mandatory)]
    [ValidateSet( "Australia East")]
    [string]$Location,

    [Parameter(Mandatory)]
    [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            }
            catch {
                $false
            }
        })]
    [string]$SubscriptionId,
    [string]$LocationAbbr = "eau",
    [string]$Product = "ng",
    [int]$SPCredentialExpiry = 100
)

$CoreInfraSubscriptionId = "d877ef00-ea85-4a82-816c-b437fb7b1ebc"
$RGShardFoundation = "prod-rg-foundation-shared"
$ResourceGroupName = "$Environment-rg-$Product-tf-bootstrap-$LocationAbbr"
$KeyVaultName = "$Environment-kv-$Product-tf-creds-$LocationAbbr"
$ClusterSpnClientAppName = "$Environment-spn-ng-aks-cluster"
$LogFile = "$PSScriptRoot/boostrap.log"
$Tags = ("team=cloudops", "domain=bootstrap", "lock=true")

function Write-Log {
    param ( [string] $Message)

    $Message | Tee-Object $LogFile -Append | Write-Host
    
}

az account set -s $SubscriptionId

if ($LASTEXITCODE -ne 0) {
    Write-Log "Subscription not yet loaded, please login and logout again..."
    exit -1
}


#create key vault
$RgExists = az group exists -n $ResourceGroupName

if ($RgExists -eq $false) {
    Write-Log "Creating resource group $ResourceGroupName at $Location..."
    az group create -l $Location -n $ResourceGroupName --tags $Tags
    az group lock create --lock-type CanNotDelete -n NODELETE -g $ResourceGroupName
    Write-Log "Creating resource group $ResourceGroupName at $Location...DONE"
}
else {
    Write-Log "$ResourceGroupName already exists, skip creation..."
}


$ExistingKeyVault = $(az keyvault list -g $ResourceGroupName -o json | ConvertFrom-Json | Where-Object { $_.name -ieq "$KeyVaultName" })

if ($null -eq $ExistingKeyVault) {
    Write-Log "Creating key vault $KeyVaultName in ResourceGrroup $ResourceGroupName..."
    az keyvault create -l $Location -n $KeyVaultName -g $ResourceGroupName --tags $Tags
    Write-Log "Creating key vault $KeyVaultName in ResourceGrroup $ResourceGroupName...DONE"
}
else {
    Write-Log "Key Vault $KeyVaultName already exists, skip creation..."
}

function CreateStorageAccountAndContainer {
    param (
        [string]$AccountPrefix
    )
    $StorageAccountSuffix = ([char[]]([char]'a'..[char]'z') + 0..9 | Sort-Object { get-random })[0..24] -join ''
    $StorageAccountPrefix = "$AccountPrefix$Environment"
    $StorageAccountName = $($StorageAccountPrefix + $StorageAccountSuffix).Substring(0, 24)
    $StateContainerName = "tfstate"

    $ExistingStorageAccount = $(az storage account list -g $ResourceGroupName -o json | ConvertFrom-Json | Where-Object { $_.name -imatch "$StorageAccountPrefix" })

    if ($null -eq $ExistingStorageAccount) {
        Write-Log "Creating storage account $StorageAccountName in ResourceGrroup $ResourceGroupName..."
        az storage account create -n $StorageAccountName -g $ResourceGroupName -l $Location --sku Standard_RAGRS --tags $Tags
        Write-Log "Creating storage account $StorageAccountName in ResourceGrroup $ResourceGroupName...DONE"
    }
    else {
        $StorageAccountName = $ExistingStorageAccount.name
        Write-Log "Storage account $StorageAccountName already exists, skip creation..."
    }

    $ExistingStateContainer = $(az storage container exists --auth-mode login --account-name $StorageAccountName -n $StateContainerName) | ConvertFrom-Json

    if ($ExistingStateContainer.exists -eq $false) {
        Write-Log "Creating container $StateContainerName in account $StorageAccountName in ResourceGrroup $ResourceGroupName..."
        az storage container create --auth-mode login -n $StateContainerName --account-name $StorageAccountName -g $ResourceGroupName
        Write-Log "Creating container $StateContainerName in account $StorageAccountName in ResourceGrroup $ResourceGroupName...DONE"
    }
    else {
        Write-Log "Container $StateContainerName in Storage account $StorageAccountName already exists, skip creation..."
    }
}

#create storage account for remote access
CreateStorageAccountAndContainer -AccountPrefix "tfstate"
CreateStorageAccountAndContainer -AccountPrefix "apptfstate"


#create SPN and assign permissions
Write-Log "Creating Cluster Service Principal: '$ClusterSpnClientAppName'"

$ClusterServicePrincipal = az ad sp create-for-rbac --name $ClusterSpnClientAppName --years $SPCredentialExpiry `
    --role contributor --scopes /subscriptions/$SubscriptionId /subscriptions/$CoreInfraSubscriptionId/resourceGroups/$RGShardFoundation | ConvertFrom-Json

Write-Log "Created Cluster Service Principal: appId '${$ClusterServicePrincipal.appId}'" | Tee-Object $LogFile

#assign reader role to spn
Write-Log "Grant Reader Permission to '$ClusterSpnClientAppName'"
$ClusterSpnAppId = $ClusterServicePrincipal.appId
$Result = az ad app permission add --id $ClusterSpnAppId --api 00000003-0000-0000-c000-000000000000 --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
Write-Log $Result
$Result = az ad app permission grant --id $ClusterSpnAppId --api 00000003-0000-0000-c000-000000000000
Write-Host $Result
Write-Log "Grant Reader Permission to '$ClusterSpnClientAppName'..DONE"

Write-Log "Adding spn details to key vault $KeyVaultName..."
az keyvault secret set --name "spn-aks-cluster-id" --vault-name $KeyVaultName --value $ClusterServicePrincipal.appId
az keyvault secret set --name "spn-aks-cluster-secret" --vault-name $KeyVaultName --value $ClusterServicePrincipal.password
Write-Log "Adding spn details to key vault $KeyVaultName...DONE"

