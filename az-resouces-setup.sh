#!/usr/bin/env bash

# ========================
# CONFIGURATION
# ========================
set -euo pipefail
IFS=$'\n\t'

# Resource details
RG1_NAME="flask-app-acr-eastus-rg"
RG1_LOCATION="eastus"
ACR_NAME="azappsvcreg"

RG2_NAME="flask-app-tf-italynorth-rg"
RG2_LOCATION="italynorth"
STORAGE_NAME="terraformitalynorth"
CONTAINER_NAME="terraformstate"

# ========================
# HELPER FUNCTIONS
# ========================

log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; exit 1; }

check_command() {
    if ! command -v "$1" &>/dev/null; then
        log_error "Command '$1' not found. Please install it before running this script."
    fi
}

verify_login() {
    if ! az account show &>/dev/null; then
        log_warn "Not logged into Azure CLI. Logging in..."
        az login || log_error "Azure login failed."
    fi
}

create_resource_group() {
    local name="$1"
    local location="$2"
    if az group exists --name "$name" | grep -q true; then
        log_info "Resource Group '$name' already exists. Skipping creation."
    else
        log_info "Creating Resource Group '$name' in location '$location'..."
        az group create --name "$name" --location "$location" >/dev/null
        log_info "Resource Group '$name' created."
    fi
}

create_acr() {
    local rg="$1"
    local name="$2"
    if az acr show --name "$name" --resource-group "$rg" &>/dev/null; then
        log_info "ACR '$name' already exists. Skipping creation."
    else
        log_info "Creating ACR '$name'..."
        az acr create --resource-group "$rg" --name "$name" --sku Basic >/dev/null
        log_info "ACR '$name' created."
    fi
    log_info "Enabling admin access for ACR '$name'..."
    az acr update -n "$name" --admin-enabled true >/dev/null
    log_info "Admin access enabled."
}

create_storage_account() {
    local rg="$1"
    local name="$2"
    local location="$3"
    if az storage account show --name "$name" --resource-group "$rg" &>/dev/null; then
        log_info "Storage account '$name' already exists. Skipping creation."
    else
        log_info "Creating storage account '$name'..."
        az storage account create \
            --name "$name" \
            --resource-group "$rg" \
            --location "$location" \
            --sku Standard_LRS \
            --kind StorageV2 \
            --min-tls-version TLS1_2 \
            --allow-blob-public-access true >/dev/null
        log_info "Storage account '$name' created."
    fi

    log_info "Enabling blob versioning for '$name'..."
    az storage account blob-service-properties update \
        --resource-group "$rg" \
        --account-name "$name" \
        --enable-versioning true >/dev/null
}

create_storage_container() {
    local account="$1"
    local container="$2"
    if az storage container show --account-name "$account" --name "$container" --auth-mode login &>/dev/null; then
        log_info "Storage container '$container' already exists. Skipping creation."
    else
        log_info "Creating storage container '$container'..."
        az storage container create \
            --account-name "$account" \
            --name "$container" \
            --auth-mode login >/dev/null
        log_info "Storage container '$container' created."
    fi
}

# ========================
# SCRIPT EXECUTION
# ========================

log_info "Starting Azure resource setup..."

check_command az
verify_login

create_resource_group "$RG1_NAME" "$RG1_LOCATION"
create_acr "$RG1_NAME" "$ACR_NAME"

create_resource_group "$RG2_NAME" "$RG2_LOCATION"
create_storage_account "$RG2_NAME" "$STORAGE_NAME" "$RG2_LOCATION"
create_storage_container "$STORAGE_NAME" "$CONTAINER_NAME"

log_info "All resources created or verified successfully."
