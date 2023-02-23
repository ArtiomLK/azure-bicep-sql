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

// ------------------------------------------------------------------------------------------------
// SQL Deployment Examples
// ------------------------------------------------------------------------------------------------
module sqlServer '../main.bicep' = {
  name: 'sql-server-public'
  params: {
    location: location
    sql_admin_login_n: SQL_ADMIN_LOGIN_N
    sql_admin_login_pass: SQL_ADMIN_LOGIN_PASS
    sql_n: 'sql-server-public'
    sqldb_n: 'sample-db'
    tags: tags
  }
}
