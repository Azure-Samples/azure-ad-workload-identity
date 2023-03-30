#!/bin/bash

# Variables
namespace="ingress-basic"
repoName="ingress-nginx"
repoUrl="https://kubernetes.github.io/ingress-nginx"
chartName="ingress-nginx"
releaseName="nginx-ingress"
replicaCount=2

# Install jq if not installed
path=$(which jq)

if [[ -z $path ]]; then
    echo 'Installing jq...'
    apt install -y jq
fi

# Check if the namespace already exists in the cluster
result=$(kubectl get namespace -o 'jsonpath={.items[?(@.metadata.name=="'$namespace'")].metadata.name'})

if [[ -n $result ]]; then
    echo "[$namespace] namespace already exists in the cluster"
else
    # Create the namespace for your ingress resources
    echo "[$namespace] namespace does not exist in the cluster"
    echo "Creating [$namespace] namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Check if the ingress-nginx repository is not already added
result=$(helm repo list | grep $repoName | awk '{print $1}')

if [[ -n $result ]]; then
    echo "[$repoName] Helm repo already exists"
else
    # Add the ingress-nginx repository
    echo "Adding [$repoName] Helm repo..."
    helm repo add $repoName $repoUrl
fi

# Use Helm to deploy an NGINX ingress controller
result=$(helm list -n $namespace | grep $releaseName | awk '{print $1}')

if [[ -n $result ]]; then
    echo "[$releaseName] ingress controller already exists in the [$namespace] namespace"
else
    # Deploy NGINX ingress controller
    echo "Deploying [$releaseName] NGINX ingress controller to the [$namespace] namespace..."
    helm install $releaseName $repoName/$chartName \
        --namespace $namespace \
        --set controller.replicaCount=$replicaCount \
        --set controller.nodeSelector."kubernetes\.io/os"=linux \
        --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
		--set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
fi