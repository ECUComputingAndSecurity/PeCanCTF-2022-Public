param suffix string

param location string
param useZones bool

param vnetName string
param snetId string

param storageName string
param FQDN string
param image string = 'redpwn/rctf:master'
param apiToken string
param psqlUrl string
param redisUrl string
param logId string

resource plan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'plan${suffix}'
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: useZones ? 'P1v2' : 'B1'
  }
}

// TODO test disabling some params eg origin, port
resource app 'Microsoft.Web/sites@2020-06-01' = {
  name: 'ase${suffix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // redundancyMode: 
    clientAffinityEnabled: false
    httpsOnly: true
    serverFarmId: plan.id
    siteConfig: {
      alwaysOn: true // no extra cost
      appSettings: [
        {
          name: 'RCTF_INSTANCE_TYPE'
          value: 'all'
        }
        {
          name: 'RCTF_ORIGIN'
          value: FQDN
        }
        {
          name: 'PORT'
          value: string(80)
        }
        {
          name: 'RCTF_TOKEN_KEY'
          value: apiToken
        }
        {
          name: 'RCTF_DATABASE_MIGRATE'
          value: 'before'
        }
        {
          name: 'RCTF_DATABASE_URL'
          value: psqlUrl
        }
        // the psql client seems to ignore ?sslmode, so use envvar instead
        {
          name: 'PGSSLMODE'
          value: 'verify-full'
        }
        {
          name: 'RCTF_REDIS_URL'
          value: redisUrl
        }
        // default is conf.d, but App Service storage mount path can't include dots
        {
          name: 'RCTF_CONF_PATH'
          value: '/app/confd'
        }
      ]
      ftpsState: 'Disabled'
      linuxFxVersion: 'DOCKER|${image}'
      vnetName: vnetName
    }
  }
  // tags: {
  //   'hidden-related:${plan.id}': 'empty'
  //   displayName: 'Website'
  // }
}

resource appVnet 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  name: 'virtualNetwork'
  parent: app
  properties: {
    subnetResourceId: snetId
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageName
}

resource configStorage 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'azurestorageaccounts'
  parent: app
  properties: {
    '${storage.name}': {
      type: 'AzureBlob'
      accountName: storage.name
      shareName: 'config'
      mountPath: '/app/confd'
      accessKey: storage.listKeys().keys[0].value
    }
  }
}

resource uploadsStorage 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' existing = {
  name: '${storage.name}/default/uploads'
}

resource roleBlobContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource appUploadsContributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(uploadsStorage.id, app.id, roleBlobContributor.id)
  scope: uploadsStorage
  properties: {
    roleDefinitionId: roleBlobContributor.id
    principalId: app.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// resource txt 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
//   name: 'asuid.${domain}'
//   properties: {
//     TXTRecords: [
//       {
//         value: [
//           app.properties.customDomainVerificationId
//         ]
//       }
//     ]
//   }
// }

// resource cname 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
//   name: domain
//   properties: {
//     CNAMERecord: {
//       cname: app.properties.defaultHostName
//     }
//   }
// }

// TODO automatically connect to app
resource insights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${app.name}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logId
  }
  // tags: {
  //   'hidden-link:${app.id}': 'Resource'
  //   displayName: 'AppInsightsComponent'
  // }
}
