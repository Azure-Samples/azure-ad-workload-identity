#!/bin/bash

# variables
namespace="ingress-basic"
deployTemplate="default-backend.yml"

# check if the namespace exists in the cluster
result=$(kubectl get namespace -o 'jsonpath={.items[?(@.metadata.name=="'$namespace'")].metadata.name'})

if [[ -n $result ]]; then
    echo "$namespace namespace already exists in the cluster"
else
    echo "$namespace namespace does not exist in the cluster"
    echo "creating $namespace namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Install application
kubectl apply -f $deployTemplate -n $namespace