# technologyconsulting-showcase-az_api-gateway
Beware: this repo only is useful for showcase purpose. 
The GH Action (`.github\workflows\createInfrastructureFromGitHub.yaml`) will create a platform for API-Gateway evalutaion based on TF in the AZ Cloud 

TF create the following through azurerm provider:
- RSG 
- keyvault
- storageaccount
- tbd 

You can execute this on your local device by calling `createInfrastructureFromLocal.sh`. You have to installed the AZ cli and logged in.  
APGW is very slow:

https://feedback.azure.com/forums/281804-azure-resource-manager/suggestions/19119910-application-gateway-management-operations-are-agon?page=6&per_page=20 