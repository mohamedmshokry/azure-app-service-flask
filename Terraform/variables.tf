variable "flask_app_rg_name" {
  type        = string
  description = "Resource Group Name"
}

variable "flask_app_rg_name_location" {
  type        = string
  description = "Resource Group Location"
}

variable "application_type" {
  type        = string
  description = "Application Type"
}

variable "flask-app-log-ws" {
  type        = map(any)
  description = "Log Analytics Workspace"
}

variable "flask-app-environment-name" {
  type        = string
  description = "Environment Name"
}

variable "web_app_name" {
  type        = string
  description = "Web App Name"
}

variable "app_service_plan_name" {
  type        = string
  description = "App Service Plan Name"
}

variable "app_service_plan_kind" {
  type        = string
  description = "App Service Plan Kind"
}

variable "app_service_plan_sku_name" {
  type        = string
  description = "App Service Plan SKU Name"
}

variable "acr" {
  type        = map(string)
  description = "Azure Container Registry details"
}

variable "acr_image" {
  type        = string
  description = "Container Image Name"
}

variable "docker_image_tag" {
  type = string
}

#
## Azure Application Gateway
#
variable "vnet_details" {
  type        = map(any)
  description = "Application Gateway Virtual Network Name"
}

variable "flaskapp-appgw-pip-name" {
  type        = string
  description = "Application Gateway Public IP Name"
}

variable "app_gateway_details" {
  type        = map(any)
  description = "Application Gateway Name"
}