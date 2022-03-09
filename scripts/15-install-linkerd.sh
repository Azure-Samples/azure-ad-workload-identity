#!/bin/bash

# Install Linkerd. For more information, see:
# - https://linkerd.io/2/getting-started/
# - 

# Install Linkerd CLI:
curl -sL https://run.linkerd.io/install | sh

# Add linkerd to your path with:
export PATH=$PATH:$HOME/.linkerd2/bin

# Verify the CLI is installed and running correctly with:
linkerd version

# Check that your Kubernetes cluster is configured correctly and ready to install the control plane, you can run:
linkerd check --pre

# Install Linkerd lightweight control plane into its own namespace (linkerd).
linkerd install | kubectl apply -f -

# Validate installation
linkerd check

# Wait for installation to complete
kubectl -n linkerd get deploy

# With the control plane installed and running, you can now view the Linkerd dashboard by running:
linkerd viz dashboard &