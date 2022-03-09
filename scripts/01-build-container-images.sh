#!/bin/bash

#Variables
frontendContainerImageTag="<frontend-container-image-tag>"
backendContainerImageTag="<backend-container-image-tag>"

cd ../src/TodoApi
docker build -t todoapi:$frontendContainerImageTag -f Dockerfile ..
cd ../src/TodoWeb
docker build -t todoweb:$backendContainerImageTag -f Dockerfile ..