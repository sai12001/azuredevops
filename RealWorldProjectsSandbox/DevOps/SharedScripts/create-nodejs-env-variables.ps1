param(
    [string][Parameter(Mandatory = $true)]$environment,
    [string][Parameter(Mandatory = $true)]$appName,
    [string][Parameter(Mandatory = $true)]$envFilePath,
    [string][Parameter(Mandatory = $true)]$configPath,
    [string][Parameter(Mandatory = $false)]$product = "ng",
    [string][Parameter(Mandatory = $false)]$locationAbbr= "eau"
)

$ErrorActionPreference = 'stop'

$readConfigFile = Get-Content "$configPath\$environment\solution.metadata.json" | ConvertFrom-Json

Write-Host "appName $appName"
$appsettings = $readConfigFile.applications  | Where-Object -FilterScript {$_.app_name -eq "$appName"} 

$plainTextSettings = $appsettings.plain_text_settings.psobject.properties.name

foreach($plainTextSetting in $plainTextSettings)
{
    Write-Host "creating plain settings into a file"

    $plainTextSetting + ' = "' + $appsettings.plain_text_settings.psobject.properties[$plainTextSetting].Value + '"' | Add-Content $envFilePath\.env
}

foreach ($secure_setting in $appsettings.secure_settings)
{
    $domain = $secure_setting.domain
    $secret_name = $secure_setting.secret_name
    $config_name = $secure_setting.config_name

    $keyvautlName = "$environment-" + "kv-" + "$product-" + "$domain-" + $locationAbbr

    Write-Host "creating secure settings into file"
    $secret = Get-AzKeyVaultSecret -VaultName $keyvautlName -Name $secret_name -AsPlainText

    $config_name + ' = "' + $secret + '"' | Add-Content $envFilePath\.env
}

