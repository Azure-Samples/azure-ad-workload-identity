// Parameters
@description('Specifies the name of the Service Bus namespace.')
param namespaceName string

@description('Enabling this property creates a Premium Service Bus Namespace in regions supported availability zones.')
param zoneRedundant bool = true

@description('Specifies the name of Service Bus namespace SKU.')
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param skuName string = 'Premium'

@description('Specifies the messaging units for the Service Bus namespace. For Premium tier, capacity are 1,2 and 4.')
param capacity int = 1

@description('Specifies the name of the Service Bus queue.')
param queueName string = 'todoapi'

@description('Specifies the lock duration of the queue.')
param queueLockDuration string = 'PT5M'

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
  'OperationalLogs'
  'VNetAndIPFilteringLogs'
  'RuntimeAuditLogs'
  'ApplicationMetricsLogs'
]
var metricCategories = [
  'AllMetrics'
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
resource namespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: namespaceName
  location: location
  tags: tags
  sku: {
    name: skuName
    capacity: capacity
  }
  properties: {
    zoneRedundant: zoneRedundant
  }
}

resource queue 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = {
  parent: namespace
  name: queueName
  properties: {
    lockDuration: queueLockDuration
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: namespace
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource serviceBusNamespaceConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'NotificationService--ServiceBus--ConnectionString'
  properties: {
    value: listkeys(resourceId('Microsoft.ServiceBus/namespaces/authorizationRules', namespace.name, 'RootManageSharedAccessKey'), namespace.apiVersion).primaryConnectionString
  }
}

resource serviceBusNamespaceNameSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'NotificationService--ServiceBus--Namespace'
  properties: {
    value: namespace.name
  }
}

resource serviceBusQueueNameSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'NotificationService--ServiceBus--QueueName'
  properties: {
    value: queue.name
  }
}

resource serviceBusUseAzureCredentialSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'NotificationService--ServiceBus--UseAzureCredential'
  properties: {
    value: 'true'
  }
}

// Outputs
output namespaceId string = namespace.id
output queueId string = queue.id
