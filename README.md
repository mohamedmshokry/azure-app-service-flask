# Azure App Service Flask
Deployment trial for sample Flask app on Azure App Service using Terraform and Azure DevOps


# Flask App deployment
The sample Flask app is Dockerized using the `Dockerfile` in the repo with security in mind and also the image size.

## TL;DR
This repo contains:
- Terraform files needed to provision Azure Web app for container and Application Gateway with all requiered other resouces
- Azure pipeline yaml file that automates the image build and container deployment to the web app upon changes on code or Dockerfile only

To get the sample Flask app deployed to Azure web app for containers
```bash
az group create --name azure-app-service-flask --location eastus
az acr create --resource-group azure-app-service-flask --name azappsvcreg --sku Basic
az acr update -n azappsvcreg --admin-enabled true
az group create --name pwcTask-italynorth-rg --location italynorth
az storage account create \
    --name terraformitalynorth \
    --resource-group pwcTask-italynorth-rg \
    --location italynorth \
    --sku Standard_LRS \
    --kind StorageV2 \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access true 
az storage account blob-service-properties update \
    --resource-group pwcTask-italynorth-rg \
    --account-name terraformitalynorth \
    --enable-versioning true
az storage container create \
    --account-name terraformitalynorth \
    --name terraformstate \
    --auth-mode login
#Fork the rpeo using GUI and clone your forked one
git clone https://github.com/mohamedmshokry/azure-app-service-flask.git
cd azure-app-service-flask/Terraform
cat << EOF | tee terraform.tfvars
flask_app_rg_name          = "flask-app-italynorth-rg"
flask_app_rg_name_location = "Italy North"

flask-app-log-ws = {
  "name"              = "flask-app-log-ws"
  "sku"               = "PerGB2018"
  "retention_in_days" = 30
}

flask-app-environment-name = "flask-app-env"

application_type          = "web"
web_app_name              = "flask-app-container"
app_service_plan_name     = "flask-app-sp"
app_service_plan_kind     = "Linux"
app_service_plan_sku_name = "P0v3"

acr = {
  "name"                = "azappsvcreg"
  "resource_group_name" = "azure-app-service-flask"
}

acr_image        = "flaskapp"
docker_image_tag = "9"

vnet_details = {
  "name"                  = "appgw-italynorth-vnet"
  "address_space"         = "20.0.0.0/16"
  "vnet_subnet_01_name"   = "default"
  "vnet_subnet_01_prefix" = "20.0.1.0/24"
  "vnet_subnet_02_name"   = "private"
  "vnet_subnet_02_prefix" = "20.0.2.0/24"
}
flaskapp-appgw-pip-name = "flask-appgw-pip"

app_gateway_details = {
  "name"                      = "flaskapp-appgw"
  "gw_ip_config"              = "flask_app_gw_ip_config"
  "backend_http_path"         = "/products"
  "probe_name"                = "flask-app-be-probe"
  "probe_interval"            = "10"
  "probe_protocol"            = "Http"
  "probe_timeout"             = 30
  "probe_unhealthy_threshold" = 3
  "probe_port"                = 80
}
EOF
terraform init
terraform apply -auto-approve

# Create you Azure Pipeline organization and project then create empty pipeline
# Copy the content of "azure-pipelines.yml" to the newly created pipeline and authorize it for the subscription
# For the pipeline task "AzureWebAppContainer@1" choose the right application name and run the pipeline
```


## Long Story (Detailed Steps)
For the sample Flask app we have thee are multiple services that can use to host the application:
- Web App for Containers: This is the servive used for below steps
- Azure Container Apps (ACA)
- Azure Container Instances (ACI)
- Azure Kubernetes Service (AKS)
- Azure Functions

### 01- Create Azure Container Registry (ACR) amd Blob Container for terraform Backend
* Create ACR to host the app images
    ```bash
    az group create --name azure-app-service-flask --location eastus
    az acr create --resource-group azure-app-service-flask --name azappsvcreg --sku Basic
    ```
* Enable Admin account
    ```bash
    az acr update -n azappsvcreg --admin-enabled true
    ```
* Create Resource Group, Storage account and Blob container for Terraform backend
    ```bash
    az group create --name pwcTask-italynorth-rg --location italynorth
    az storage account create \
        --name terraformitalynorth \
        --resource-group pwcTask-italynorth-rg \
        --location italynorth \
        --sku Standard_LRS \
        --kind StorageV2 \
        --min-tls-version TLS1_2 \
        --allow-blob-public-access true 
    ```

    ```bash
    # Enabling Blob container versioning
    az storage account blob-service-properties update \
    --resource-group pwcTask-italynorth-rg \
    --account-name terraformitalynorth \
    --enable-versioning true
    ```

    ```bash
    # Create Blob container for Terraform state
    az storage container create \
    --account-name terraformitalynorth \
    --name terraformstate \
    --auth-mode login
    ```

### 02- Fork and clone the repo and provision Azure web app for container service and Application Gateway
You will need to fork to your github account and clone the repo to be able to  provision using terraform and control the repo from Azure DevOps
```bash
git clone https://github.com/mohamedmshokry/azure-app-service-flask.git
cd azure-app-service-flask/Terraform
```
You will need to create your own terraform.tfvars and fill the values with your desiered ones
```
flask_app_rg_name          = ""
flask_app_rg_name_location = ""

flask-app-log-ws = {
  "name"              = ""
  "sku"               = ""
  "retention_in_days" = 
}

flask-app-environment-name = ""

application_type          = ""
web_app_name              = ""
app_service_plan_name     = ""
app_service_plan_kind     = ""
app_service_plan_sku_name = ""

acr = {
  "name"                = ""
  "resource_group_name" = ""
}

acr_image        = ""
docker_image_tag = ""

vnet_details = {
  "name"                  = ""
  "address_space"         = ""
  "vnet_subnet_01_name"   = ""
  "vnet_subnet_01_prefix" = ""
  "vnet_subnet_02_name"   = ""
  "vnet_subnet_02_prefix" = "
}
flaskapp-appgw-pip-name = ""

app_gateway_details = {
  "name"                      = ""
  "gw_ip_config"              = ""
  "backend_http_path"         = ""
  "probe_name"                = ""
  "probe_interval"            = ""
  "probe_protocol"            = ""
  "probe_timeout"             = 
  "probe_unhealthy_threshold" = 
  "probe_port"                = 
}
```
```bash
terraform init
terraform plan
terraform apply
```

Details about the created app service:
- The App web app for container created is configuered to allow access only from default vnet subnet where Application gateway is provisioned
- There is a Log ***Analytics workspace*** and ***Application Insights*** created for the web app, instrumentation key and connection string are configuered for the application settings

### 03- Create Azure DevOps pipeline
- Assuming you have a free account on Azure you can create a new organization on https://dev.azure.com/
- Inside the organization create a new project for the flask app
- Inside the project we will utilize only the Pipelines feature, so Create a pipeline where code in the forked repo you did
- Make it an empty pipeline, the pipeline is provided in the "azure-pipelines.yml" in the repo
- What you will need to do is to authorize the pipline to use your subscription and select the created "Azure web app for container" resource to deploy the container on
- The pipeline is triggered only for application code and Docker file modifications

## To Do's
* Change ACR to premium plan and make Private Endpoint for the ACR instead of public access
* Create a Depoyment Slot for Stging and Deploy to teh staging instead of prod slot
* Add to the pipeline a "Load Testing resource" creation and configuration for limited time performance test to the flask API