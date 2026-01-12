#!/bin/bash
# Bash deployment script for AI Bingo Game
# This script deploys the infrastructure and website to Azure

set -e

ACTION="${1:-deploy}"
SKIP_TERRAFORM=false
DESTROY_INFRA=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-terraform)
            SKIP_TERRAFORM=true
            shift
            ;;
        --destroy)
            DESTROY_INFRA=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo "====================================="
echo "AI Bingo Game Deployment Script"
echo "====================================="
echo ""

# Check if Azure CLI is installed
echo "Checking prerequisites..."
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version --output json | jq -r '."azure-cli"')
    echo "✓ Azure CLI installed (version $AZ_VERSION)"
else
    echo "✗ Azure CLI not found. Please install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if Terraform is installed
if [ "$SKIP_TERRAFORM" = false ]; then
    if command -v terraform &> /dev/null; then
        TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
        echo "✓ Terraform installed (version $TF_VERSION)"
    else
        echo "✗ Terraform not found. Please install from: https://www.terraform.io/downloads"
        exit 1
    fi
fi

# Check Azure login
echo ""
echo "Checking Azure login status..."
if az account show &> /dev/null; then
    ACCOUNT_NAME=$(az account show --query "name" -o tsv)
    ACCOUNT_USER=$(az account show --query "user.name" -o tsv)
    echo "✓ Logged in to Azure as: $ACCOUNT_USER"
    echo "  Subscription: $ACCOUNT_NAME"
else
    echo "Not logged in to Azure. Logging in..."
    az login
fi

# Handle destroy action
if [ "$DESTROY_INFRA" = true ]; then
    echo ""
    echo "WARNING: This will destroy all Azure resources!"
    read -p "Type 'yes' to confirm destruction: " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Destruction cancelled."
        exit 0
    fi

    cd terraform
    terraform destroy -auto-approve
    cd ..
    echo "✓ Resources destroyed"
    exit 0
fi

# Deploy infrastructure with Terraform
if [ "$SKIP_TERRAFORM" = false ]; then
    echo ""
    echo "Deploying infrastructure with Terraform..."
    cd terraform

    echo "  Initializing Terraform..."
    terraform init

    echo "  Planning infrastructure..."
    terraform plan -out=tfplan

    echo "  Applying infrastructure..."
    terraform apply tfplan

    echo "✓ Infrastructure deployed"

    # Get outputs
    STORAGE_ACCOUNT_NAME=$(terraform output -raw storage_account_name)
    WEBSITE_URL=$(terraform output -raw website_url)
    RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name)

    cd ..
else
    echo ""
    echo "Skipping Terraform (using existing infrastructure)..."

    # Try to get existing values from Terraform state
    cd terraform
    STORAGE_ACCOUNT_NAME=$(terraform output -raw storage_account_name 2>/dev/null || echo "")
    WEBSITE_URL=$(terraform output -raw website_url 2>/dev/null || echo "")
    RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name 2>/dev/null || echo "")
    cd ..

    if [ -z "$STORAGE_ACCOUNT_NAME" ]; then
        echo "✗ Could not find existing infrastructure. Run without --skip-terraform first."
        exit 1
    fi
fi

# Prepare website files
echo ""
echo "Preparing website files..."
DEPLOY_DIR="deploy"
if [ -d "$DEPLOY_DIR" ]; then
    rm -rf "$DEPLOY_DIR"
fi
mkdir -p "$DEPLOY_DIR"

# Copy bingo.html as index.html
cp bingo.html "$DEPLOY_DIR/index.html"
# Copy logo image
cp whey-ai-man-banner-middle.png "$DEPLOY_DIR/"
echo "✓ Website files prepared"

# Deploy website to Azure Storage
echo ""
echo "Deploying website to Azure Storage Account..."

# Get storage account key
echo "  Getting storage account key..."
STORAGE_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --query '[0].value' \
    --output tsv)

# Upload HTML files
echo "  Uploading HTML files..."
az storage blob upload-batch \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --account-key "$STORAGE_KEY" \
    --source "$DEPLOY_DIR" \
    --destination '$web' \
    --pattern "*.html" \
    --content-type 'text/html' \
    --overwrite

# Upload PNG files
echo "  Uploading image files..."
az storage blob upload-batch \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --account-key "$STORAGE_KEY" \
    --source "$DEPLOY_DIR" \
    --destination '$web' \
    --pattern "*.png" \
    --content-type 'image/png' \
    --overwrite

echo "✓ Files uploaded to storage account"

echo ""
echo "====================================="
echo "Deployment Complete!"
echo "====================================="
echo ""
echo "Your AI Bingo Game is now live at:"
echo "  $WEBSITE_URL"
echo ""
echo "Share this URL with your meeting participants!"
echo ""
echo "Resource Details:"
echo "  Resource Group: $RESOURCE_GROUP_NAME"
echo "  Storage Account: $STORAGE_ACCOUNT_NAME"
echo ""
