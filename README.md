# Azure SQL Server

[![DEV - Deploy Azure Resource](https://github.com/ArtiomLK/azure-bicep-sql/actions/workflows/dev.orchestrator.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-sql/actions/workflows/dev.orchestrator.yml)

[Reference examples][1]

## Locally test Azure Bicep Modules

```bash
sub_id="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";        echo $sub_id
rg_n="rg-azure-bicep-sql-demo";                       echo $rg_n
l="eastus2";                                          echo $l

# Create an Azure Resource Group
az group create \
--name $rg_n \
--location $l \
--tags project=bicephub env=dev

# Deploy Sample Modules
az deployment group create \
--subscription $sub_id \
--resource-group $rg_n \
--mode Incremental \
--template-file examples/examples.bicep
```

## Additional Resources

- Azure SQL Server
- [StackOverflow | Azure SQL Server version 12][2]
- [MS | Learn | Resolve errors for SKU not available][3]
- Azure VMs

[1]: ./examples/examples.bicep
[2]: https://dba.stackexchange.com/a/290563
[3]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-sku-not-available?tabs=azure-cli
