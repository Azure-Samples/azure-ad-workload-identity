#!/bin/bash

# Variables
acrName="<azure-container-registry-name>"
dnsZoneName="<your-public-dns-zone-name>"
keyVaultName="<azure-key-vault-name>"

release="todolist"
namespace="todolist"
chart="../chart"

frontendContainerImageName="${acrName,,}.azurecr.io/todoweb"
frontendContainerImageTag="<frontend-container-image-tag>"
frontendHostName="todo.$dnsZoneName"
frontendReplicaCount=3

backendContainerImageName="${acrName,,}.azurecr.io/todoapi"
backendContainerImageTag="net60v06"
backendHostName="todoapi.$dnsZoneName"
backendReplicaCount=3

# Check if the Helm release already exists
echo "Checking if a [$release] Helm release exists in the [$namespace] namespace..."
name=$(helm list -n $namespace | awk '{print $1}' | grep -Fx $release)

if [[ -n $name ]]; then
    # Install the Helm chart for the tenant to a dedicated namespace
    echo "A [$release] Helm release already exists in the [$namespace] namespace"
    echo "Upgrading the [$release] Helm release to the [$namespace] namespace via Helm..."
    helm upgrade $release $chart \
    --set frontendDeployment.image.repository=$frontendContainerImageName \
    --set frontendDeployment.image.tag=$frontendContainerImageTag \
    --set frontendDeployment.replicaCount=$frontendReplicaCount \
    --set backendDeployment.image.repository=$backendContainerImageName \
    --set backendDeployment.image.tag=$backendContainerImageTag \
    --set backendDeployment.replicaCount=$backendReplicaCount \
    --set nameOverride=$namespace \
    --set frontendIngress.hosts[0].host=$frontendHostName \
    --set frontendIngress.tls[0].hosts[0]=$frontendHostName \
    --set backendIngress.hosts[0].host=$backendHostName \
    --set backendIngress.tls[0].hosts[0]=$backendHostName \
    --set configMap.keyVaultName=$keyVaultName

    if [[ $? == 0 ]]; then
        echo "[$release] Helm release successfully upgraded to the [$namespace] namespace via Helm"
    else
        echo "Failed to upgrade [$release] Helm release to the [$namespace] namespace via Helm"
        exit
    fi
else
    # Install the Helm chart for the tenant to a dedicated namespace
    echo "The [$release] Helm release does not exist in the [$namespace] namespace"
    echo "Deploying the [$release] Helm release to the [$namespace] namespace via Helm..."
    helm install $release $chart \
    --create-namespace \
    --namespace $namespace \
    --set frontendDeployment.image.repository=$frontendContainerImageName \
    --set frontendDeployment.image.tag=$frontendContainerImageTag \
    --set backendDeployment.image.repository=$backendContainerImageName \
    --set backendDeployment.image.tag=$backendContainerImageTag \
    --set nameOverride=$namespace \
    --set frontendIngress.hosts[0].host=$frontendHostName \
    --set frontendIngress.tls[0].hosts[0]=$frontendHostName \
    --set backendIngress.hosts[0].host=$backendHostName \
    --set backendIngress.tls[0].hosts[0]=$backendHostName \
    --set configMap.keyVaultName=$keyVaultName

    if [[ $? == 0 ]]; then
        echo "[$release] Helm release successfully deployed to the [$namespace] namespace via Helm"
    else
        echo "Failed to install [$release] Helm release to the [$namespace] namespace via Helm"
        exit
    fi
fi