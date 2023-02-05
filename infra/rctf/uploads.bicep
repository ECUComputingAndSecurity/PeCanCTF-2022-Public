param suffix string

param location string
param useZones bool

param FQDN string

resource storage 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: 'st${take(replace(suffix, '-', ''), 24)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: useZones ? 'Standard_ZRS' : 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storage
}

resource config 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: 'config'
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

resource uploads 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: 'uploads'
  parent: blobService
  properties: {
    publicAccess: 'Blob'
  }
}

resource cdnProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: 'cdnp${suffix}'
  location: 'global'
  sku: {
    name: 'Standard_Verizon'
  }
}

var stUri = storage.properties.primaryEndpoints.blob
var stDomain = substring(stUri, 8, length(stUri)-9) // 2nd arg is "number of chars" not "end index"

resource cdnEndpoint 'Microsoft.Cdn/profiles/endpoints@2021-06-01' = {
  name: 'cdne${suffix}'
  location: 'global'
  parent: cdnProfile
  properties: {
    isHttpAllowed: false
    originHostHeader: stDomain
    origins: [
      {
        name: replace(stDomain, '.', '-')
        properties: {
          hostName: stDomain
        }
      }
    ]
  }
}

resource cdnCustomDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = {
  name: FQDN
  parent: cdnProfile
  properties: {
    hostName: FQDN
    tlsSettings: {
      certificateType: 'AzureFirstPartyManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
  }
}

output storage string = storage.name
