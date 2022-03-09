#!/bin/bash

# Variables
acrName="<acr-name>"
acrResourceGroug="<acr-resource-group>"
frontendContainerImageTag="<frontend-container-image-tag>"
backendContainerImageTag="<backend-container-image-tag>"

# Login to ACR
az acr login --name $acrName 

# Retrieve ACR login server. Each container image needs to be tagged with the loginServer name of the registry. 
loginServer=$(az acr show --name $acrName --query loginServer --output tsv)

# Tag the local todoapi image with the loginServer of ACR
docker tag todoapi:$backendContainerImageTag $loginServer/todoapi:$backendContainerImageTag

# Push todoapi container image to ACR
docker push $loginServer/todoapi:$backendContainerImageTag

# Tag the local todoweb image with the loginServer of ACR
docker tag todoweb:$frontendContainerImageTag $loginServer/todoweb:$frontendContainerImageTag

# Push todoweb container image to ACR
docker push $loginServer/todoweb:$frontendContainerImageTag