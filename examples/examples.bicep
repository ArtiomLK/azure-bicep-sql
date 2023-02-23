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
  name: 'sql-server-2014-public'
  params: {
    location: location
    sql_admin_login_n: SQL_ADMIN_LOGIN_N
    sql_admin_login_pass: SQL_ADMIN_LOGIN_PASS
    tags: tags
    sql_n: 'sql-server-public'
    sql_v: '12.0'
  }
}
