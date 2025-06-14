param(
    [string][Parameter(Mandatory = $true)]$environment,
    [string][Parameter(Mandatory = $true)]$scriptPath,
    [string][Parameter(Mandatory = $false)]$product = "ng",
    [string][Parameter(Mandatory = $false)]$appType = "fnapp",
    [string][Parameter(Mandatory = $false)]$locationAbbr= "eau"
)

$ErrorActionPreference = 'stop'

$serviceName = "$environment-apim-$product-infra-shared"
$resourceGroupName = "$environment-rg-$product-infra-shared-$locationAbbr"

Function printApiDetails($object, $type) {
    Write-Host "--------------------------------------------------------------------------------"
    Write-Host "--------------------------------------------------------------------------------"
    If ($type -eq "xml") {
        Write-Host $object
    }
    Elseif ($type -eq "json") {
        Write-Host (ConvertTo-Json $object -Depth 10)
    }
    Else {
        Write-Host "Unknown type for $object"
    }
    Write-Host "--------------------------------------------------------------------------------"
    Write-Host "--------------------------------------------------------------------------------"
}

$apiDefinition = Get-Content "$scriptPath\definition.json" | ForEach-Object { $ExecutionContext.InvokeCommand.ExpandString($_) } | ConvertFrom-Json

$context = New-AzApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

# Create or update API
$api = Get-AzApiManagementApi -Context $context -ApiId $apiDefinition.id -ErrorAction SilentlyContinue

$serviceAppName = "$environment-$appType-$product-$($apiDefinition.serviceSolution)-$($apiDefinition.serviceApp)-$locationAbbr"
$serviceUrl = "https://$serviceAppName.azurewebsites.net"
if ($null -eq $api) {
    Write-Host "[$($api.name)] Creating api..."
    printApiDetails $apiDefinition "json"
    New-AzApiManagementApi -Context $context -ApiId $apiDefinition.id -Name $apiDefinition.name -ServiceUrl $serviceUrl -ProductIds $apiDefinition.inProducts  -Path $apiDefinition.servicePath -Protocols $apiDefinition.protocols
}
else { 
    Write-Host "[$($api.name)] Updating api..."
    if ( ($apiDefinition.name -ine $api.Name) `
            -or ($apiDefinition.protocols -ine $api.Protocols)`
            -or ($apiDefinition.serviceUrl -ine $api.ServiceUrl) `
            -or ($apiDefinition.servicePath -ine $api.Path)) {
        Set-AzApiManagementApi -Context $context -ApiId $apiDefinition.id -Name $apiDefinition.name -ServiceUrl $serviceUrl -Protocols $apiDefinition.protocols -Path $apiDefinition.servicePath 
    }

    $apiDefinition.inProducts | ForEach-Object {
        Add-AzApiManagementApiToProduct -Context $context -ProductId $_ -ApiId $api.ApiId
    }

}
$apiPolicy = "$scriptPath\base.xml"

if (Test-Path $apiPolicy) {
    Write-Host "[$($api.name)] Updating policy from $apiPolicy ..."
    $policyContent = Get-Content $apiPolicy -Raw | ForEach-Object { $ExecutionContext.InvokeCommand.ExpandString($_) }
    printApiDetails $policyContent "xml"
    Set-AzApiManagementPolicy -Context $context -ApiId $apiDefinition.id -Policy $policyContent
}
Write-Host "[$($api.name)] Api Upsert Completed."

# Create or update operations
foreach ($operation in $apiDefinition.operations) {
    $op = Get-AzApiManagementOperation -Context $context -ApiId $apiDefinition.id -OperationId $operation.id -ErrorAction SilentlyContinue
    
    $tparam = Select-String "{([^}]+)}" -input $operation.urlTemplate -AllMatches |
    ForEach-Object { $_.matches } |
    ForEach-Object {
        $p = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
        $p.Name = $_.Groups[1].Value
        $p.Type = "string"
        return $p
    }

    $Request = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementRequest

    if ( $operation.parameters.Count -gt 0) {
        $QueryParameters = $operation.parameters | ForEach-Object {
            $queryParameter = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
            $queryParameter.Name = $_.name
            $queryParameter.Type = $_.type
            $queryParameter.Required = $FALSE
            return $queryParameter
        }

        Write-Host "Request.QueryParameters " $QueryParameters
        $Request.QueryParameters = @($QueryParameters)
    }

    $Response = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementResponse
    $Response.StatusCode = 200


    Try {
        if ($null -eq $op) {
            Write-Host "[$($operation.name)] Creating operation ... "
            New-AzApiManagementOperation -Context $context -ApiId $apiDefinition.id -OperationId $operation.id -Name $operation.name -Method $operation.method -UrlTemplate $operation.urlTemplate -TemplateParameters $tparam -Request $Request -Responses $Response
        }
        else {
            Write-Host "[$($operation.name)] Updating operation ..."
            Set-AzApiManagementOperation -Context $context -ApiId $apiDefinition.id -OperationId $operation.id -Name $operation.name -Method $operation.method -UrlTemplate $operation.urlTemplate -TemplateParameters $tparam -Request $Request -Responses $Response
        }

        $operationPolicy = "$scriptPath\$($operation.id).xml"
        if (Test-Path $operationPolicy) {
            Write-Host "[$($operation.name)] Updating policy from $operationPolicy ..."
            $policyContent = Get-Content $operationPolicy -Raw | ForEach-Object { $ExecutionContext.InvokeCommand.ExpandString($_) }
            printApiDetails $policyContent "xml"
            Set-AzApiManagementPolicy -Context $context -ApiId $apiDefinition.id -OperationId $operation.id -Policy $policyContent 
        }
        Write-Host "[$($operation.name)] Operation  Completed."
    }
    Catch {
        Write-Host $_.Exception.Error.OriginalMessage
        Write-Host $_.Exception.Body.Message
        ConvertTo-Json $_.Exception.Body.Details | Write-Host 
        Write-Host $policyContent
        throw $_.Exception
    }
}

Write-Host "Deployment Completed."
