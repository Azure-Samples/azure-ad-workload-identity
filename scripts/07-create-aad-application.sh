#!/bin/bash

# Variables
applicationName="<aad-application-name>" 
keyVaultName="<key-vault-name>"
keyVaultResourceGroupName="<key-vault-resource-group>"
storageAccountName="<storage-account-name>"
cosmosDbAccountName="<cosmos-db-account-name>"
cosmosDbAccountResourceGroupName="<cosmos-db-resource-group-name>"
serviceBusNamespace="<service-bus-namespace-name>"
serviceBusResourceGroupName="service-bus-resource-group-name>"
tenantId=$(az account show --query tenantId --output tsv)

# Create Azure Active Directory Application
echo "Checking if an AAD application with [$applicationName] display name already exists in the [$tenantId] tenant..."
displayName=$(az ad sp list \
  --display-name $applicationName \
  --query [].appDisplayName \
  --output tsv)

if [[ -z $displayName ]]; then
  echo "No AAD application with [$applicationName] display name exists in the [$tenantId] tenant"
  echo "Creating AAD application with [$applicationName] display name exists in the [$tenantId] tenant..."

  # Create AAD application
  az ad sp create-for-rbac --name $applicationName

  if [[ $? == 0 ]]; then
    echo "AAD application with [$applicationName] display name successfully created in the [$tenantId] tenant"
  else
    echo "Failed to create an AAD application with [$applicationName] display name in the [$tenantId] tenant"
  fi
else
  echo "An AAD application with [$applicationName] display name already exists in the [$tenantId] tenant"
fi

# Get the appId of the AAD application
echo "Getting the appId of the AAD application with [$applicationName] display name..."
appId=$(az ad sp list \
  --display-name $applicationName \
  --query [].appId \
  --output tsv)

if [[ -n $appId ]]; then
  echo "[$appId] appId successfully retrieved"
else
  echo "Failed to retrieve the appId of the AAD application with [$applicationName] display name"
  exit -1
fi

# Get the objectId of the AAD application
echo "Getting the objectId of the service principal associated to the AAD application with [$applicationName] display name..."
objectId=$(az ad sp show  \
  --id $appId \
  --query objectId \
  --output tsv)

if [[ -n $objectId ]]; then
  echo "[$objectId] objectId successfully retrieved"
else
  echo "Failed to retrieve the objectId of the AAD application with [$applicationName] display name"
  exit -1
fi

# Create Key Vault access policy for the AAD application
echo "Setting the access policy for AAD application with [$applicationName] display name on the [$keyVaultName] key vault..."
az keyvault set-policy --name $keyVaultName \
  --secret-permissions get list \
  --spn $appId &>/dev/null

if [[ $? == 0 ]]; then
  echo "Access policy successfully set for the AAD application with [$applicationName] display name on the [$keyVaultName] key vault"
else
  echo "Failed to set the access policy for the AAD application with [$applicationName] display name on the [$keyVaultName] key vault"
fi

# Get storage account resource id
storageAccountId=$(az storage account show \
  --name $storageAccountName \
  --query id \
  --output tsv)

if [[ -n $storageAccountId ]]; then
  echo "Resource id for the [$storageAccountName] storage account successfully retrieved"
else
  echo "Failed to the resource id for the [$storageAccountName] storage account"
  exit -1
fi

# Assign the Storage Blob Data Contributor role to the service principal of the AAD application with the storage account as scope
role="Storage Blob Data Contributor"
echo "Checking if service principal of the [$applicationName] AAD application has been assigned to [$role] role with [$storageAccountName] storage account as scope..."
current=$(az role assignment list \
  --assignee $appId \
  --scope $storageAccountId \
  --query "[?roleDefinitionName=='$role'].roleDefinitionName" \
  --output tsv 2>/dev/null)

if [[ $current == $role ]]; then
  echo "Service principal of the [$applicationName] AAD application is already assigned to the ["$current"] role with [$storageAccountName] storage account as scope"
else
  echo "Service principal of the [$applicationName] AAD application is not assigned to the [$role] role with [$storageAccountName] storage account as scope"
  echo "Assigning the service principal of the [$applicationName] AAD application to the [$role] role with [$storageAccountName] storage account as scope..."

  az role assignment create \
    --assignee $appId \
    --role "$role" \
    --scope $storageAccountId 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "Service principal of the [$applicationName] AAD application successfully assigned to the [$role] role with [$storageAccountName] storage account as scope"
  else
    echo "Failed to assign the service principal of the [$applicationName] AAD application to the [$role] role with [$storageAccountName] storage account as scope"
    exit
  fi
fi

# Assign the Cosmos DB Built-in Data Contributor role to the service principal of the AAD application with the Cosmos DB accout as scope
role="Cosmos DB Built-in Data Contributor"
roleId="00000000-0000-0000-0000-000000000002"
echo "Checking if service principal of the [$applicationName] AAD application has been assigned to [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope..."
current=$(az cosmosdb sql role assignment list \
  --account-name $cosmosDbAccountName \
  --resource-group $cosmosDbAccountResourceGroupName \
  --query "[?principalId=='$objectId'].roleDefinitionId" \
  --output tsv)

if [[ -n $current ]]; then
  echo "Service principal of the [$applicationName] AAD application is already assigned to the ["$role"] role with [$cosmosDbAccountName] Cosmos DB account as scope"
else
  echo "Service principal of the [$applicationName] AAD application is not assigned to the [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope"
  echo "Assigning the service principal of the [$applicationName] AAD application to the [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope..."

  az cosmosdb sql role assignment create \
    --account-name $cosmosDbAccountName \
    --resource-group $cosmosDbAccountResourceGroupName \
    --scope "/" \
    --principal-id $objectId \
    --role-definition-id "$roleId" 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "Service principal of the [$applicationName] AAD application successfully assigned to the [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope"
  else
    echo "Failed to assign the service principal of the [$applicationName] AAD application to the [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope"
    exit
  fi
fi

# Get Service Bus namespace resource id
serviceBusNamespaceId=$(az servicebus namespace show \
  --name $serviceBusNamespace \
  --resource-group $serviceBusResourceGroupName \
  --query id \
  --output tsv)

if [[ -n $serviceBusNamespaceId ]]; then
  echo "Resource id for the [$serviceBusNamespace] Service Bus namespace successfully retrieved"
else
  echo "Failed to the resource id for the [$serviceBusNamespace] Service Bus namespace"
  exit -1
fi

# Assign the Azure Service Bus Data Owner role to the service principal of the AAD application with the Service Bus namespace as scope
role="Azure Service Bus Data Owner"
echo "Checking if service principal of the [$applicationName] AAD application has been assigned to [$role] role with [$serviceBusNamespace] Service Bus namespace as scope..."
current=$(az role assignment list \
  --assignee $appId \
  --scope $serviceBusNamespaceId \
  --query "[?roleDefinitionName=='$role'].roleDefinitionName" \
  --output tsv 2>/dev/null)

if [[ -n $current ]]; then
  echo "Service principal of the [$applicationName] AAD application is already assigned to the ["$current"] role with [$serviceBusNamespace] Service Bus namespace as scope"
else
  echo "Service principal of the [$applicationName] AAD application is not assigned to the [$role] role with [$serviceBusNamespace] Service Bus namespace as scope"
  echo "Assigning the service principal of the [$applicationName] AAD application to the [$role] role with [$serviceBusNamespace] Service Bus namespace as scope..."

  az role assignment create \
    --assignee $appId \
    --role "$role" \
    --scope $serviceBusNamespaceId 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "Service principal of the [$applicationName] AAD application successfully assigned to the [$role] role with [$serviceBusNamespace] Service Bus namespace as scope"
  else
    echo "Failed to assign the service principal of the [$applicationName] AAD application to the [$role] role with [$serviceBusNamespace] Service Bus namespace as scope"
    exit
  fi
fi
