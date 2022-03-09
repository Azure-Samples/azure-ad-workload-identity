#!/bin/bash

# Variables
name="todolist-api"
namespace="ox"
domain="oxapi.babosbird.com"
url="http://$domain/swagger/v1/swagger.json"

# The following command does three things:
# 1. Fetch the swagger specification for webapp.
# 2. Take the spec and convert it into a service profile by using the profile command.
# 3. Apply this configuration to the cluster.
# You can edit the service profile with the following command:
# kubectl -n default edit sp/voting-data.voting-linkerd.svc.cluster.local
echo "Invoking $url to retrieve OpenAPI service profile..."
curl -sL $url | linkerd -n $namespace profile --open-api - $name | kubectl -n $namespace apply -f -

# Display the service profile in YAML format
kubectl get serviceprofile.linkerd.io/$name.$namespace.svc.cluster.local -n $namespace -o yaml

# See routes
linkerd viz routes -n $namespace svc/$name  