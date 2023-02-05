@description('Name of the CTF')
param name string
var suffix = '-${name}-rctf'

param location string = resourceGroup().location // eg australiaeast
@description('Whether to use availability zones. Only available in some regions at much higher costs.')
param useZones bool = length(concat(pickZones('Microsoft.DBforPostgreSQL', 'flexibleServers', location), pickZones('Microsoft.Cache', 'redis', location), pickZones('Microsoft.Web', 'sites', location))) == 3

@description('Your domain name. Will result in rCTF at rctf.domain.com, chals at yourchal.chals.domain.com, and CDN at cdn.domain.com.')
param domainName string
@description('rCTF Docker image with tag')
param image string = 'ghcr.io/ecucomputingandsecurity/rctf:latest'

@secure()
@description('PostgreSQL password')
param psqlPassword string

@minLength(44)
@maxLength(44)
@secure()
@description('base64 encoded 32 byte key used for encrypting auth tokens')
param apiToken string

// shouldn't deploy snets separately per Azure/bicep#5397
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet${suffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/25'// /26 for app service. /28 for psql. /29 for redis pe. /29 for storage pe?
      ]
    }
    subnets: [
      {
        name: 'snet-ase'
        properties: {
          addressPrefix: '10.0.0.0/26'
          delegations: [
            {
              name: 'dlg-ase'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
        }
      }
      {
        name: 'snet-psql'
        #disable-next-line BCP187
        location: location
        properties: {
          addressPrefix: '10.0.0.64/28'
          delegations: [
            {
              name: 'dlg-psql'
              properties: {
                serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
              }
            }
          ]
        }
      }
      {
        name: 'snet-redis'
        #disable-next-line BCP187
        location: location
        properties: {
          addressPrefix: '10.0.0.80/29'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource log 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: 'log${suffix}'
  location: location
  properties: {
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

// Fixed price per month, so only deploy when environment is done and ready to test
// resource loadTest 'Microsoft.LoadTestService/loadTests@2021-12-01-preview' = {
//   name: 'ltr-${suffix}'
//   location: location
// }

module psql 'psql.bicep' = {
  name: 'psql'
  params: {
    suffix: suffix
    location: location
    useZones: useZones
    vnetId: vnet.id
    snetId: '${vnet.id}/subnets/snet-psql'
    password: psqlPassword
  }
}

module redis 'redis.bicep' = {
  name: 'redis'
  params: {
    suffix: suffix
    location: location
    useZones: useZones
    vnetId: vnet.id
    snetId: '${vnet.id}/subnets/snet-redis'
  }
}

module uploads 'uploads.bicep' = {
  name: 'uploads'
  params: {
    suffix: suffix
    location: location
    useZones: useZones
    FQDN: 'cdn.${domainName}'
  }
}

module app 'app.bicep' = {
  name: 'app'
  params: {
    suffix: suffix
    location: location
    useZones: useZones
    vnetName: vnet.name
    snetId: '${vnet.id}/subnets/snet-ase'
    image: image
    FQDN: domainName
    apiToken: apiToken
    psqlUrl: psql.outputs.url
    redisUrl: redis.outputs.url
    storageName: uploads.outputs.storage
    logId: log.id
  }
}
