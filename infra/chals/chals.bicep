// based on https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/deploy/azuredeploy.json
// https://azure.github.io/application-gateway-kubernetes-ingress/annotations/#appgw-trusted-root-certificate

@description('Name of the CTF')
param name string
var suffix = '-${name}-chals'

param location string = resourceGroup().location
param useZones bool = length(concat(pickZones('Microsoft.ContainerService', 'ManagedClusters', location), pickZones('Microsoft.ContainerRegistry', 'registries', location))) == 2

@description('Object ID of your GitHub Actions service principal')
param githubSvcId string

resource registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: 'cr${replace(suffix,'-','')}'
  location: location
  sku: {
    name: useZones ? 'Premium' : 'Basic'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccess: 'Enabled' // allow push from GitHub Actions
    zoneRedundancy: useZones ? 'Enabled' : 'Disabled'
  }
}

resource roleAcrPush 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '8311e382-0749-4cb8-b61a-304f252e45ec'
}

resource githubAcrPush 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(registry.id, githubSvcId, roleAcrPush.id)
  scope: registry
  properties: {
    roleDefinitionId: roleAcrPush.id
    principalId: githubSvcId
    principalType: 'ServicePrincipal'
  }
}

var aksZones = pickZones('Microsoft.ContainerService', 'ManagedClusters', location, 2)

resource cluster 'Microsoft.ContainerService/managedClusters@2021-08-01' = {
  name: 'aks${suffix}'
  location: location
  sku: {
    name: 'Basic'
    tier: useZones ? 'Paid' : 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    addonProfiles: {
      ingressApplicationGateway: {
        enabled: true
        config: {
          subnetCIDR: '10.232.0.0/16'
        }
      }
    }
    agentPoolProfiles: [
      {
        availabilityZones: aksZones
        count: useZones ? length(aksZones) : 1
        enableAutoScaling: true
        enableNodePublicIP: true
        kubeletDiskType: 'OS'
        maxCount: useZones ? length(aksZones) : 1
        minCount: 1
        mode: 'System'
        name: 'pipagentpool'
        osDiskSizeGB: 0
        osType: 'Linux'
        vmSize: 'Standard_B2s'
      }
    ]
    apiServerAccessProfile: {
      disableRunCommand: true
      enablePrivateCluster: false // required for GitHub Actions
    }
    autoUpgradeProfile: {
      upgradeChannel: 'node-image'
    }
    dnsPrefix: 'aks${suffix}-dns'
    enableRBAC: true
    kubernetesVersion: '1.21.14'
  }
}

resource roleAcrPull 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

resource clusterAcrPull 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(registry.id, cluster.id, roleAcrPull.id)
  scope: registry
  properties: {
    roleDefinitionId: roleAcrPull.id
    principalId: cluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

resource roleAksUser 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '4abbcc35-e782-43d8-92c5-2d3f1bd2253f'
}

resource githubAksUser 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(cluster.id, githubSvcId, roleAksUser.id)
  scope: cluster
  properties: {
    roleDefinitionId: roleAksUser.id
    principalId: githubSvcId
    principalType: 'ServicePrincipal'
  }
}

output appGatewayId string = cluster.properties.addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId

// certbot certonly --manual --preferred-challenges=dns -d *.chals.domain.com
// az network application-gateway ssl-cert create -g rg-[name]-chals --gateway-name [output] -n appgw-cert --cert-file cert.pfx --cert-password password 
