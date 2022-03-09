#!/bin/bash

# Variables
keyVaultName="<azure-key-vault-name>"
keyVaultResourceGroupName="<azure-key-vault-resource-group-name>"
keyVaultSku="Standard"

cosmosDBAccountName="<cosmos-db-account>"
cosmosDBPrimaryKey="<cosmos-db-primary-key>"
cosmosDbUseAzureCredential="true"
cosmosDbDatabaseName="TodoApiDb"
cosmosDbCollectionName="TodoApiCollection"

serviceBusConnectionString="<service-bus-namespace-connection-string>"
serviceBusNamespace="<service-bus-namespace-name>"
serviceBusUseAzureCredential="true"
serviceBusQueueName="todoapi"

applicationInsightsInstrumentationKey="<application-insights-instrumentation-key>"

dataProtectionBlobStorageConnectionString="<storage-account-connection-string>"
dataProtectionBlobStorageAccountName="<storage-account-name>"
dataProtectionBlobStorageUseAzureCredential="true"

location="WestEurope"
subscriptionName=$(az account show --query name --output tsv)
subscriptionId=$(az account show --query id --output tsv)

# Check if the resource group already exists
echo "Checking if [$keyVaultResourceGroupName] resource group actually exists in the [$subscriptionName] subscription..."

az group show --name $keyVaultResourceGroupName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$keyVaultResourceGroupName] resource group actually exists in the [$subscriptionName] subscription"
    echo "Creating [$keyVaultResourceGroupName] resource group in the [$subscriptionName] subscription..."
    
    # create the resource group
    az group create --name $keyVaultResourceGroupName --location $location 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$keyVaultResourceGroupName] resource group successfully created in the [$subscriptionName] subscription"
    else
        echo "Failed to create [$keyVaultResourceGroupName] resource group in the [$subscriptionName] subscription"
        exit
    fi
else
	echo "[$keyVaultResourceGroupName] resource group already exists in the [$subscriptionName] subscription"
fi

# Check if the key vault already exists
echo "Checking if [$keyVaultName] key vault actually exists in the [$subscriptionName] subscription..."

az keyvault show --name $keyVaultName --resource-group $keyVaultResourceGroupName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$keyVaultName] key vault actually exists in the [$subscriptionName] subscription"
    echo "Creating [$keyVaultName] key vault in the [$subscriptionName] subscription..."
    
    # create the key vault
    az keyvault create \
    --name $keyVaultName \
    --resource-group $keyVaultResourceGroupName \
    --location $location \
    --enabled-for-deployment \
    --enabled-for-disk-encryption \
    --enabled-for-template-deployment \
    --sku $keyVaultSku 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$keyVaultName] key vault successfully created in the [$subscriptionName] subscription"
    else
        echo "Failed to create [$keyVaultName] key vault in the [$subscriptionName] subscription"
        exit
    fi
else
	echo "[$keyVaultName] key vault already exists in the [$subscriptionName] subscription"
fi

# Check if the secret already exists
cosmosDbEndpointUriSecretName="RepositoryService--CosmosDb--EndpointUri"
cosmosDbEndpointUriSecretValue="https://${cosmosDBAccountName}.documents.azure.com:443/"

echo "Checking if [$cosmosDbEndpointUriSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbEndpointUriSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$cosmosDbEndpointUriSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$cosmosDbEndpointUriSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $cosmosDbEndpointUriSecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbEndpointUriSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$cosmosDbEndpointUriSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$cosmosDbEndpointUriSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$cosmosDbEndpointUriSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
cosmosDbPrimaryKeySecretName="RepositoryService--CosmosDb--PrimaryKey"
cosmosDbPrimaryKeySecretValue=$cosmosDBPrimaryKey

echo "Checking if [$cosmosDbPrimaryKeySecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbPrimaryKeySecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$cosmosDbPrimaryKeySecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$cosmosDbPrimaryKeySecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $cosmosDbPrimaryKeySecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbPrimaryKeySecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$cosmosDbPrimaryKeySecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$cosmosDbPrimaryKeySecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$cosmosDbPrimaryKeySecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
cosmosDbUseAzureCredentialSecretName="RepositoryService--CosmosDb--UseAzureCredential"
cosmosDbUseAzureCredentialSecretValue=$cosmosDbUseAzureCredential

echo "Checking if [$cosmosDbUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbUseAzureCredentialSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$cosmosDbUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$cosmosDbUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $cosmosDbUseAzureCredentialSecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbUseAzureCredentialSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$cosmosDbUseAzureCredentialSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$cosmosDbUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$cosmosDbUseAzureCredentialSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
cosmosDbDatabaseNameSecretName="RepositoryService--CosmosDb--DatabaseName"
cosmosDbDatabaseNameSecretValue=$cosmosDbDatabaseName

echo "Checking if [$cosmosDbDatabaseNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbDatabaseNameSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$cosmosDbDatabaseNameSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$cosmosDbDatabaseNameSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $cosmosDbDatabaseNameSecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbDatabaseNameSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$cosmosDbDatabaseNameSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$cosmosDbDatabaseNameSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$cosmosDbDatabaseNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
cosmosDbCollectionNameSecretName="RepositoryService--CosmosDb--CollectionName"
cosmosDbCollectionNameSecretValue=$cosmosDbCollectionName

echo "Checking if [$cosmosDbCollectionNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbCollectionNameSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$cosmosDbCollectionNameSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$cosmosDbCollectionNameSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $cosmosDbCollectionNameSecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbCollectionNameSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$cosmosDbCollectionNameSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$cosmosDbCollectionNameSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$cosmosDbCollectionNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
serviceBusConnectionStringSecretName="NotificationService--ServiceBus--ConnectionString"
serviceBusConnectionStringSecretValue=$serviceBusConnectionString

echo "Checking if [$serviceBusConnectionStringSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $serviceBusConnectionStringSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$serviceBusConnectionStringSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$serviceBusConnectionStringSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $serviceBusConnectionStringSecretName \
    --vault-name $keyVaultName \
    --value $serviceBusConnectionStringSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$serviceBusConnectionStringSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$serviceBusConnectionStringSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$serviceBusConnectionStringSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
serviceBusNamespaceSecretName="NotificationService--ServiceBus--Namespace"
serviceBusNamespaceSecretValue=$serviceBusNamespace

echo "Checking if [$serviceBusNamespaceSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $serviceBusNamespaceSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$serviceBusNamespaceSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$serviceBusNamespaceSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $serviceBusNamespaceSecretName \
    --vault-name $keyVaultName \
    --value $serviceBusNamespaceSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$serviceBusNamespaceSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$serviceBusNamespaceSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$serviceBusNamespaceSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
serviceBusUseAzureCredentialSecretName="NotificationService--ServiceBus--UseAzureCredential"
serviceBusUseAzureCredentialSecretValue=$serviceBusUseAzureCredential

echo "Checking if [$serviceBusUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $serviceBusUseAzureCredentialSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$serviceBusUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$serviceBusUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $serviceBusUseAzureCredentialSecretName \
    --vault-name $keyVaultName \
    --value $serviceBusUseAzureCredentialSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$serviceBusUseAzureCredentialSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$serviceBusUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$serviceBusUseAzureCredentialSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
serviceBusQueueNameSecretName="NotificationService--ServiceBus--QueueName"
serviceBusQueueNameSecretValue=$serviceBusQueueName

echo "Checking if [$serviceBusQueueNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $serviceBusQueueNameSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$serviceBusQueueNameSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$serviceBusQueueNameSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $serviceBusQueueNameSecretName \
    --vault-name $keyVaultName \
    --value $serviceBusQueueNameSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$serviceBusQueueNameSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$serviceBusQueueNameSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$serviceBusQueueNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
applicationInsightsInstrumentationKeySecretName="ApplicationInsights--InstrumentationKey"
applicationInsightsInstrumentationKeySecretValue=$applicationInsightsInstrumentationKey

echo "Checking if [$applicationInsightsInstrumentationKeySecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $applicationInsightsInstrumentationKeySecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$applicationInsightsInstrumentationKeySecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$applicationInsightsInstrumentationKeySecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $applicationInsightsInstrumentationKeySecretName \
    --vault-name $keyVaultName \
    --value $applicationInsightsInstrumentationKeySecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$applicationInsightsInstrumentationKeySecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$applicationInsightsInstrumentationKeySecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$applicationInsightsInstrumentationKeySecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
dataProtectionBlobStorageConnectionStringSecretName="DataProtection--BlobStorage--ConnectionString"
dataProtectionBlobStorageConnectionStringSecretValue=$dataProtectionBlobStorageConnectionString

echo "Checking if [$dataProtectionBlobStorageConnectionStringSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $dataProtectionBlobStorageConnectionStringSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$dataProtectionBlobStorageConnectionStringSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$dataProtectionBlobStorageConnectionStringSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $dataProtectionBlobStorageConnectionStringSecretName \
    --vault-name $keyVaultName \
    --value $dataProtectionBlobStorageConnectionStringSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$dataProtectionBlobStorageConnectionStringSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$dataProtectionBlobStorageConnectionStringSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$dataProtectionBlobStorageConnectionStringSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
dataProtectionBlobStorageAccountNameSecretName="DataProtection--BlobStorage--AccountName"
dataProtectionBlobStorageAccountNameSecretValue=$dataProtectionBlobStorageAccountName

echo "Checking if [$dataProtectionBlobStorageAccountNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $dataProtectionBlobStorageAccountNameSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$dataProtectionBlobStorageAccountNameSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$dataProtectionBlobStorageAccountNameSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $dataProtectionBlobStorageAccountNameSecretName \
    --vault-name $keyVaultName \
    --value $dataProtectionBlobStorageAccountNameSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$dataProtectionBlobStorageAccountNameSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$dataProtectionBlobStorageAccountNameSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$dataProtectionBlobStorageAccountNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
dataProtectionBlobStorageUseAzureCredentialSecretName="DataProtection--BlobStorage--UseAzureCredential"
dataProtectionBlobStorageUseAzureCredentialSecretValue=$dataProtectionBlobStorageUseAzureCredential

echo "Checking if [$dataProtectionBlobStorageUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $dataProtectionBlobStorageUseAzureCredentialSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$dataProtectionBlobStorageUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$dataProtectionBlobStorageUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault..."
    
    # create the secret
    az keyvault secret set \
    --name $dataProtectionBlobStorageUseAzureCredentialSecretName \
    --vault-name $keyVaultName \
    --value $dataProtectionBlobStorageUseAzureCredentialSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$dataProtectionBlobStorageUseAzureCredentialSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$dataProtectionBlobStorageUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$dataProtectionBlobStorageUseAzureCredentialSecretName] secret already exists in the [$keyVaultName] key vault"
fi