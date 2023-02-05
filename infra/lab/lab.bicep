param name string
var suffix = '-${name}-lab'

param location string = resourceGroup().location
param FQDN string

// TODO automatically create image gallery without user input
// How is this first-party principal created?
// Looks like well-known client ID in global cloud is c7bb12bf-0b39-4f7f-9171-f418ff39b76a
// param labServicesSvcId string

// resource gallery 'Microsoft.Compute/galleries@2021-10-01' = {
//   name: 'gal${replace(suffix, '-', '_')}'
//   location: location
// }

// resource roleContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
//   name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
// }

// resource labGalleryContributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
//   name: guid(gallery.id, labServicesSvcId, roleContributor.id)
//   scope: gallery
//   properties: {
//     roleDefinitionId: roleContributor.id
//     principalId: labServicesSvcId
//     principalType: 'ServicePrincipal'
//   }
// }

resource lab 'Microsoft.LabServices/labPlans@2021-11-15-preview' = {
  name: 'lab${suffix}'
  location: location
  properties: {
    allowedRegions: [
      location
    ]
    defaultAutoShutdownProfile: {
      shutdownOnDisconnect: 'Enabled'
      disconnectDelay: '00:05:00' // 0-59:00
      shutdownWhenNotConnected: 'Enabled'
      noConnectDelay: '00:15:00' // 15:00-59:00
      shutdownOnIdle: 'UserAbsence'
      idleDelay: '00:15:00' // 15:00-59:00
    }
    defaultConnectionProfile: {
      clientRdpAccess: 'Public'
      clientSshAccess: 'Public'
      
      // Required by ARM but unsupported
      webRdpAccess: 'None'
      webSshAccess: 'None'
    }
    // sharedGalleryId: gallery.id
    supportInfo: {
      url: 'https://${FQDN}'
    }
  }
}