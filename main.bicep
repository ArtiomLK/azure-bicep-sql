targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
param location string

@description('Az Resources tags')
param tags object = {}

// ------------------------------------------------------------------------------------------------
// SQL Server Configuration parameters
// ------------------------------------------------------------------------------------------------
@description('The administrator username of the SQL logical server')
param sql_admin_login_n string

@description('The administrator password of the SQL logical server.')
@secure()
param sql_admin_login_pass string

@description('Sql Server Name')
@minLength(1)
@maxLength(63)
param sql_n string

@description('Enable public network access')
param sql_enable_public_access bool = true

@description('subnet ID to attach the Private Endpoints Connections')
param snet_sql_pe_id string = ''

// pdnszgroup - Add A records to PDNSZ for app pe
@description('SQL Private DNS Zone Resource ID where the A records will be written')
param pdnsz_sql_id string = ''

// ------------------------------------------------------------------------------------------------
// Enable SQL Server PE
// ------------------------------------------------------------------------------------------------
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01'  = if (!empty(snet_sql_pe_id)) {
  name: 'pe-${sql_n}'
  location: location
  properties: {
    subnet: {
      id: snet_sql_pe_id
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-${sql_n}-${take(guid(subscription().id, sql_n, resourceGroup().name), 4)}'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01'  = if (!empty(snet_sql_pe_id)) {
  name: '${privateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: pdnsz_sql_id
        }
      }
    ]
  }
}

// ------------------------------------------------------------------------------------------------
// DEPLOY SQL Server
// ------------------------------------------------------------------------------------------------
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sql_n
  location: location
  tags: tags
  properties: {
    administratorLogin: sql_admin_login_n
    administratorLoginPassword: sql_admin_login_pass
    version: '12.0'
    publicNetworkAccess: sql_enable_public_access ? 'enabled' : 'disabled'
  }
}

output id string = sqlServer.id
