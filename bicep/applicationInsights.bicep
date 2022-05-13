// Parameters
@description('Specifies the name of the Application Insights used by workload.')
param name string = 'TodoApplicationInsights'

@description('Specifies the name of a Key Vault where to store secrets.')
param keyVaultName string

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Resources
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  location: location
  tags: tags
  name: name
  kind: 'web'
  properties: {
    Application_Type: 'web'
    SamplingPercentage: 100
    DisableIpMasking: true
    WorkspaceResourceId: workspaceId
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource instrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'ApplicationInsights--InstrumentationKey'
  properties: {
    value: applicationInsights.properties.InstrumentationKey
  }
}

// Outputs
output id string = applicationInsights.id
output name string = applicationInsights.properties.Name
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
