#!/bin/bash
resource=`az group list --query '[0].name' --output tsv`

echo "Creating VM Scale Set in $resource..."
az vmss create --name myScaleSet --image UbuntuLTS --upgrade-policy-mode automatic --admin-username azureuser --generate-ssh-keys --resource-group $resource

echo "Setting up webservers..."
az vmss extension set --publisher Microsoft.Azure.Extensions --version 2.0 --name CustomScript  --vmss-name myScaleSet --settings '{"fileUris":["https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate_nginx.sh"],"commandToExecute":"./automate_nginx.sh"}' --resource-group $resource

echo "Opening port 80 for web traffic..."
az network lb rule create --name myLoadBalancerRuleWeb --lb-name myScaleSetLB --backend-pool-name myScaleSetLBBEPool --backend-port 443 --frontend-ip-name loadBalancerFrontEnd --frontend-port 80 --protocol tcp --resource-group $resource

printf "***********************  Webserver Pool Created  *********************\n\n"
