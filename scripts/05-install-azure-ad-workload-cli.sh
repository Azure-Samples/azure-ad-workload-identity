#!/bin/bash

# For more information, see https://azure.github.io/azure-workload-identity/docs/installation/azwi.html

# Install Azure AD Workload CLI (azwi)
# azwi is a utility CLI that helps manage Azure AD Workload Identity and automate error-prone operations:
# - Generates the JWKS document from a list of public keys
# - Streamlines the creation and deletion of the following resources:
#   - AAD applications
#   - Kubernetes service accounts
#   - Federated identities
#   - Azure role assignments
brew install Azure/azure-workload-identity/azwi