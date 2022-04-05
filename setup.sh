#!/bin/bash
resource=`az group list --query '[0].name' --output tsv`

az network public-ip create \
    --resource-group $resource \
    --name webPublicIP

az network lb create \
    --resource-group $resource \
    --name webLoadBalancer \
    --frontend-ip-name webFrontEndPool \
    --backend-pool-name webBackEndPool \
    --public-ip-address webPublicIP

az network lb probe create \
    --resource-group $resource \
    --lb-name webLoadBalancer \
    --name webHealthProbe \
    --protocol tcp \
    --port 80

az network lb rule create \
    --resource-group $resource \
    --lb-name webLoadBalancer \
    --name webLoadBalancerRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 443 \
    --frontend-ip-name webFrontEndPool \
    --backend-pool-name webBackEndPool \
    --probe-name webHealthProbe

az network vnet create \
    --resource-group $resource \
    --name webVnet \
    --subnet-name webSubnet

az network nsg create \
    --resource-group $resource \
    --name webNetworkSecurityGroup

az network nsg rule create \
    --resource-group $resource \
    --nsg-name webNetworkSecurityGroup \
    --name webNetworkSecurityGroupRule \
    --priority 1001 \
    --protocol tcp \
    --destination-port-range 80

az network nic create \
    --resource-group $resource \
    --name webNic1 \
    --vnet-name webVnet \
    --subnet webSubnet \
    --network-security-group webNetworkSecurityGroup \
    --lb-name webLoadBalancer \
    --lb-address-pools webBackEndPool

az network nic create \
    --resource-group $resource \
    --name webNic2 \
    --vnet-name webVnet \
    --subnet webSubnet \
    --network-security-group webNetworkSecurityGroup \
    --lb-name webLoadBalancer \
    --lb-address-pools webBackEndPool

az vm availability-set create \
    --resource-group $resource \
    --name webAvailabilitySet \
    --platform-fault-domain-count 2 \
    --platform-update-domain-count 2

az vm create \
    --resource-group $resource \
    --name webVirtualMachine1 \
    --availability-set webAvailabilitySet \
    --nics webNic1 \
    --image UbuntuLTS \
    --admin-username azureuser \
    --generate-ssh-keys \
    --custom-data cloud-init.txt \
    --no-wait

az vm create \
    --resource-group $resource \
    --name webVirtualMachine2 \
    --availability-set webAvailabilitySet \
    --nics webNic2 \
    --image UbuntuLTS \
    --admin-username azureuser \
    --generate-ssh-keys \
    --custom-data cloud-init.txt \
    --no-wait

printf "***********************  Webserver Pool Created  *********************\n\n"
