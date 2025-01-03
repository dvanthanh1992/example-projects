#!/bin/bash

# Function to authenticate and retrieve token
authenticate_vcd_account() {
  local url_provider="..."
  local client_username="..."
  local client_api_token="..."

  # Extract organization name from username
  local org_name=$(echo "$client_username" | cut -d'@' -f2)
  local url="$url_provider/oauth/tenant/$org_name/token"

  # Send authentication request
  local response=$(curl -s -X POST "$url" \
    -H "Accept: application/json" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "grant_type=refresh_token" \
    --data-urlencode "refresh_token=$client_api_token")

  # Parse and return the access token
  echo "$response" | jq -r .access_token
}

# Function to update firewall group
update_firewall_group() {
  local token=$1
  shift
  local ip_addresses=$(printf '"%s",' "$@")
  ip_addresses=${ip_addresses%,} # Remove trailing comma

  # Define static parameters
  local ORG_REF_NAME="ASG999003-SEC-JP"
  local ORG_REF_ID="urn:vcloud:org:0f71c67e-113e-47c3-8e60-b848676f5b9e"
  local EDGE_GATEWAY_REF_NAME="VPC02-ASG999003-SEC-JP-K8S"
  local EDGE_GATEWAY_REF_ID="urn:vcloud:gateway:5e593a02-ba02-46ad-ac3a-8d0278d13472"
  local FIREWALL_GROUP_ID="urn:vcloud:firewallGroup:9c81c42b-18b8-4cc2-9e7b-2c2ef0911bfc"
  local FIREWALL_GROUP_NAME="Azure Public"
  local BASE_URL="https://iaas-hcmc02.higiocloud.vn/cloudapi/1.0.0/firewallGroups"

  # Create JSON payload
  local json_payload=$(cat <<EOF
{
  "orgRef": {
    "name": "$ORG_REF_NAME",
    "id": "$ORG_REF_ID"
  },
  "edgeGatewayRef": {
    "name": "$EDGE_GATEWAY_REF_NAME",
    "id": "$EDGE_GATEWAY_REF_ID"
  },
  "ownerRef": {
    "name": "$EDGE_GATEWAY_REF_NAME",
    "id": "$EDGE_GATEWAY_REF_ID"
  },
  "networkProviderScope": "hcm10nsxmgrlb001",
  "status": "REALIZED",
  "id": "$FIREWALL_GROUP_ID",
  "name": "$FIREWALL_GROUP_NAME",
  "description": "",
  "type": "IP_SET",
  "typeValue": "IP_SET",
  "ipAddresses": [$ip_addresses],
  "members": null
}
EOF
)

  # Send PUT request
  curl -X PUT \
    "$BASE_URL/$FIREWALL_GROUP_ID" \
    -H "Accept: application/json;version=39.0.0-alpha" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    --data-raw "$json_payload"
}

# Main script
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <ip1> [ip2] [ip3] ..."
  exit 1
fi

# Authenticate and get token
token=$(authenticate_vcd_account)

if [ -z "$token" ] || [ "$token" == "null" ]; then
  echo "Failed to authenticate and retrieve token."
  exit 1
fi

# Update firewall group
update_firewall_group "$token" "$@"
