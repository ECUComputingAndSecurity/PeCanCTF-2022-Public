param suffix string

param location string
param useZones bool

param vnetId string
param snetId string

// cache.windows.net isn't included in environment().suffixes, so determine it manually eg privatelink.redis.cache.windows.net
// var privateDnsName = 'privatelink${skip(redis.properties.hostName, indexOf(redis.properties.hostName, '.'))}'
var privateDnsName = 'privatelink.redis.cache.windows.net'
resource privateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsName
  location: 'global'
}

resource privateDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: redis.name //TODO vnet.name
  parent: privateDns
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'pe-${redis.name}'
  location: location
  properties: {
    subnet: {
      id: snetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pl-${redis.name}'
        properties: {
          groupIds: [
            'redisCache'
          ]
          privateLinkServiceId: redis.id
        }
      }
    ]
  }
}

resource privateDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'registry-PrivateDnsZoneGroup'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsName
        properties: {
          privateDnsZoneId: privateDns.id
        }
      }
    ]
  }
}

var zones = useZones ? pickZones('Microsoft.Cache', 'redis', location) : []
resource redis 'Microsoft.Cache/redis@2021-06-01' = {
  name: 'redis${suffix}'
  location: location
  properties: {
    enableNonSslPort: false
    publicNetworkAccess: 'Disabled'
    redisVersion: '6'
    sku: {
      capacity: useZones ? 1 : 0
      family: 'C'
      name: useZones ? 'Premium' : 'Basic'
    }
    replicasPerMaster: useZones ? length(zones) : null
  }
  zones: zones
}

// primaryKey may not be available immediately
output url string = 'rediss://${redis.properties.hostName}:${redis.properties.sslPort}?db=0&password=${redis.properties.accessKeys.primaryKey}'
