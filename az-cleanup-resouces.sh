#!/usr/bin/env bash

# ========================
# CONFIGURATION
# ========================
set -euo pipefail
IFS=$'\n\t'

# Resource details (must match creation script)
RG1_NAME="flask-app-acr-eastus-rg"
ACR_NAME="azappsvcreg"

RG2_NAME="flask-app-tf-italynorth-rg"
STORAGE_NAME="terraformitalynorth"
CONTAINER_NAME="terraformstate"

FORCE_DELETE=${FORCE_DELETE:-false}  # Set FORCE_DELETE=true to skip confirmation

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

confirm_delete() {
    local resource="$1"
    if [ "$FORCE_DELETE" = true ]; then
        return
    fi
    read -r -p "Are you sure you want to delete $resource? (y/N): " choice
    case "$choice" in
        y|Y ) ;;
        * ) log_info "Skipping deletion of $resource."; return 1 ;;
    esac
}

delete_storage_container() {
    local account="$1"
    local container="$2"
    if az storage container show --account-name "$account" --name "$container" --auth-mode login &>/dev/null; then
        log_info "Deleting storage container '$container' from account '$account'..."
        confirm_delete "storage container $container" || return
        az storage container delete --account-name "$account" --name "$container" --auth-mode login >/dev/null
        log_info "Storage container '$container' deleted."
    else
        log_info "Storage container '$container' does not exist. Skipping."
    fi
}

delete_storage_account() {
    local rg="$1"
    local name="$2"
    if az storage account show --name "$name" --resource-group "$rg" &>/dev/null; then
        log_info "Deleting storage account '$name'..."
        confirm_delete "storage account $name" || return
        az storage account delete --name "$name" --resource-group "$rg" --yes >/dev/null
        log_info "Storage account '$name' deleted."
    else
        log_info "Storage account '$name' does not exist. Skipping."
    fi
}

delete_acr() {
    local rg="$1"
    local name="$2"
    if az acr show --name "$name" --resource-group "$rg" &>/dev/null; then
        log_info "Deleting ACR '$name'..."
        confirm_delete "ACR $name" || return
        az acr delete --name "$name" --resource-group "$rg" --yes >/dev/null
        log_info "ACR '$name' deleted."
    else
        log_info "ACR '$name' does not exist. Skipping."
    fi
}

delete_resource_group() {
    local name="$1"
    if az group exists --name "$name" | grep -q true; then
        log_info "Deleting Resource Group '$name'..."
        confirm_delete "resource group $name" || return
        az group delete --name "$name" --yes --no-wait >/dev/null
        log_info "Resource Group '$name' deletion initiated."
    else
        log_info "Resource Group '$name' does not exist. Skipping."
    fi
}

# ========================
# SCRIPT EXECUTION
# ========================

log_info "Starting Azure resource cleanup..."

check_command az
verify_login

# Delete container first to avoid locked storage account
delete_storage_container "$STORAGE_NAME" "$CONTAINER_NAME"
delete_storage_account "$RG2_NAME" "$STORAGE_NAME"
delete_resource_group "$RG2_NAME"

delete_acr "$RG1_NAME" "$ACR_NAME"
delete_resource_group "$RG1_NAME"

log_info "Cleanup script completed. Some deletions may still be running in background."
