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
// ------------------------------------------------------------------------------------------------
// SQL Database Configuration parameters
// ------------------------------------------------------------------------------------------------
@description('Sql Dabatase Name')
@minLength(1)
@maxLength(128)
param sqldb_n string
var databaseName = '${sql_n}/${sqldb_n}'

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

// ------------------------------------------------------------------------------------------------
// DEPLOY SQL DATABASES
// ------------------------------------------------------------------------------------------------
resource database 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: databaseName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  tags: {
    displayName: databaseName
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600
    sampleName: 'AdventureWorksLT'
  }
  dependsOn: [
    sqlServer
  ]
}

output id string = sqlServer.id
