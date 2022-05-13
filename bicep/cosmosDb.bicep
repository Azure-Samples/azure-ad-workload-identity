// Parameters
@description('Specifies the name of the Azure Cosmos Db account.')
param accountName string

@description('Indicates the type of database account. This can only be set at database account creation.')
@allowed([
  'GlobalDocumentDB'
  'MongoDB'
  'Parse'
])
param kind string = 'GlobalDocumentDB'

@description('Specifies whether the public network access is enabled or disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Indicates what services are allowed to bypass firewall checks.')
@allowed([
  'AzureServices'
  'None'
])
param networkAclBypass string = 'AzureServices'

@description('Specifies the name of the Azure Cosmos Db database.')
param databaseName string = 'TodoApiDb'

@description('Specifies the throughput of the Azure Cosmos DB database.')
param databaseThroughput int = 400

@description('Specifies the name of the Azure Cosmos Db container.')
param containerName string = 'TodoApiCollection'

@description('Specifies the partition key of the container.')
param containerPartitionKey string = '/id'

@description('indexingMode	Indicates the indexing mode.')
@allowed([
  'consistent'
  'lazy'
  'none'
])
param indexingMode string = 'consistent'

@description('Specifies the name of a Key Vault where to store secrets.')
param keyVaultName string

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the workspace data retention in days.')
param retentionInDays int = 60

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var logCategories = [
  'DataPlaneRequests'
  'MongoRequests'
  'QueryRuntimeStatistics'
  'PartitionKeyStatistics'
  'PartitionKeyRUConsumption'
  'ControlPlaneRequests'
  'CassandraRequests'
  'GremlinRequests'
  'TableApiRequests'
]
var metricCategories = [
  'Requests'
]
var logs = [for category in logCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var metrics = [for category in metricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]

// Resources
resource account 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' = {
  name: toLower(accountName)
  kind: kind
  location: location
  tags: tags
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    publicNetworkAccess: publicNetworkAccess
    networkAclBypass: networkAclBypass
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-02-15-preview' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: databaseThroughput
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-02-15-preview' = {
  parent: database
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          containerPartitionKey
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: indexingMode
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: account
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource containerNameSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'RepositoryService--CosmosDb--CollectionName'
  properties: {
    value: container.name
  }
}

resource catabaseNameSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'RepositoryService--CosmosDb--DatabaseName'
  properties: {
    value: database.name
  }
}

resource accountDocumentEndpointSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'RepositoryService--CosmosDb--EndpointUri'
  properties: {
    value: account.properties.documentEndpoint
  }
}

resource accountPrimaryMasterKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'RepositoryService--CosmosDb--PrimaryKey'
  properties: {
    value: listKeys(account.id, account.apiVersion).primaryMasterKey
  }
}

resource cosmosDbUseAzureCredentialSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'RepositoryService--CosmosDb--UseAzureCredential'
  properties: {
    value: 'true'
  }
}

// Outputs
output accountId string = account.id
output databaseId string = database.id
output containerId string = container.id
