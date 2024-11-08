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
