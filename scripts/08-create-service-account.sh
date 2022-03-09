#!/bin/bash

# Variables
aksClusterName="<aks-cluster-name>"
aksResourceGroupName="<aks-cluster-resource-group>"
namespace="todolist"
serviceAccountName="todolist-identity-sa"
applicationName="<aad-application-name>" 
tenantId=$(az account show --query tenantId --output tsv)
useAzwi=0

# Get the OIDC service account issuer URL
oidcIssuerUrl=$(az aks show \
  --name $aksClusterName \
  --resource-group $aksResourceGroupName \
  --query oidcIssuerProfile.issuerUrl \
  --output tsv)

if [[ -n $oidcIssuerUrl ]]; then
  echo "[$oidcIssuerUrl] OIDC service account issuer URL successfully retrieved for the [$aksClusterName] AKS cluster"
else
  echo "Failed to retrieve the OIDC service account issuer URL for the [$aksClusterName] AKS cluster"
  exit -1
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
echo "Getting the objectId of the AAD application with [$applicationName] display name..."
objectId=$(az ad app show \
  --id $appId \
  --query objectId \
  --output tsv)

if [[ -n $objectId ]]; then
  echo "[$objectId] objectId successfully retrieved"
else
  echo "Failed to retrieve the objectId of the AAD application with [$applicationName] display name"
  exit -1
fi

# Check if the namespace exists in the cluster
echo "Checking if the [$namespace] namespace already exists..."
result=$(kubectl get ns -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
  echo "[$namespace] namespace already exists in the cluster"
else
  echo "[$namespace] namespace does not exist in the cluster"
  echo "Creating [$namespace] namespace in the cluster..."

  # Create the namespace
  kubectl create namespace $namespace
fi

# Check if the service account exists in the namespace
echo "Checking if the [$serviceAccountName] service account already exists in the [$namespace] namespace..."
result=$(kubectl get serviceaccount -n $namespace -o jsonpath="{.items[?(@.metadata.name=='$serviceAccountName')].metadata.name}")

if [[ -n $result ]]; then
  echo "[$serviceAccountName] service account already exists in the [$namespace] namespace"
else
  echo "[$serviceAccountName] service account does not exist in the [$namespace] namespace"
  echo "Creating [$serviceAccountName] service account in the [$namespace] namespace..."

  # Create the service account
  if [[ $useAzwi == 0 ]]; then
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${serviceAccountName}
  namespace: ${namespace}
  annotations:
    azure.workload.identity/client-id: ${appId}
    azure.workload.identity/tenant-id: ${tenantId}
  labels:
    azure.workload.identity/use: "true"
EOF
  else
    azwi serviceaccount create phase sa \
      --aad-application-name "${applicationName}" \
      --service-account-namespace "${namespace}" \
      --service-account-name "${serviceAccountName}"
  fi
fi

# Delete any existing body.json from the current folder
if [[ -f body.json ]]; then
  rm body.json
fi

# Establish federated identity credential between the AAD application and the service account issuer & subject
echo "Establishing federated identity credential between the [$applicationName] AAD application and the [$serviceAccountName] service account issuer & subject..."
if [[ $useAzwi == 0 ]]; then
  cat <<EOF >body.json
{
  "name": "kubernetes-federated-credential",
  "issuer": "${oidcIssuerUrl}",
  "subject": "system:serviceaccount:${namespace}:${serviceAccountName}",
  "description": "Kubernetes service account federated credential",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
EOF
  az rest \
    --method POST \
    --uri "https://graph.microsoft.com/beta/applications/$objectId/federatedIdentityCredentials" \
    --body @body.json 1>/dev/null
  
  if [[ $? == 0 ]]; then
    echo "Federated identity credential successfully established between the [$applicationName] AAD application and the [$serviceAccountName] service account issuer & subject"
  else
    echo "Failed to establish federated identity credential between the [$applicationName] AAD application and the [$serviceAccountName] service account issuer & subject"
  fi
else
  azwi serviceaccount create phase federated-identity \
    --aad-application-name "$applicationName" \
    --service-account-namespace "$namespace}" \
    --service-account-name "$serviceAccountName" \
    --service-account-issuer-url "$oidcIssuerUrl"
  if [[ $? == 0 ]]; then
    echo "Federated identity credential successfully established between the [$applicationName] AAD application and the [$serviceAccountName] service account issuer & subject"
  else
    echo "Failed to establish federated identity credential between the [$applicationName] AAD application and the [$serviceAccountName] service account issuer & subject"
  fi
fi

# Delete any existing body.json from the current folder
if [[ -f body.json ]]; then
  rm body.json
fi