#!/bin/bash
set -e

# Default to latest version if not specified
HELM_VERSION=${1:-latest}

# Check if Weaviate Helm repository exists, add it if not
echo "Checking Weaviate Helm repository..."
if ! helm repo list | grep -q "weaviate"; then
  echo "Adding Weaviate Helm repository..."
  helm repo add weaviate https://weaviate.github.io/weaviate-helm/
else
  echo "Weaviate Helm repository already exists."
fi

# Update Helm repositories
echo "Updating Helm repositories..."
helm repo update

# Get latest version if requested
if [ "$HELM_VERSION" = "latest" ]; then
  HELM_VERSION=$(helm search repo weaviate/weaviate -o json | jq -r '.[0].version')
  echo "Using latest Helm chart version: $HELM_VERSION"
fi

# Remove existing chart
echo "Removing existing Helm chart..."
rm -rf helm-charts/weaviate

# Pull the chart
echo "Pulling Weaviate Helm chart version $HELM_VERSION..."
mkdir -p helm-charts
helm pull weaviate/weaviate --version $HELM_VERSION --untar --untardir helm-charts

echo "Successfully updated Weaviate Helm chart to version $HELM_VERSION"
echo "You can now build the operator with: make generate-operator-yaml" 