@description('Specifies the location of AKS cluster.')
param location string = resourceGroup().location

@description('Specifies the name of the AKS cluster.')
param aksClusterName string = 'aks-${uniqueString(resourceGroup().id)}'

@description('Specifies the DNS prefix specified when creating the managed cluster.')
param aksClusterDnsPrefix string = aksClusterName

@description('Specifies the tags of the AKS cluster.')
param aksClusterTags object = {
  resourceType: 'AKS Cluster'
  createdBy: 'ARM Template'
}

@description('Specifies the network plugin used for building Kubernetes network. - azure or kubenet.')
@allowed([
  'azure'
  'kubenet'
])
param aksClusterNetworkPlugin string = 'azure'

@description('Specifies the network policy used for building Kubernetes network. - calico or azure')
@allowed([
  'azure'
  'calico'
])
param aksClusterNetworkPolicy string = 'azure'

@description('Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param aksClusterPodCidr string = '10.244.0.0/16'

@description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param aksClusterServiceCidr string = '172.16.0.0/16'

@description('Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param aksClusterDnsServiceIP string = '172.16.0.10'

@description('Specifies the CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range.')
param aksClusterDockerBridgeCidr string = '172.17.0.1/16'

@description('Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
@allowed([
  'basic'
  'standard'
])
param aksClusterLoadBalancerSku string = 'standard'

@description('Specifies outbound (egress) routing method. - loadBalancer or userDefinedRouting.')
@allowed([
  'loadBalancer'
  'userDefinedRouting'
])
param aksClusterOutboundType string = 'loadBalancer'

@description('Specifies the tier of a managed cluster SKU: Paid or Free')
@allowed([
  'Paid'
  'Free'
])
param aksClusterSkuTier string = 'Paid'

@description('Specifies the version of Kubernetes specified when creating the managed cluster.')
param aksClusterKubernetesVersion string = '1.18.8'

@description('Specifies the administrator username of Linux virtual machines.')
param aksClusterAdminUsername string = 'azureuser'

@description('Specifies the SSH RSA public key string for the Linux nodes.')
param aksClusterSshPublicKey string

@description('Specifies the tenant id of the Azure Active Directory used by the AKS cluster for authentication.')
param aadProfileTenantId string = subscription().tenantId

@description('Specifies the AAD group object IDs that will have admin role of the cluster.')
param aadProfileAdminGroupObjectIDs array = []

@description('Specifies the upgrade channel for auto upgrade. Allowed values include rapid, stable, patch, node-image, none.')
@allowed([
  'rapid'
  'stable'
  'patch'
  'node-image'
  'none'
])
param aksUpgradeChannel string = 'stable'

@description('Specifies whether to create the cluster as a private cluster or not.')
param aksClusterEnablePrivateCluster bool = true

@description('Specifies the Private DNS Zone mode for private cluster. When the value is equal to None, a Public DNS Zone is used in place of a Private DNS Zone')
param aksPrivateDNSZone string = 'none'

@description('Specifies whether to create additional public FQDN for private cluster or not.')
param aksEnablePrivateClusterPublicFQDN bool = true

@description('Specifies whether to enable managed AAD integration.')
param aadProfileManaged bool = true

@description('Specifies whether to  to enable Azure RBAC for Kubernetes authorization.')
param aadProfileEnableAzureRBAC bool = true

@description('Specifies the unique name of of the system node pool profile in the context of the subscription and resource group.')
param systemNodePoolName string = 'nodepool1'

@description('Specifies the vm size of nodes in the system node pool.')
param systemNodePoolVmSize string = 'Standard_DS5_v2'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified.')
param systemNodePoolOsDiskSizeGB int = 100

@description('Specifies the OS disk type to be used for machines in a given agent pool. Allowed values are \'Ephemeral\' and \'Managed\'. If unspecified, defaults to \'Ephemeral\' when the VM supports ephemeral OS and has a cache disk larger than the requested OSDiskSizeGB. Otherwise, defaults to \'Managed\'. May not be changed after creation. - Managed or Ephemeral')
@allowed([
  'Ephemeral'
  'Managed'
])
param systemNodePoolOsDiskType string = 'Ephemeral'

@description('Specifies the number of agents (VMs) to host docker containers in the system node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param systemNodePoolAgentCount int = 3

@description('Specifies the OS type for the vms in the system node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param systemNodePoolOsType string = 'Linux'

@description('Specifies the maximum number of pods that can run on a node in the system node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param systemNodePoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the system node pool.')
param systemNodePoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the system node pool.')
param systemNodePoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the system node pool.')
param systemNodePoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority in the system node pool: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param systemNodePoolScaleSetPriority string = 'Regular'

@description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
@allowed([
  'Delete'
  'Deallocate'
])
param systemNodePoolScaleSetEvictionPolicy string = 'Delete'

@description('Specifies the Agent pool node labels to be persisted across all nodes in the system node pool.')
param systemNodePoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. - string')
param systemNodePoolNodeTaints array = []

@description('Specifies the type for the system node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param systemNodePoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for the agent nodes in the system node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
param systemNodePoolAvailabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Specifies the unique name of of the user node pool profile in the context of the subscription and resource group.')
param userNodePoolName string = 'nodepool1'

@description('Specifies the vm size of nodes in the user node pool.')
param userNodePoolVmSize string = 'Standard_DS5_v2'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..')
param userNodePoolOsDiskSizeGB int = 100

@description('Specifies the OS disk type to be used for machines in a given agent pool. Allowed values are \'Ephemeral\' and \'Managed\'. If unspecified, defaults to \'Ephemeral\' when the VM supports ephemeral OS and has a cache disk larger than the requested OSDiskSizeGB. Otherwise, defaults to \'Managed\'. May not be changed after creation. - Managed or Ephemeral')
@allowed([
  'Ephemeral'
  'Managed'
])
param userNodePoolOsDiskType string = 'Ephemeral'

@description('Specifies the number of agents (VMs) to host docker containers in the user node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param userNodePoolAgentCount int = 3

@description('Specifies the OS type for the vms in the user node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param userNodePoolOsType string = 'Linux'

@description('Specifies the maximum number of pods that can run on a node in the user node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param userNodePoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the user node pool.')
param userNodePoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the user node pool.')
param userNodePoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the user node pool.')
param userNodePoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority in the user node pool: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param userNodePoolScaleSetPriority string = 'Regular'

@description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
@allowed([
  'Delete'
  'Deallocate'
])
param userNodePoolScaleSetEvictionPolicy string = 'Delete'

@description('Specifies the Agent pool node labels to be persisted across all nodes in the user node pool.')
param userNodePoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. - string')
param userNodePoolNodeTaints array = []

@description('Specifies the type for the user node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param userNodePoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for the agent nodes in the user node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
param userNodePoolAvailabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Specifies whether the httpApplicationRouting add-on is enabled or not.')
param httpApplicationRoutingEnabled bool = false

@description('Specifies whether the aciConnectorLinux add-on is enabled or not.')
param aciConnectorLinuxEnabled bool = false

@description('Specifies whether the azurepolicy add-on is enabled or not.')
param azurePolicyEnabled bool = true

@description('Specifies whether the kubeDashboard add-on is enabled or not.')
param kubeDashboardEnabled bool = false

@description('Specifies whether the pod identity addon is enabled..')
param podIdentityProfileEnabled bool = false

@description('Specifies whether the OIDC issuer is enabled.')
param oidcIssuerProfileEnabled bool = true

@description('Specifies the scan interval of the auto-scaler of the AKS cluster.')
param autoScalerProfileScanInterval string = '10s'

@description('Specifies the scale down delay after add of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterAdd string = '10m'

@description('Specifies the scale down delay after delete of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterDelete string = '20s'

@description('Specifies scale down delay after failure of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterFailure string = '3m'

@description('Specifies the scale down unneeded time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnneededTime string = '10m'

@description('Specifies the scale down unready time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnreadyTime string = '20m'

@description('Specifies the utilization threshold of the auto-scaler of the AKS cluster.')
param autoScalerProfileUtilizationThreshold string = '0.5'

@description('Specifies the max graceful termination time interval in seconds for the auto-scaler of the AKS cluster.')
param autoScalerProfileMaxGracefulTerminationSec string = '600'

@description('Specifies the name of the virtual network.')
param virtualNetworkName string = '${aksClusterName}Vnet'

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

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param bastionSubnetAddressPrefix string = '10.2.1.0/24'

@description('Specifies the name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string = '${aksClusterName}Workspace'

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param logAnalyticsSku string = 'PerNode'

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
param logAnalyticsRetentionInDays int = 60

@description('Specifies the name of the virtual machine.')
param vmName string = 'TestVm'

@description('Specifies the size of the virtual machine.')
param vmSize string = 'Standard_DS3_v2'

@description('Specifies the image publisher of the disk image used to create the virtual machine.')
param imagePublisher string = 'Canonical'

@description('Specifies the offer of the platform image or marketplace image used to create the virtual machine.')
param imageOffer string = 'UbuntuServer'

@description('Specifies the Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
param imageSku string = '18.04-LTS'

@description('Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('Specifies the name of the administrator account of the virtual machine.')
param vmAdminUsername string

@description('Specifies the SSH Key or password for the virtual machine. SSH key is recommended.')
@secure()
param vmAdminPasswordOrKey string

@description('Specifies the storage account type for OS and data disk.')
@allowed([
  'Premium_LRS'
  'StandardSSD_LRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param diskStorageAccounType string = 'Premium_LRS'

@description('Specifies the number of data disks of the virtual machine.')
@minValue(0)
@maxValue(64)
param numDataDisks int = 1

@description('Specifies the size in GB of the OS disk of the VM.')
param osDiskSize int = 50

@description('Specifies the size in GB of the OS disk of the virtual machine.')
param dataDiskSize int = 50

@description('Specifies the caching requirements for the data disks.')
param dataDiskCaching string = 'ReadWrite'

@description('Specifies the globally unique name for the storage account used to store the boot diagnostics logs of the virtual machine.')
param blobStorageAccountName string = 'boot${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the private link to the boot diagnostics storage account.')
param blobStorageAccountPrivateEndpointName string = 'BlobStorageAccountPrivateEndpoint'

@description('Specifies the name of the private link to the Azure Container Registry.')
param acrPrivateEndpointName string = 'AcrPrivateEndpoint'

@description('Name of your Azure Container Registry')
@minLength(5)
@maxLength(50)
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Tier of your Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string = '${aksClusterName}Bastion'

@description('Specifies the name of the private link to the Key Vault.')
param keyVaultPrivateEndpointName string = 'KeyVaultPrivateEndpoint'

@description('Specifies the name of the Key Vault resource.')
param keyVaultName string = 'keyvault-${uniqueString(resourceGroup().id)}'

@description('The default action of allow or deny when no other rules match. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param keyVaultNetworkRuleSetDefaultAction string = 'Allow'

@description('Specifies whether the Azure Key Vault resource is enabled for deployments.')
param keyVaultEnabledForDeployment bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for disk encryption.')
param keyVaultEnabledForDiskEncryption bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for template deployment.')
param keyVaultEnabledForTemplateDeployment bool = true

@description('Specifies whether the soft deelete is enabled for this Azure Key Vault resource.')
param keyVaultEnableSoftDelete bool = true

@description('Specifies the object ID ofthe service principals to configure in Key Vault access policies.')
param keyVaultObjectIds array = []

@description('Specifies the name of the built-in role to assign to the virtual machine system managed identity.')
param roleDefinitionName string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Specifies the relative path of the scripts used to initialize the virtual machine.')
param scriptFilePath string = 'https://raw.githubusercontent.com/paolosalvatori/azure-ad-workload-identity/master/templates/'

@description('Specifies the script to download from the URI specified by the scriptFilePath parameter.')
param scriptFileName string = 'install-azure-devops-self-hosted-agent.sh'

@description('Specifies the url of the Azure DevOps organization: https://dev.azure.com/organization.')
param azureDevOpsUrl string

@description('Specifies the personal access token of the Azure DevOps organization.')
param azureDevOpsPat string

@description('Specifies the name of the Azure DevOps agent pool.')
param azureDevOpsPool string

@description('Specifies the name of the Azure Cosmos Db account.')
param cosmosDbAccountName string = toLower('${aksClusterName}todoapi')

@description('Specifies whether the public network access is enabled or disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param cosmosDbAccountPublicNetworkAccess string = 'Enabled'

@description('Indicates what services are allowed to bypass firewall checks.')
@allowed([
  'AzureServices'
  'None'
])
param cosmosDbAccountNetworkAclBypass string = 'AzureServices'

@description('Specifies the name of the Azure Cosmos Db database.')
param cosmosDbDatabaseName string = 'TodoApiDb'

@description('Specifies the name of the Azure Cosmos Db container.')
param cosmosDbContainerName string = 'TodoApiCollection'

@description('Specifies the name of the private endpoint to Cosmos DB.')
param cosmosDbPrivateEndpointName string = 'CosmosDbPrivateEndpoint'

@description('Specifies the name of the Service Bus namespace.')
param serviceBusNamespaceName string = '${aksClusterName}ServiceBus'

@description('Enabling this property creates a Premium Service Bus Namespace in regions supported availability zones.')
param serviceBusNamespaceZoneRedundant bool = true

@description('Specifies the messaging units for the Service Bus namespace. For Premium tier, capacity are 1,2 and 4.')
param serviceBusNamespaceCapacity int = 1

@description('Specifies the name of the Service Bus queue used by the Azure Functions app.')
param serviceBusQueueName string = 'todoapi'

@description('Specifies the name of the private link to the storage account.')
param serviceBusNamespacePrivateEndpointName string = 'ServiceBusNamespacePrivateEndpoint'

@description('Specifies the name of the Application Insights used by workload.')
param applicationInsightsName string = 'TodoApplicationInsights'

var acrPullRoleDefinitionName = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
var aksClusterUserDefinedManagedIdentityName_var = '${aksClusterName}Identity'
var aksClusterUserDefinedManagedIdentityId = aksClusterUserDefinedManagedIdentityName.id
var vmSubnetNsgName_var = '${vmSubnetName}Nsg'
var vmSubnetNsgId = vmSubnetNsgName.id
var bastionSubnetNsgName_var = '${bastionHostName}Nsg'
var bastionSubnetNsgId = bastionSubnetNsgName.id
var virtualNetworkId = virtualNetworkName_resource.id
var aksSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, aksSubnetName)
var vmSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, vmSubnetName)
var vmNicName_var = '${vmName}Nic'
var vmNicId = vmNicName.id
var blobStorageAccountId = blobStorageAccountName_resource.id
var blobPublicDNSZoneForwarder = 'blob.${environment().suffixes.storage}'
var blobPrivateDnsZoneName_var = 'privatelink.${blobPublicDNSZoneForwarder}'
var blobPrivateDnsZoneId = blobPrivateDnsZoneName.id
var blobStorageAccountPrivateEndpointGroupName = 'blob'
var blobPrivateDnsZoneGroupName = '${blobStorageAccountPrivateEndpointGroupName}PrivateDnsZoneGroup'
var blobStorageAccountPrivateEndpointId = blobStorageAccountPrivateEndpointName_resource.id
var vmId = vmName_resource.id
var scriptFileUri = '${scriptFilePath}/${scriptFileName}'
var customScriptExtensionName = 'CustomScript'
var omsAgentForLinuxName = 'LogAnalytics'
var customScriptId = vmName_customScriptExtensionName.id
var omsAgentForLinuxId = vmName_omsAgentForLinuxName.id
var omsDependencyAgentForLinuxName = 'DependencyAgent'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${vmAdminUsername}/.ssh/authorized_keys'
        keyData: vmAdminPasswordOrKey
      }
    ]
  }
  provisionVMAgent: true
}
var bastionPublicIpAddressName_var = '${bastionHostName}PublicIp'
var bastionPublicIpAddressId = bastionPublicIpAddressName.id
var bastionSubnetName = 'AzureBastionSubnet'
var bastionSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, bastionSubnetName)
var workspaceId = logAnalyticsWorkspaceName_resource.id
var contributorRoleId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleDefinitionName}'
var contributorRoleAssignmentName_var = guid('${resourceGroup().id}${aksClusterUserDefinedManagedIdentityName_var}${aksClusterName}')
var contributorRoleAssignmentId = contributorRoleAssignmentName.id
var acrPullRoleId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${acrPullRoleDefinitionName}'
var acrPullRoleAssignmentName_var = guid('${resourceGroup().id}acrPullRoleAssignment')
var containerInsightsSolutionName_var = 'ContainerInsights(${logAnalyticsWorkspaceName})'
var acrPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? 'azurecr.us' : 'azurecr.io')
var acrPrivateDnsZoneName_var = 'privatelink.${acrPublicDNSZoneForwarder}'
var acrPrivateDnsZoneId = acrPrivateDnsZoneName.id
var acrPrivateEndpointGroupName = 'registry'
var acrPrivateDnsZoneGroupName = '${acrPrivateEndpointGroupName}PrivateDnsZoneGroup'
var acrPrivateEndpointId = acrPrivateEndpointName_resource.id
var acrId = acrName_resource.id
var aksClusterId = aksClusterName_resource.id
var keyVaultPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? '.vaultcore.usgovcloudapi.net' : '.vaultcore.azure.net')
var keyVaultPrivateDnsZoneName_var = 'privatelink${keyVaultPublicDNSZoneForwarder}'
var keyVaultPrivateDnsZoneId = keyVaultPrivateDnsZoneName.id
var keyVaultPrivateEndpointId = keyVaultPrivateEndpointName_resource.id
var keyVaultPrivateEndpointGroupName = 'vault'
var keyVaultPrivateDnsZoneGroupName = '${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup'
var keyVaultPrivateDnsZoneGroupId = resourceId('Microsoft.Network/privateEndpoints/privateDnsZoneGroups', keyVaultPrivateEndpointName, '${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup')
var keyVaultId = keyVaultName_resource.id
var cosmosDbDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? '.documents.azure.us' : '.documents.azure.com')
var cosmosDbPrivateDnsZoneName_var = 'privatelink${cosmosDbDNSZoneForwarder}'
var cosmosDbPrivateDnsZoneId = cosmosDbPrivateDnsZoneName.id
var cosmosDbPrivateEndpointId = cosmosDbPrivateEndpointName_resource.id
var cosmosDbDatabaseName_var = '${toLower(cosmosDbAccountName)}/${cosmosDbDatabaseName}'
var cosmosDbDatabaseContainerName_var = '${toLower(cosmosDbAccountName)}/${cosmosDbDatabaseName}/${cosmosDbContainerName}'
var cosmosDbAccountId = cosmosDbAccountName_resource.id
var cosmosDbDatabaseId = resourceId('Microsoft.DocumentDB/databaseAccounts/sqlDatabases', toLower(cosmosDbAccountName), cosmosDbDatabaseName)
var serviceBusPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? '.servicebus.usgovcloudapi.net' : '.servicebus.windows.net')
var serviceBusNamespacePrivateDnsZoneName_var = 'privatelink${serviceBusPublicDNSZoneForwarder}'
var serviceBusNamespacePrivateDnsZoneId = serviceBusNamespacePrivateDnsZoneName.id
var serviceBusNamespacePrivateEndpointId = serviceBusNamespacePrivateEndpointName_resource.id
var serviceBusNamespaceId = serviceBusNamespaceName_resource.id
var serviceBusNamespaceDefaultSASKeyName = 'RootManageSharedAccessKey'
var serviceBusNamespaceAuthRuleResourceId = resourceId('Microsoft.ServiceBus/namespaces/authorizationRules', serviceBusNamespaceName, serviceBusNamespaceDefaultSASKeyName)
var applicationInsightsId = applicationInsightsName_resource.id

resource applicationInsightsName_resource 'Microsoft.Insights/components@2020-02-02' = {
  location: location
  name: applicationInsightsName
  kind: 'web'
  properties: {
    Application_Type: 'web'
    SamplingPercentage: 100
    DisableIpMasking: true
    WorkspaceResourceId: workspaceId
  }
  dependsOn: [
    workspaceId
  ]
}

resource cosmosDbAccountName_resource 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  name: toLower(cosmosDbAccountName)
  kind: 'GlobalDocumentDB'
  location: location
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
    publicNetworkAccess: cosmosDbAccountPublicNetworkAccess
    networkAclBypass: cosmosDbAccountNetworkAclBypass
  }
}

resource cosmosDbDatabaseName_resource 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-10-15' = {
  name: cosmosDbDatabaseName_var
  properties: {
    resource: {
      id: cosmosDbDatabaseName
    }
    options: {}
  }
  dependsOn: [
    cosmosDbAccountId
  ]
}

resource cosmosDbDatabaseContainerName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-10-15' = {
  name: cosmosDbDatabaseContainerName_var
  properties: {
    resource: {
      id: cosmosDbContainerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
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
    options: {
      throughput: 400
    }
  }
  dependsOn: [
    cosmosDbAccountId
    cosmosDbDatabaseId
  ]
}

resource serviceBusNamespaceName_resource 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: serviceBusNamespaceCapacity
  }
  properties: {
    zoneRedundant: serviceBusNamespaceZoneRedundant
  }
}

resource serviceBusNamespaceName_serviceBusQueueName 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = {
  parent: serviceBusNamespaceName_resource
  name: serviceBusQueueName
  properties: {
    lockDuration: 'PT5M'
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
  dependsOn: [
    serviceBusNamespaceId
  ]
}

resource bastionPublicIpAddressName 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: bastionPublicIpAddressName_var
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionSubnetNsgName 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: bastionSubnetNsgName_var
  location: location
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

resource bastionSubnetNsgName_Microsoft_Insights_default 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${bastionSubnetNsgName_var}/Microsoft.Insights/default'
  location: location
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
  dependsOn: [
    bastionSubnetNsgId
    workspaceId
  ]
}

resource bastionHostName_resource 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: bastionPublicIpAddressId
          }
        }
      }
    ]
  }
  dependsOn: [
    bastionPublicIpAddressId
    virtualNetworkId
  ]
}

resource blobStorageAccountName_resource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: blobStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource blobStorageAccountName_default_todoapi 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${blobStorageAccountName}/default/todoapi'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    blobStorageAccountId
  ]
}

resource blobStorageAccountName_default_todoweb 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${blobStorageAccountName}/default/todoweb'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    blobStorageAccountId
  ]
}

resource vmNicName 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: vmNicName_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vmSubnetId
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetworkId
  ]
}

resource vmName_resource 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: osDiskSize
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }
      dataDisks: [for j in range(0, numDataDisks): {
        caching: dataDiskCaching
        diskSizeGB: dataDiskSize
        lun: j
        name: '${vmName}-DataDisk${j}'
        createOption: 'Empty'
        managedDisk: {
          storageAccountType: diskStorageAccounType
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNicName.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(blobStorageAccountId).primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    vmNicId
  ]
}

resource vmName_customScriptExtensionName 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: vmName_resource
  name: customScriptExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: false
      timestamp: 123456789
      fileUris: [
        scriptFileUri
      ]
    }
    protectedSettings: {
      commandToExecute: 'bash ${scriptFileName} ${vmAdminUsername} ${azureDevOpsUrl} ${azureDevOpsPat} ${azureDevOpsPool}'
    }
  }
  dependsOn: [
    vmId
  ]
}

resource vmName_omsAgentForLinuxName 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: vmName_resource
  name: omsAgentForLinuxName
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.12'
    settings: {
      workspaceId: reference(workspaceId, '2020-03-01-preview').customerId
      stopOnMultipleConnections: false
    }
    protectedSettings: {
      workspaceKey: listKeys(workspaceId, '2020-03-01-preview').primarySharedKey
    }
  }
  dependsOn: [
    vmId
    workspaceId
    customScriptId
  ]
}

resource vmName_omsDependencyAgentForLinuxName 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: vmName_resource
  name: omsDependencyAgentForLinuxName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.10'
    autoUpgradeMinorVersion: true
  }
  dependsOn: [
    vmId
    workspaceId
    customScriptId
    omsAgentForLinuxId
  ]
}

resource vmSubnetNsgName 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: vmSubnetNsgName_var
  location: location
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

resource vmSubnetNsgName_Microsoft_Insights_default 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${vmSubnetNsgName_var}/Microsoft.Insights/default'
  location: location
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
  dependsOn: [
    vmSubnetNsgId
    workspaceId
  ]
}

resource virtualNetworkName_resource 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefixes
      ]
    }
    dhcpOptions: {
      dnsServers: []
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
            id: vmSubnetNsgId
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
            id: bastionSubnetNsgId
          }
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
    enableVmProtection: false
  }
  dependsOn: [
    bastionSubnetNsgId
  ]
}

resource aksClusterUserDefinedManagedIdentityName 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: aksClusterUserDefinedManagedIdentityName_var
  location: location
}

resource contributorRoleAssignmentName 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: contributorRoleAssignmentName_var
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: reference(aksClusterUserDefinedManagedIdentityName_var, '2018-11-30', 'Full').properties.principalId
    scope: resourceGroup().id
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    aksClusterUserDefinedManagedIdentityId
  ]
}

resource acrPullRoleAssignmentName 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = if (acrSku == 'Premium') {
  name: acrPullRoleAssignmentName_var
  properties: {
    roleDefinitionId: acrPullRoleId
    principalId: reference(aksClusterId, '2020-09-01', 'Full').properties.identityProfile.kubeletidentity.objectId
    scope: resourceGroup().id
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    aksClusterId
    acrId
  ]
}

resource acrName_resource 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
  dependsOn: [
    acrPrivateDnsZoneId
  ]
}

resource aksClusterName_resource 'Microsoft.ContainerService/managedClusters@2022-01-02-preview' = {
  name: aksClusterName
  location: location
  sku: {
    name: 'Basic'
    tier: aksClusterSkuTier
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksClusterUserDefinedManagedIdentityId}': {}
    }
  }
  tags: aksClusterTags
  properties: {
    kubernetesVersion: aksClusterKubernetesVersion
    dnsPrefix: aksClusterDnsPrefix
    agentPoolProfiles: [
      {
        name: toLower(systemNodePoolName)
        count: systemNodePoolAgentCount
        vmSize: systemNodePoolVmSize
        osDiskSizeGB: systemNodePoolOsDiskSizeGB
        osDiskType: systemNodePoolOsDiskType
        vnetSubnetID: aksSubnetId
        maxPods: systemNodePoolMaxPods
        osType: systemNodePoolOsType
        maxCount: systemNodePoolMaxCount
        minCount: systemNodePoolMinCount
        scaleSetPriority: systemNodePoolScaleSetPriority
        scaleSetEvictionPolicy: systemNodePoolScaleSetEvictionPolicy
        enableAutoScaling: systemNodePoolEnableAutoScaling
        mode: 'System'
        type: systemNodePoolType
        availabilityZones: systemNodePoolAvailabilityZones
        nodeLabels: systemNodePoolNodeLabels
        nodeTaints: systemNodePoolNodeTaints
      }
      {
        name: toLower(userNodePoolName)
        count: userNodePoolAgentCount
        vmSize: userNodePoolVmSize
        osDiskSizeGB: userNodePoolOsDiskSizeGB
        osDiskType: userNodePoolOsDiskType
        vnetSubnetID: aksSubnetId
        maxPods: userNodePoolMaxPods
        osType: userNodePoolOsType
        maxCount: userNodePoolMaxCount
        minCount: userNodePoolMinCount
        scaleSetPriority: userNodePoolScaleSetPriority
        scaleSetEvictionPolicy: userNodePoolScaleSetEvictionPolicy
        enableAutoScaling: userNodePoolEnableAutoScaling
        mode: 'User'
        type: userNodePoolType
        availabilityZones: userNodePoolAvailabilityZones
        nodeLabels: userNodePoolNodeLabels
        nodeTaints: userNodePoolNodeTaints
      }
    ]
    linuxProfile: {
      adminUsername: aksClusterAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: aksClusterSshPublicKey
          }
        ]
      }
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: httpApplicationRoutingEnabled
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
      }
      aciConnectorLinux: {
        enabled: aciConnectorLinuxEnabled
      }
      azurepolicy: {
        enabled: azurePolicyEnabled
        config: {
          version: 'v2'
        }
      }
      kubeDashboard: {
        enabled: kubeDashboardEnabled
      }
    }
    podIdentityProfile: {
      enabled: podIdentityProfileEnabled
    }
    oidcIssuerProfile: {
      enabled: oidcIssuerProfileEnabled
    }
    enableRBAC: true
    networkProfile: {
      networkPlugin: aksClusterNetworkPlugin
      networkPolicy: aksClusterNetworkPolicy
      podCidr: ((aksClusterNetworkPlugin == 'azure') ? json('null') : aksClusterPodCidr)
      serviceCidr: aksClusterServiceCidr
      dnsServiceIP: aksClusterDnsServiceIP
      dockerBridgeCidr: aksClusterDockerBridgeCidr
      outboundType: aksClusterOutboundType
      loadBalancerSku: aksClusterLoadBalancerSku
      loadBalancerProfile: json('null')
    }
    aadProfile: {
      clientAppID: null
      serverAppID: null
      serverAppSecret: null
      managed: aadProfileManaged
      enableAzureRBAC: aadProfileEnableAzureRBAC
      adminGroupObjectIDs: aadProfileAdminGroupObjectIDs
      tenantID: aadProfileTenantId
    }
    autoUpgradeProfile: {
      upgradeChannel: aksUpgradeChannel
    }
    autoScalerProfile: {
      'scan-interval': autoScalerProfileScanInterval
      'scale-down-delay-after-add': autoScalerProfileScaleDownDelayAfterAdd
      'scale-down-delay-after-delete': autoScalerProfileScaleDownDelayAfterDelete
      'scale-down-delay-after-failure': autoScalerProfileScaleDownDelayAfterFailure
      'scale-down-unneeded-time': autoScalerProfileScaleDownUnneededTime
      'scale-down-unready-time': autoScalerProfileScaleDownUnreadyTime
      'scale-down-utilization-threshold': autoScalerProfileUtilizationThreshold
      'max-graceful-termination-sec': autoScalerProfileMaxGracefulTerminationSec
    }
    apiServerAccessProfile: {
      enablePrivateCluster: aksClusterEnablePrivateCluster
      privateDNSZone: (aksClusterEnablePrivateCluster ? aksPrivateDNSZone : json('null'))
      enablePrivateClusterPublicFQDN: aksEnablePrivateClusterPublicFQDN
    }
  }
  dependsOn: [
    virtualNetworkId
    workspaceId
    contributorRoleAssignmentId
    keyVaultPrivateDnsZoneGroupId
  ]
}

resource logAnalyticsWorkspaceName_resource 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: logAnalyticsSku
    }
    retentionInDays: logAnalyticsRetentionInDays
  }
}

resource containerInsightsSolutionName 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: containerInsightsSolutionName_var
  location: location
  plan: {
    name: containerInsightsSolutionName_var
    promotionCode: ''
    product: 'OMSGallery/ContainerInsights'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspaceName_resource.id
    containedResources: []
  }
}

resource cosmosDbPrivateDnsZoneName 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: cosmosDbPrivateDnsZoneName_var
  location: 'global'
}

resource serviceBusNamespacePrivateDnsZoneName 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: serviceBusNamespacePrivateDnsZoneName_var
  location: 'global'
}

resource blobPrivateDnsZoneName 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobPrivateDnsZoneName_var
  location: 'global'
}

resource acrPrivateDnsZoneName 'Microsoft.Network/privateDnsZones@2020-06-01' = if (acrSku == 'Premium') {
  name: acrPrivateDnsZoneName_var
  location: 'global'
}

resource keyVaultPrivateDnsZoneName 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: keyVaultPrivateDnsZoneName_var
  location: 'global'
}

resource cosmosDbPrivateDnsZoneName_link_to_virtualNetworkName 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: cosmosDbPrivateDnsZoneName
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    cosmosDbPrivateDnsZoneId
    virtualNetworkId
  ]
}

resource serviceBusNamespacePrivateDnsZoneName_link_to_virtualNetworkName 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: serviceBusNamespacePrivateDnsZoneName
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    serviceBusNamespacePrivateDnsZoneId
    virtualNetworkId
  ]
}

resource blobPrivateDnsZoneName_link_to_virtualNetworkName 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZoneName
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    blobPrivateDnsZoneId
    virtualNetworkId
  ]
}

resource acrPrivateDnsZoneName_link_to_virtualNetworkName 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (acrSku == 'Premium') {
  parent: acrPrivateDnsZoneName
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    acrPrivateDnsZoneId
    virtualNetworkId
  ]
}

resource keyVaultPrivateDnsZoneName_link_to_virtualNetworkName 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: keyVaultPrivateDnsZoneName
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    keyVaultPrivateDnsZoneId
    virtualNetworkId
  ]
}

resource cosmosDbPrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: cosmosDbPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: vmSubnetId
    }
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
  }
  dependsOn: [
    cosmosDbAccountId
    virtualNetworkId
  ]
}

resource cosmosDbPrivateEndpointName_CosmosDbPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  parent: cosmosDbPrivateEndpointName_resource
  name: 'CosmosDbPrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfiguration'
        properties: {
          privateDnsZoneId: cosmosDbPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    cosmosDbPrivateDnsZoneId
    cosmosDbPrivateEndpointId
  ]
}

resource serviceBusNamespacePrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-04-01' = {
  name: serviceBusNamespacePrivateEndpointName
  location: location
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
      id: vmSubnetId
    }
    customDnsConfigs: [
      {
        fqdn: concat(serviceBusNamespaceName, serviceBusPublicDNSZoneForwarder)
      }
    ]
  }
  dependsOn: [
    virtualNetworkId
    serviceBusNamespaceId
    serviceBusNamespacePrivateDnsZoneId
  ]
}

resource serviceBusNamespacePrivateEndpointName_ServiceBusNamespacePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  parent: serviceBusNamespacePrivateEndpointName_resource
  name: 'ServiceBusNamespacePrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: serviceBusNamespacePrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    serviceBusNamespacePrivateDnsZoneId
    serviceBusNamespacePrivateEndpointId
  ]
}

resource blobStorageAccountPrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: blobStorageAccountPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: blobStorageAccountPrivateEndpointName
        properties: {
          privateLinkServiceId: blobStorageAccountId
          groupIds: [
            blobStorageAccountPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: vmSubnetId
    }
  }
  dependsOn: [
    virtualNetworkId
    blobStorageAccountId
  ]
}

resource blobStorageAccountPrivateEndpointName_blobPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  parent: blobStorageAccountPrivateEndpointName_resource
  name: blobPrivateDnsZoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: blobPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    blobStorageAccountPrivateEndpointId
    blobPrivateDnsZoneId
    blobStorageAccountPrivateEndpointId
  ]
}

resource keyVaultPrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: keyVaultPrivateEndpointName
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateEndpointName
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            keyVaultPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: vmSubnetId
    }
  }
  dependsOn: [
    virtualNetworkId
    keyVaultId
  ]
}

resource keyVaultPrivateEndpointName_keyVaultPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  parent: keyVaultPrivateEndpointName_resource
  name: '${keyVaultPrivateDnsZoneGroupName}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    keyVaultId
    keyVaultPrivateDnsZoneId
    keyVaultPrivateEndpointId
  ]
}

resource acrPrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-07-01' = if (acrSku == 'Premium') {
  name: acrPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: acrPrivateEndpointName
        properties: {
          privateLinkServiceId: acrId
          groupIds: [
            acrPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: vmSubnetId
    }
  }
  dependsOn: [
    virtualNetworkId
    acrId
  ]
}

resource acrPrivateEndpointName_acrPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = if (acrSku == 'Premium') {
  parent: acrPrivateEndpointName_resource
  name: '${acrPrivateDnsZoneGroupName}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: acrPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    acrId
    acrPrivateDnsZoneId
    acrPrivateEndpointId
  ]
}

resource AllAzureAdvisorAlert 'microsoft.insights/activityLogAlerts@2017-04-01' = {
  name: 'AllAzureAdvisorAlert'
  location: 'Global'
  properties: {
    scopes: [
      resourceGroup().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Recommendation'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Advisor/recommendations/available/action'
        }
      ]
    }
    enabled: true
    description: 'All azure advisor alerts'
  }
}

resource keyVaultName_resource 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  properties: {
    accessPolicies: [for item in keyVaultObjectIds: {
      tenantId: subscription().tenantId
      objectId: item
      permissions: {
        keys: [
          'get'
          'list'
        ]
        secrets: [
          'get'
          'list'
        ]
        certificates: [
          'get'
          'list'
        ]
      }
    }]
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: keyVaultNetworkRuleSetDefaultAction
    }
    enabledForDeployment: keyVaultEnabledForDeployment
    enabledForDiskEncryption: keyVaultEnabledForDiskEncryption
    enabledForTemplateDeployment: keyVaultEnabledForTemplateDeployment
    enableSoftDelete: keyVaultEnableSoftDelete
  }
}

resource keyVaultName_ApplicationInsights_InstrumentationKey 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'ApplicationInsights--InstrumentationKey'
  properties: {
    value: reference(applicationInsightsId, '2020-02-02').instrumentationKey
  }
  dependsOn: [
    keyVaultId
    applicationInsightsId
  ]
}

resource keyVaultName_DataProtection_BlobStorage_AccountName 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'DataProtection--BlobStorage--AccountName'
  properties: {
    value: blobStorageAccountName
  }
  dependsOn: [
    keyVaultId
    blobStorageAccountId
  ]
}

resource keyVaultName_DataProtection_BlobStorage_ConnectionString 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'DataProtection--BlobStorage--ConnectionString'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${blobStorageAccountName};AccountKey=${listKeys(blobStorageAccountId, '2021-08-01').keys[0].value};EndpointSuffix=core.windows.net'
  }
  dependsOn: [
    keyVaultId
    blobStorageAccountId
  ]
}

resource keyVaultName_DataProtection_BlobStorage_UseAzureCredential 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'DataProtection--BlobStorage--UseAzureCredential'
  properties: {
    value: 'true'
  }
  dependsOn: [
    keyVaultId
    blobStorageAccountId
  ]
}

resource keyVaultName_NotificationService_ServiceBus_ConnectionString 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'NotificationService--ServiceBus--ConnectionString'
  properties: {
    value: listkeys(serviceBusNamespaceAuthRuleResourceId, '2017-04-01').primaryConnectionString
  }
  dependsOn: [
    keyVaultId
    serviceBusNamespaceId
  ]
}

resource keyVaultName_NotificationService_ServiceBus_Namespace 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'NotificationService--ServiceBus--Namespace'
  properties: {
    value: serviceBusNamespaceName
  }
  dependsOn: [
    keyVaultId
    serviceBusNamespaceId
  ]
}

resource keyVaultName_NotificationService_ServiceBus_QueueName 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'NotificationService--ServiceBus--QueueName'
  properties: {
    value: serviceBusQueueName
  }
  dependsOn: [
    keyVaultId
    serviceBusNamespaceId
  ]
}

resource keyVaultName_NotificationService_ServiceBus_UseAzureCredential 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'NotificationService--ServiceBus--UseAzureCredential'
  properties: {
    value: 'true'
  }
  dependsOn: [
    keyVaultId
    serviceBusNamespaceId
  ]
}

resource keyVaultName_RepositoryService_CosmosDb_CollectionName 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'RepositoryService--CosmosDb--CollectionName'
  properties: {
    value: cosmosDbContainerName
  }
  dependsOn: [
    keyVaultId
    cosmosDbDatabaseId
  ]
}

resource keyVaultName_RepositoryService_CosmosDb_DatabaseName 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'RepositoryService--CosmosDb--DatabaseName'
  properties: {
    value: cosmosDbDatabaseName
  }
  dependsOn: [
    keyVaultId
    cosmosDbDatabaseId
  ]
}

resource keyVaultName_RepositoryService_CosmosDb_EndpointUri 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'RepositoryService--CosmosDb--EndpointUri'
  properties: {
    value: reference(cosmosDbAccountId, '2021-10-15').documentEndpoint
  }
  dependsOn: [
    keyVaultId
    cosmosDbDatabaseId
  ]
}

resource keyVaultName_RepositoryService_CosmosDb_PrimaryKey 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'RepositoryService--CosmosDb--PrimaryKey'
  properties: {
    value: listKeys(cosmosDbAccountId, '2021-10-15').primaryMasterKey
  }
  dependsOn: [
    keyVaultId
    cosmosDbDatabaseId
  ]
}

resource keyVaultName_RepositoryService_CosmosDb_UseAzureCredential 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: keyVaultName_resource
  name: 'RepositoryService--CosmosDb--UseAzureCredential'
  properties: {
    value: 'true'
  }
  dependsOn: [
    keyVaultId
    cosmosDbDatabaseId
  ]
}

resource keyVaultName_Microsoft_Insights_default 'Microsoft.KeyVault/vaults/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${keyVaultName}/Microsoft.Insights/default'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
  dependsOn: [
    keyVaultId
    workspaceId
  ]
}
