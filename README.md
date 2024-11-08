# Azure App Service Flask
Deployment trial for sample Flask app on Azure App Service using Terraform and Azure DevOps


# Flask App deployment
The sample Flask app is Dockerized using the `Dockerfile` in the repo with security in mind and also the image size.

## TL;DR
There are two Azure DevOps pipelines:
* One that is triggered upon a change in Dockerfile or application files to build a push a new image to ACR
* One pipeline that provision Azure App Service and Application gateway
* Another Pipeline to deploy latest image to Azure App Service


## Long Story (Detailed Steps)
* Create ACR to host the app images
    ```bash
    az group create --name azure-app-service-flask --location eastus
    az acr create --resource-group azure-app-service-flask --name azappsvcreg --sku Basic
    ```
* Enable Admin account
    ```bash
    az acr update -n azappsvcreg --admin-enabled true
    ```


## To Do's
* Change ACR to premium plan and make Private Endpoint for the ACR instead of public access