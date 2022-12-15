param name string
param addressprefix string
param subnets array
param location string


var networkContributorRoleDefId = '4d97b98b-1d4f-4787-a291-c67834d212e7'


resource umi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'umi-${name}'
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'vnet-${name}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressprefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: 'vnet-${name}-${subnet.name}'
      properties: {
        addressPrefix: subnet.subnetprefix
      }
    }]
  }

  resource subnetaks 'subnets' existing = {
    name: 'vnet-${name}-sn-aks'
  }

  resource subnetvms 'subnets' existing = {
    name: 'vnet-${name}-sn-vms'
  }
}


resource setVnetRbac 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: vnet
  name: guid(umi.id, networkContributorRoleDefId, name)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleDefId)
    principalId: umi.properties.principalId
    principalType: 'ServicePrincipal'
  }
}


output vnetId string = vnet.id
output subnetIdaks string = vnet::subnetaks.id 
output subnetIdvms string = vnet::subnetvms.id 
