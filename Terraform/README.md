## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.flask-appgw](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/application_gateway) | resource |
| [azurerm_application_insights.flask-app-insights](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/application_insights) | resource |
| [azurerm_linux_web_app.web_app](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/linux_web_app) | resource |
| [azurerm_log_analytics_workspace.flask-app-log-ws](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/log_analytics_workspace) | resource |
| [azurerm_public_ip.flaskapp-appgw-pip](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/public_ip) | resource |
| [azurerm_resource_group.flask-app-italynorth-rg](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/resource_group) | resource |
| [azurerm_service_plan.app_service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/service_plan) | resource |
| [azurerm_subnet.default](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/subnet) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/subnet) | resource |
| [azurerm_virtual_network.appgw-vnet](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/resources/virtual_network) | resource |
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/4.9.0/docs/data-sources/container_registry) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr"></a> [acr](#input\_acr) | Azure Container Registry details | `map(string)` | n/a | yes |
| <a name="input_acr_image"></a> [acr\_image](#input\_acr\_image) | Container Image Name | `string` | n/a | yes |
| <a name="input_app_gateway_details"></a> [app\_gateway\_details](#input\_app\_gateway\_details) | Application Gateway Name | `map(any)` | n/a | yes |
| <a name="input_app_service_plan_kind"></a> [app\_service\_plan\_kind](#input\_app\_service\_plan\_kind) | App Service Plan Kind | `string` | n/a | yes |
| <a name="input_app_service_plan_name"></a> [app\_service\_plan\_name](#input\_app\_service\_plan\_name) | App Service Plan Name | `string` | n/a | yes |
| <a name="input_app_service_plan_sku_name"></a> [app\_service\_plan\_sku\_name](#input\_app\_service\_plan\_sku\_name) | App Service Plan SKU Name | `string` | n/a | yes |
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | Application Type | `string` | n/a | yes |
| <a name="input_docker_image_tag"></a> [docker\_image\_tag](#input\_docker\_image\_tag) | n/a | `string` | n/a | yes |
| <a name="input_flask-app-log-ws"></a> [flask-app-log-ws](#input\_flask-app-log-ws) | Log Analytics Workspace | `map(any)` | n/a | yes |
| <a name="input_flask_app_rg_name"></a> [flask\_app\_rg\_name](#input\_flask\_app\_rg\_name) | Resource Group Name | `string` | n/a | yes |
| <a name="input_flask_app_rg_name_location"></a> [flask\_app\_rg\_name\_location](#input\_flask\_app\_rg\_name\_location) | Resource Group Location | `string` | n/a | yes |
| <a name="input_flaskapp-appgw-pip-name"></a> [flaskapp-appgw-pip-name](#input\_flaskapp-appgw-pip-name) | Application Gateway Public IP Name | `string` | n/a | yes |
| <a name="input_vnet_details"></a> [vnet\_details](#input\_vnet\_details) | Application Gateway Virtual Network Name | `map(any)` | n/a | yes |
| <a name="input_web_app_name"></a> [web\_app\_name](#input\_web\_app\_name) | Web App Name | `string` | n/a | yes |

## Outputs

No outputs.
