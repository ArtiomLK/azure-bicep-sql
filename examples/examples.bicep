targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------

@secure()
param SQL_ADMIN_LOGIN_N string

@secure()
param SQL_ADMIN_LOGIN_PASS string

// Sample tags parameters
var tags = {
  project: 'bicephub'
  env: 'dev'
}

param location string = 'eastus2'

var sql_public_n = 'sql-server-public'
var sql_private_n = 'sql-server-private'

var vmName = take('vm${uniqueString(resourceGroup().id)}', 15)
var publicIpAddressName = '${vmName}PublicIP'
var networkInterfaceName = '${vmName}NetInt'
var osDiskType = 'StandardSSD_LRS'
@description('The size of the VM')
var VmSize = 'Standard_B2s'

// ------------------------------------------------------------------------------------------------
// SQL Database Configuration parameters
// ------------------------------------------------------------------------------------------------
@description('Sql Dabatase Name')
@minLength(1)
@maxLength(128)
param sqldb_n string = 'sample-db'

// ------------------------------------------------------------------------------------------------
// SQL Public Deployment Examples
// ------------------------------------------------------------------------------------------------
module sqlServerPublic '../main.bicep' = {
  name: sql_public_n
  params: {
    location: location
    sql_admin_login_n: SQL_ADMIN_LOGIN_N
    sql_admin_login_pass: SQL_ADMIN_LOGIN_PASS
    sql_n: sql_public_n
    tags: tags
  }
}

resource databasePublic 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${sql_public_n}/${sqldb_n}'
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    sampleName: 'AdventureWorksLT'
  }
  dependsOn: [
    sqlServerPublic
  ]
}


// ------------------------------------------------------------------------------------------------
// SQL Private Deployment Examples
// ------------------------------------------------------------------------------------------------
var subnets = [
  {
    name: 'snet-pe'
    subnetPrefix: '150.100.0.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    delegations: []
  }
  {
    name: 'snet-vm'
    subnetPrefix: '150.100.1.0/24'
    privateEndpointNetworkPolicies: 'Enabled'
    delegations: []
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'vnet-sql-bicep'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '150.100.0.0/23'
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        delegations: subnet.delegations
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
      }
    }]
  }
}

resource pdnsz 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.sqlServerHostname}'
  location: 'global'
  tags: tags
}

module sqlServerPrivate '../main.bicep' = {
  name: sql_private_n
  params: {
    location: location
    sql_admin_login_n: SQL_ADMIN_LOGIN_N
    sql_admin_login_pass: SQL_ADMIN_LOGIN_PASS
    sql_n: sql_private_n
    sql_enable_public_access: false
    snet_sql_pe_id: vnet.properties.subnets[0].id
    pdnsz_sql_id: pdnsz.id
    tags: tags
  }
}

resource databasePrivate 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${sql_private_n}/${sqldb_n}'
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    sampleName: 'AdventureWorksLT'
  }
  dependsOn: [
    sqlServerPrivate
  ]
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicIpAddressName
  location: location
  tags: {
    displayName: publicIpAddressName
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: networkInterfaceName
  location: location
  tags: {
    displayName: networkInterfaceName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: vnet.properties.subnets[1].id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  tags: {
    displayName: vmName
  }
  properties: {
    hardwareProfile: {
      vmSize: VmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: SQL_ADMIN_LOGIN_N
      adminPassword: SQL_ADMIN_LOGIN_PASS
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}OsDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        diskSizeGB: 128
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}
