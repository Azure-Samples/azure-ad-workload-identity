#!/bin/bash

# For more information, see https://azure.github.io/azure-workload-identity/docs/installation/mutating-admission-webhook.html

# Variables
repoName="azure-workload-identity"
namespace="azure-workload-identity-system"
releaseName="workload-identity-webhook"
chartName="workload-identity-webhook"
repoUrl="https://azure.github.io/azure-workload-identity/charts"
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)
tenantId=$(az account show --query tenantId --output tsv)

# Check if the repo is not already added
echo "Checking if [$repoName] has been already added..."
result=$(helm repo list | grep $repoName | awk '{print $1}')

if [[ -n $result ]]; then
    echo "[$repoName] Helm repo has been already added"
else
    # Add the Jetstack Helm repository
    echo "[$repoName] Helm repo has not been added yet"
    echo "Adding [$repoName] Helm repo..."
    helm repo add $repoName $repoUrl
fi

# Update your local Helm chart repository cache
echo 'Updating Helm repos...'
helm repo update

# Install Helm chart
result=$(helm list -n $namespace | grep $releaseName | awk '{print $1}')

if [[ -n $result ]]; then
    echo "[$releaseName] already exists in the $namespace namespace"
else
    # Install the Helm chart
    echo "Deploying [$releaseName] release to the $namespace namespace..."
    helm install $releaseName $repoName/$chartName \
        --namespace $namespace \
        --create-namespace \
        --set azureTenantID="$tenantId"
fi