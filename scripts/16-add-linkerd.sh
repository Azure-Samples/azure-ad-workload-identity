#!/bin/bash

# Variables
namespace="todolist"
frontendDeployment="todolist-web"
backendDeployment="todolist-api"

# The commands below retrieve a deployment from the AKS cluster by name, run the a Linkerd command to inject data plane
# transparent proxies as containers in their pods, and finally reapplies it to the cluster. The inject command augments the 
# resources to include the data plane’s proxies. As with install, inject is a pure text operation, meaning that you can 
# inspect the input and output before you use it. Once piped into kubectl apply, Kubernetes will execute a rolling 
# deploy and update each pod with the data plane’s proxies, all without any downtime.

kubectl get deployment $frontendDeployment -n $namespace -o yaml | linkerd inject - | kubectl apply -f -
kubectl get deployment $backendDeployment -n $namespace -o yaml | linkerd inject - | kubectl apply -f -