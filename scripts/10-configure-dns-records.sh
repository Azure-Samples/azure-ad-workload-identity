
# Variables
namespace="ingress-basic"
releaseName="nginx-ingress"
dnsZoneName="<your-public-dns-zone-name>"
dnsZoneResourceGroupName="<your-public-dns-zone-resouce-group-name>"
frontendSubdomain="todo"
backendSubdomain="todoapi"

# Install jq if not installed
path=$(which jq)

if [[ -z $path ]]; then
    echo 'Installing jq...'
    apt install -y jq
fi

# Retrieve the public IP address of the NGINX ingress controller
echo "Retrieving the external IP address of the [$releaseName] NGINX ingress controller..."
publicIpAddress=$(kubectl get service -o json -n $namespace |
    jq -r '.items[] | 
    select(.spec.type == "LoadBalancer" and .metadata.name == "'$releaseName'-ingress-nginx-controller") |
    .status.loadBalancer.ingress[0].ip')

if [ -n $publicIpAddress ]; then
    echo "[$publicIpAddress] external IP address of the [$releaseName] NGINX ingress controller successfully retrieved"
else
    echo "Failed to retrieve the external IP address of the [$releaseName] NGINX ingress controller"
    exit
fi

# Check if an A record for the frontend subdomain exists in the DNS Zone
echo "Retrieving the A record for the [$frontendSubdomain] subdomain from the [$dnsZoneName] DNS zone..."
ipv4Address=$(az network dns record-set a list \
    --zone-name $dnsZoneName \
    --resource-group $dnsZoneResourceGroupName \
    --query "[?name=='$frontendSubdomain'].arecords[].ipv4Address" \
    --output tsv)

if [[ -n $ipv4Address ]]; then
    echo "An A record already exists in [$dnsZoneName] DNS zone for the [$frontendSubdomain] subdomain with [$ipv4Address] IP address"
else
    echo "Creating an A record in [$dnsZoneName] DNS zone for the [$frontendSubdomain] subdomain with [$publicIpAddress] IP address..."
    az network dns record-set a add-record \
    --zone-name $dnsZoneName \
    --resource-group $dnsZoneResourceGroupName \
    --record-set-name $frontendSubdomain \
    --ipv4-address $publicIpAddress 1>/dev/null

    if [[ $? == 0 ]]; then
        echo "A record for the [$frontendSubdomain] subdomain with [$publicIpAddress] IP address successfully created in [$dnsZoneName] DNS zone"
    else
        echo "Failed to create an A record for the $frontendSubdomain subdomain with [$publicIpAddress] IP address in [$dnsZoneName] DNS zone"
    fi
fi

# Check if an A record for the backend subdomain exists in the DNS Zone
echo "Retrieving the A record for the [$backendSubdomain] subdomain from the [$dnsZoneName] DNS zone..."
ipv4Address=$(az network dns record-set a list \
    --zone-name $dnsZoneName \
    --resource-group $dnsZoneResourceGroupName \
    --query "[?name=='$backendSubdomain'].arecords[].ipv4Address" \
    --output tsv)

if [[ -n $ipv4Address ]]; then
    echo "An A record already exists in [$dnsZoneName] DNS zone for the [$backendSubdomain] subdomain with [$ipv4Address] IP address"
else
    echo "Creating an A record in [$dnsZoneName] DNS zone for the [$backendSubdomain] subdomain with [$publicIpAddress] IP address..."
    az network dns record-set a add-record \
    --zone-name $dnsZoneName \
    --resource-group $dnsZoneResourceGroupName \
    --record-set-name $backendSubdomain \
    --ipv4-address $publicIpAddress 1>/dev/null

    if [[ $? == 0 ]]; then
        echo "A record for the [$backendSubdomain] subdomain with [$publicIpAddress] IP address successfully created in [$dnsZoneName] DNS zone"
    else
        echo "Failed to create an A record for the $backendSubdomain subdomain with [$publicIpAddress] IP address in [$dnsZoneName] DNS zone"
    fi
fi