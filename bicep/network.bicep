// Parameters
@description('Specifies the name of the virtual network.')
param virtualNetworkName string

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

@description('Specifies the name of the subnet hosting the worker nodes of the AKS cluster.')
param aksSubnetName string = 'AksSubnet'

@description('Specifies the address prefix of the subnet hosting the worker nodes of the AKS cluster.')
param aksSubnetAddressPrefix string = '10.0.0.0/16'

@description('Specifies the name of the subnet which contains the virtual machine.')
param vmSubnetName string = 'VmSubnet'

@description('Specifies the address prefix of the subnet which contains the virtual machine.')
param vmSubnetAddressPrefix string = '10.2.0.0/24'

@description('Specifies the name of the network security group associated to the subnet hosting the virtual machine.')
param vmSubnetNsgName string = 'VmSubnetNsg'

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param bastionSubnetAddressPrefix string = '10.2.1.0/24'

@description('Specifies the name of the network security group associated to the subnet hosting Azure Bastion.')
param bastionSubnetNsgName string = 'AzureBastionNsg'

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string

@description('Enable/Disable Copy/Paste feature of the Bastion Host resource.')
param bastionHostDisableCopyPaste bool = false

@description('Enable/Disable File Copy feature of the Bastion Host resource.')
param bastionHostEnableFileCopy bool = false

@description('Enable/Disable IP Connect feature of the Bastion Host resource.')
param bastionHostEnableIpConnect bool = false

@description('Enable/Disable Shareable Link of the Bastion Host resource.')
param bastionHostEnableShareableLink bool = false

@description('Enable/Disable Tunneling feature of the Bastion Host resource.')
param bastionHostEnableTunneling bool = false

@description('Specifies the name of the private endpoint to Cosmos DB.')
param cosmosDbPrivateEndpointName string = 'CosmosDbPrivateEndpoint'

@description('Specifies the resource id of the Azure Cosmos DB account.')
param cosmosDbAccountId string

@description('Specifies the name of the private link to the storage account.')
param serviceBusNamespacePrivateEndpointName string = 'ServiceBusNamespacePrivateEndpoint'

@description('Specifies the resource id of the Azure Service Bus namespace.')
param serviceBusNamespaceId string

@description('Specifies the name of the private link to the boot diagnostics storage account.')
param storageAccountPrivateEndpointName string = 'BlobStorageAccountPrivateEndpoint'

@description('Specifies the resource id of the Azure Storage Account.')
param storageAccountId string

@description('Specifies the name of the private link to the Key Vault.')
param keyVaultPrivateEndpointName string = 'KeyVaultPrivateEndpoint'

@description('Specifies the resource id of the Azure Key vault.')
param keyVaultId string

@description('Specifies whether to create a private endpoint for the Azure Container Registry')
param createAcrPrivateEndpoint bool = false

@description('Specifies the name of the private link to the Azure Container Registry.')
param acrPrivateEndpointName string = 'AcrPrivateEndpoint'

@description('Specifies the resource id of the Azure Container Registry.')
param acrId string

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
var nsgLogCategories = [
  'NetworkSecurityGroupEvent'
  'NetworkSecurityGroupRuleCounter'
]
var nsgLogs = [for category in nsgLogCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var vnetLogCategories = [
  'VMProtectionAlerts'
]
var vnetMetricCategories = [
  'AllMetrics'
]
var vnetLogs = [for category in vnetLogCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var vnetMetrics = [for category in vnetMetricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var bastionLogCategories = [
  'BastionAuditLogs'
]
var bastionMetricCategories = [
  'AllMetrics'
]
var bastionLogs = [for category in bastionLogCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var bastionMetrics = [for category in bastionMetricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var bastionSubnetName = 'AzureBastionSubnet'
var bastionPublicIpAddressName = '${bastionHostName}PublicIp'

// Resources

// Network Security Groups
resource bastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: bastionSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource vmSubnetNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: vmSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowSshInbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefixes
      ]
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: vmSubnetName
        properties: {
          addressPrefix: vmSubnetAddressPrefix
          networkSecurityGroup: {
            id: vmSubnetNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
          networkSecurityGroup: {
            id: bastionSubnetNsg.id
          }
        }
      }
    ]
  }
}

// Azure Bastion Host
resource bastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: bastionPublicIpAddressName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: bastionHostName
  location: location
  tags: tags
  properties: {
    disableCopyPaste: bastionHostDisableCopyPaste
    enableFileCopy: bastionHostEnableFileCopy
    enableIpConnect: bastionHostEnableIpConnect
    enableShareableLink: bastionHostEnableShareableLink
    enableTunneling: bastionHostEnableTunneling
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/${bastionSubnetName}'
          }
          publicIPAddress: {
            id: bastionPublicIpAddress.id
          }
        }
      }
    ]
  }
}


// Private DNS Zones
resource acrPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.${toLower(environment().name) == 'azureusgovernment' ? 'azurecr.us' : 'azurecr.io'}'
  location: 'global'
  tags: tags
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  tags: tags
}

resource cosmosDbPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name:  'privatelink.${toLower(environment().name) == 'azureusgovernment' ? 'documents.azure.us' : 'documents.azure.com'}'
  location: 'global'
  tags: tags
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.${toLower(environment().name) == 'azureusgovernment' ? 'vaultcore.usgovcloudapi.net' : 'vaultcore.azure.net'}'
  location: 'global'
  tags: tags
}

resource serviceBusPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.${toLower(environment().name) == 'azureusgovernment' ? 'servicebus.usgovcloudapi.net' : 'servicebus.windows.net'}'
  location: 'global'
  tags: tags
}

// Virtual Network Links
resource acrPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: acrPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource blobPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource cosmosDbPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: cosmosDbPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource keyVaultPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: keyVaultPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource serviceBusPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent:serviceBusPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

// Private Endpoints
resource cosmosDbPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: cosmosDbPrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: cosmosDbPrivateEndpointName
        properties: {
          privateLinkServiceId: cosmosDbAccountId
          groupIds: [
            'Sql'
          ]
        }
      }
    ]
    subnet: {
      id: '${vnet.id}/subnets/${vmSubnetName}'
    }
  }
}

resource cosmosDbPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  parent: cosmosDbPrivateEndpoint
  name: 'PrivateDnsZoneGroupName'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: cosmosDbPrivateDnsZone.id
        }
      }
    ]
  }
}

resource serviceBusNamespacePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: serviceBusNamespacePrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: serviceBusNamespacePrivateEndpointName
        properties: {
          privateLinkServiceId: serviceBusNamespaceId
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
    subnet: {
      id: '${vnet.id}/subnets/${vmSubnetName}'
    }
  }
}

resource serviceBusNamespacePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  parent: serviceBusNamespacePrivateEndpoint
  name: 'PrivateDnsZoneGroupName'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: serviceBusPrivateDnsZone.id
        }
      }
    ]
  }
}

resource blobStorageAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: storageAccountPrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: storageAccountPrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: '${vnet.id}/subnets/${vmSubnetName}'
    }
  }
}

resource blobStorageAccountPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  parent: blobStorageAccountPrivateEndpoint
  name: 'PrivateDnsZoneGroupName'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: keyVaultPrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateEndpointName
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: '${vnet.id}/subnets/${vmSubnetName}'
    }
  }
}

resource keyVaultPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  parent: keyVaultPrivateEndpoint
  name: 'PrivateDnsZoneGroupName'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
}

resource acrPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = if (createAcrPrivateEndpoint) {
  name: acrPrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: acrPrivateEndpointName
        properties: {
          privateLinkServiceId: acrId
          groupIds: [
            'registry'
          ]
        }
      }
    ]
    subnet: {
      id: '${vnet.id}/subnets/${vmSubnetName}'
    }
  }
}

resource acrPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = if (createAcrPrivateEndpoint) {
  parent: acrPrivateEndpoint
  name: 'acrPrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: acrPrivateDnsZone.id
        }
      }
    ]
  }
}

// Diagnostic Settings
resource vmSubnetNsgDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: vmSubnetNsg
  properties: {
    workspaceId: workspaceId
    logs: nsgLogs
  }
}

resource bastionSubnetNsgDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: bastionSubnetNsg
  properties: {
    workspaceId: workspaceId
    logs: nsgLogs
  }
}

resource vnetDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: vnet
  properties: {
    workspaceId: workspaceId
    logs: vnetLogs
    metrics: vnetMetrics
  }
}

resource bastionDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: bastionHost
  properties: {
    workspaceId: workspaceId
    logs: bastionLogs
    metrics: bastionMetrics
  }
}

// Outputs
output virtualNetworkId string = vnet.id
output virtualNetworkName string = vnet.name
output aksSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, aksSubnetName)
output vmSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, vmSubnetName)
output bastionSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, bastionSubnetName)
output aksSubnetName string = aksSubnetName
output vmSubnetName string = vmSubnetName
output bastionSubnetName string = bastionSubnetName
