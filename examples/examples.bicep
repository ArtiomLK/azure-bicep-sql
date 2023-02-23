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

// ------------------------------------------------------------------------------------------------
// SQL Deployment Examples
// ------------------------------------------------------------------------------------------------
module sqlServerPublic '../main.bicep' = {
  name: 'sql-server-public'
  params: {
    location: location
    sql_admin_login_n: SQL_ADMIN_LOGIN_N
    sql_admin_login_pass: SQL_ADMIN_LOGIN_PASS
    sql_n: sql_public_n
    tags: tags
  }
}

// ------------------------------------------------------------------------------------------------
// SQL Database Configuration parameters
// ------------------------------------------------------------------------------------------------
@description('Sql Dabatase Name')
@minLength(1)
@maxLength(128)
param sqldb_n string = 'sample-db'
var databaseName = '${sql_public_n}/${sqldb_n}'
// ------------------------------------------------------------------------------------------------
// DEPLOY SQL DATABASES
// ------------------------------------------------------------------------------------------------
resource database 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: databaseName
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
