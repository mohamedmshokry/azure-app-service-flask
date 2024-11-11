resource "azurerm_resource_group" "flask-app-italynorth-rg" {
  name     = var.flask_app_rg_name
  location = var.flask_app_rg_name_location
}

# Create Application Insights
resource "azurerm_log_analytics_workspace" "flask-app-log-ws" {
  name                = var.flask-app-log-ws["name"]
  location            = azurerm_resource_group.flask-app-italynorth-rg.location
  resource_group_name = azurerm_resource_group.flask-app-italynorth-rg.name
  sku                 = var.flask-app-log-ws["sku"]
  retention_in_days   = var.flask-app-log-ws["retention_in_days"]
}

resource "azurerm_application_insights" "flask-app-insights" {
  name                = "${var.web_app_name}-insights"
  location            = azurerm_resource_group.flask-app-italynorth-rg.location
  resource_group_name = azurerm_resource_group.flask-app-italynorth-rg.name
  workspace_id        = azurerm_log_analytics_workspace.flask-app-log-ws.id
  application_type    = var.application_type
}


# Create App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                   = "${var.web_app_name}-asp"
  location               = var.flask_app_rg_name_location
  resource_group_name    = azurerm_resource_group.flask-app-italynorth-rg.name
  os_type                = var.app_service_plan_kind
  sku_name               = var.app_service_plan_sku_name
  zone_balancing_enabled = true
}


# Get ACR Information
data "azurerm_container_registry" "acr" {
  name                = var.acr["name"]
  resource_group_name = var.acr["resource_group_name"]
}

# Create Web App for Container with Managed Identity
resource "azurerm_linux_web_app" "web_app" {
  name                = var.web_app_name
  location            = azurerm_resource_group.flask-app-italynorth-rg.location
  resource_group_name = azurerm_resource_group.flask-app-italynorth-rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      docker_image_name        = "${var.acr_image}:${var.docker_image_tag}"
      docker_registry_url      = "https://${data.azurerm_container_registry.acr.login_server}"
      docker_registry_username = data.azurerm_container_registry.acr.admin_username
      docker_registry_password = data.azurerm_container_registry.acr.admin_password
    }
    ip_restriction_default_action = "Deny"
    # TODO: Need to use for_each for multiple ip_restrictions
    ip_restriction {
      action                    = "Allow"
      name                      = "allow_only_from_appgw"
      priority                  = 100
      virtual_network_subnet_id = azurerm_subnet.default.id
    }
    health_check_path                 = "/products"
    health_check_eviction_time_in_min = 10
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.flask-app-insights.instrumentation_key
    #   "APPINSIGHTS_PROFILERFEATURE_VERSION" = "1.0.0"
    #   "APPINSIGHTS_SNAPSHOTFEATURE_VERSION" = "1.0.0"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.flask-app-insights.connection_string
    #   "ApplicationInsightsAgent_EXTENSION_VERSION" = ""
    #   "DiagnosticServices_EXTENSION_VERSION" = ""
    #   "InstrumentationEngine_EXTENSION_VERSION" = "" 
    #   "SnapshotDebugger_EXTENSION_VERSION" = ""
    #   "XDT_MicrosoftApplicationInsights_BaseExtensions" = ""
    #   "XDT_MicrosoftApplicationInsights_Mode" = ""
  }
}
