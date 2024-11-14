#create the Virtual Network and Subnet
resource "azurerm_virtual_network" "appgw-vnet" {
  name                = var.vnet_details["name"]
  location            = azurerm_resource_group.flask-app-italynorth-rg.location
  resource_group_name = azurerm_resource_group.flask-app-italynorth-rg.name
  address_space       = [var.vnet_details["address_space"]]
}

# Create Subnets separately
resource "azurerm_subnet" "default" {
  name                 = var.vnet_details["vnet_subnet_01_name"]
  resource_group_name  = azurerm_resource_group.flask-app-italynorth-rg.name
  virtual_network_name = azurerm_virtual_network.appgw-vnet.name
  address_prefixes     = [var.vnet_details["vnet_subnet_01_prefix"]]
  service_endpoints    = ["Microsoft.Web"]
}

resource "azurerm_subnet" "private" {
  name                 = var.vnet_details["vnet_subnet_02_name"]
  resource_group_name  = azurerm_resource_group.flask-app-italynorth-rg.name
  virtual_network_name = azurerm_virtual_network.appgw-vnet.name
  address_prefixes     = [var.vnet_details["vnet_subnet_02_prefix"]]
}

#create the public ip address for APPGW Frontend
resource "azurerm_public_ip" "flaskapp-appgw-pip" {
  name                = var.flaskapp-appgw-pip-name
  resource_group_name = azurerm_resource_group.flask-app-italynorth-rg.name
  location            = azurerm_resource_group.flask-app-italynorth-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.appgw-vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.appgw-vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.appgw-vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.appgw-vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.appgw-vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.appgw-vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.appgw-vnet.name}-rdrcfg"
}

#create the app gw-02"
resource "azurerm_application_gateway" "flask-appgw" {
  name                = var.app_gateway_details["name"]
  resource_group_name = azurerm_resource_group.flask-app-italynorth-rg.name
  location            = azurerm_resource_group.flask-app-italynorth-rg.location

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
    # capacity = 2
  }

  autoscale_configuration {
    min_capacity = var.app_gateway_details["min_capacity"]
    max_capacity = var.app_gateway_details["max_capacity"]
  }

  gateway_ip_configuration {
    name      = var.app_gateway_details["gw_ip_config"]
    subnet_id = azurerm_subnet.default.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.flaskapp-appgw-pip.id
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = [azurerm_linux_web_app.web_app.default_hostname]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    # path                                = var.app_gateway_details["backend_http_path"]
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = var.app_gateway_details["probe_name"]
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  probe {
    name                                      = var.app_gateway_details["probe_name"]
    interval                                  = abs(var.app_gateway_details["probe_interval"])
    protocol                                  = var.app_gateway_details["probe_protocol"]
    path                                      = var.app_gateway_details["backend_http_path"]
    unhealthy_threshold                       = var.app_gateway_details["probe_unhealthy_threshold"]
    port                                      = var.app_gateway_details["probe_port"]
    timeout                                   = var.app_gateway_details["probe_timeout"]
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }
}