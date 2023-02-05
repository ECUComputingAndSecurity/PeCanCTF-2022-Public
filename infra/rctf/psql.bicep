param suffix string

param location string
param useZones bool

param vnetId string
param snetId string

param username string = 'notpostgres'
@secure()
param password string

resource vnet 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: vnetId
}

// var dnsSuffix = skip(psql.properties.hostName, indexOf(psql.properties.hostName, '.'))
var dnsSuffix = '.postgres.database.azure.com'
resource privateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'psql${suffix}.private${dnsSuffix}'
  location: 'global'
}

resource privateDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: vnet.name
  parent: privateDns
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource psql 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: 'psql${suffix}'
  location: location
  dependsOn: [
    privateDnsVnetLink
  ]
  sku: {
    name: 'Standard_B1ms'
    tier:  useZones ? 'GeneralPurpose' : 'Burstable'
  }
  properties: {
    administratorLogin: username
    administratorLoginPassword: password
    backup: {
      backupRetentionDays: 7
    }
    highAvailability: {
      mode: useZones ? 'ZoneRedundant' : 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: snetId
      privateDnsZoneArmResourceId: privateDns.id
    }
    storage: {
      storageSizeGB: 32
    }
    version: '13'
  }
}

resource psqlConfig 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2021-06-01' = {
  name: 'azure.extensions'
  parent: psql
  properties: {
    value: 'CITEXT'
    source: 'user-override' // TODO is this required?
  }
}

var params = '?sslmode=verify-full&sslrootcert=/app/confd/DigiCertGlobalRootCA.crt.pem'
output url string = 'postgres://${username}:${password}@${psql.properties.fullyQualifiedDomainName}:5432/postgres${params}'
