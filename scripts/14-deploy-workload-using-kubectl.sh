#!/bin/bash

# For more information, see https://azure.github.io/azure-workload-identity/docs/quick-start.html

# Variables
namespace="todo"
deploymentTemplate="todolist.yml"

configMapName="todolist-configmap"
configMapTemplate="config-map.yml"

aspNetCoreEnvironment="Docker"
todoApiServiceEndpointUri="todolist-api"
todoWebDataProtectionBlobStorageContainerName="todoweb"
todoApiDataProtectionBlobStorageContainerName="todoapi"
keyVaultName="KaluaKeyVault"

frontendIngressName="ingress-frontend"
frontendIngressTemplate="ingress-frontend.yml"
frontendHostName="ax.babosbird.com"
frontendSecretName="tls-frontend"
frontendServiceName="todolist-web"
frontendPort="80"

backendIngressName="ingress-backend"
backendIngressTemplate="ingress-backend.yml"
backendHostName="axapi.babosbird.com"
backendSecretName="tls-backend"
backendServiceName="todolist-api"
backendPort="80"

# Create the namespace if it doesn't already exists in the cluster
result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
    echo "[$namespace] namespace already exists in the cluster"
else
    echo "[$namespace] namespace does not exist in the cluster"
    echo "creating [$namespace] namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Check if the configMap already exists
result=$(kubectl get configmap -n $namespace -o json | jq -r '.items[].metadata.name | select(. == "'$configMapName'")')

if [[ -n $result ]]; then
    echo "[$configMapName] ingress already exists"
    exit
else
    # Create the configMap 
    echo "[$configMapName] ingress does not exist"
    echo "Creating [$configMapName] ingress..."
    cat $configMapTemplate | 
    yq -Y "(.metadata.name)|="\""$configMapName"\" |
    yq -Y "(.data.aspNetCoreEnvironment)|="\""$aspNetCoreEnvironment"\" |
    yq -Y "(.data.todoApiServiceEndpointUri)|="\""$todoApiServiceEndpointUri"\" |
    yq -Y "(.data.todoWebDataProtectionBlobStorageContainerName)|="\""$todoWebDataProtectionBlobStorageContainerName"\" |
    yq -Y "(.data.todoApiDataProtectionBlobStorageContainerName)|="\""$todoApiDataProtectionBlobStorageContainerName"\" |
    yq -Y "(.data.keyVaultName)|="\""$keyVaultName"\" |
    kubectl apply -n $namespace -f -
fi

# Install todolist application
kubectl apply -f $deploymentTemplate -n $namespace

# Check if the frontend ingress already exists
result=$(kubectl get ingress -n $namespace -o json | jq -r '.items[].metadata.name | select(. == "'$frontendIngressName'")')

if [[ -n $result ]]; then
    echo "[$frontendIngressName] ingress already exists"
    exit
else
    # Create the frontend ingress 
    echo "[$frontendIngressName] ingress does not exist"
    echo "Creating [$frontendIngressName] ingress..."
    cat $frontendIngressTemplate | 
    yq -Y "(.metadata.name)|="\""$frontendIngressName"\" |
    yq -Y "(.spec.tls[0].hosts[0])|="\""$frontendHostName"\" |
    yq -Y "(.spec.tls[0].secretName)|="\""$frontendSecretName"\" |
    yq -Y "(.spec.rules[0].host)|="\""$frontendHostName"\" |
    yq -Y "(.spec.rules[0].http.paths[0].backend.service.name)|="\""$frontendServiceName"\" |
    yq -Y "(.spec.rules[0].http.paths[0].backend.service.port.number)|=$frontendPort" |
    kubectl apply -n $namespace -f -
fi

# Check if the backend ingress already exists
result=$(kubectl get ingress -n $namespace -o json | jq -r '.items[].metadata.name | select(. == "'$backendIngressName'")')

if [[ -n $result ]]; then
    echo "[$backendIngressName] ingress already exists"
    exit
else
    # Create the backend ingress 
    echo "[$backendIngressName] ingress does not exist"
    echo "Creating [$backendIngressName] ingress..."
    cat $backendIngressTemplate | 
    yq -Y "(.metadata.name)|="\""$backendIngressName"\" |
    yq -Y "(.spec.tls[0].hosts[0])|="\""$backendHostName"\" |
    yq -Y "(.spec.tls[0].secretName)|="\""$backendSecretName"\" |
    yq -Y "(.spec.rules[0].host)|="\""$backendHostName"\" |
    yq -Y "(.spec.rules[0].http.paths[0].backend.service.name)|="\""$backendServiceName"\" |
    yq -Y "(.spec.rules[0].http.paths[0].backend.service.port.number)|=$backendPort" |
    kubectl apply -n $namespace -f -
fi