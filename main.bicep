targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
param location string

@description('Az Resources tags')
param tags object = {}

// ------------------------------------------------------------------------------------------------
// SQL Configuration parameters
// ------------------------------------------------------------------------------------------------
@description('The administrator username of the SQL logical server')
param sql_admin_login_n string

@description('The administrator password of the SQL logical server.')
@secure()
param sql_admin_login_pass string

@description('Sql Server Name')
param sql_n string = 'sqlserver${uniqueString(resourceGroup().id)}'

@description('Enable public network access')
param sql_enable_public_access bool = true

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
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
