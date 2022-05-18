# Kafka Demo

Simple bicep module that will deploy multiple virtual machines with different name prefixes into one resource group.
The deployment location of the virtual machines will be the same as the resource group location.

## Deployment Instructions

Recommended to run in [Cloud Shell](https://shell.azure.com):

1. Clone git Repository and navigate to the 'kafkademo' folder

```bash
git clone https://github.com/daltondhcp/kafkademo.git
```

2. Edit 'main-parameters.json' to fit target environment.

3. Deploy the template with Azure CLI as below. Replace 'Subscription Name' and 'ResourceGroupName' with your own values.

```bash
# Switch to correct subscription context
az account set --subscription 'Subscription Name'

# Execute deployment
az deployment group create --name deployfordemo --resource-group ResourceGroupName --template-file main.bicep --parameters @main-parameters.json
```

4. Get detailed information on the vm properties exported to file named `machineDetails.json` with below command (paste directly into Cloud shell or run query in resource graph explorer)

```bash
az graph query -q "Resources | where type =~ 'microsoft.compute/virtualmachines'| project vmId = tolower(tostring(id)), vmName = name | join (Resources
        | where type =~ 'microsoft.network/networkinterfaces'
        | mv-expand ipconfig=properties.ipConfigurations
        | project vmId = tolower(tostring(properties.virtualMachine.id)), privateIp = ipconfig.properties.privateIPAddress, publicIpId = tostring(ipconfig.properties.publicIPAddress.id)
        | join kind=leftouter (Resources
            | where type =~ 'microsoft.network/publicipaddresses'
            | project publicIpId = id, publicIp = properties.dnsSettings.fqdn
        ) on publicIpId
        | project-away publicIpId, publicIpId1
        | summarize privateIps = make_list(privateIp), publicIpDns = make_list(publicIp) by vmId
    ) on vmId
    | project-away vmId1
    | sort by vmName asc
| where array_length(publicIpDns)>0" -o json | jq .data[] > machineDetails.json
```
