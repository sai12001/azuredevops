param acrConfig object

param location string = resourceGroup().location

//Used by pipeline
#disable-next-line no-unused-params
param resourceGroupName string = ''

module containerRegistry '../../DevOps/modules/containerRegistry/deploy.bicep' = {
  name: 'deploy-acr-blackstream'
  params: {
    name: acrConfig.name
    acrSku: acrConfig.sku
    location: location
  }
}
