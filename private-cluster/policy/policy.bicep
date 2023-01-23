targetScope = 'resourceGroup'
param subId string

resource ESAKSAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'EnterpriseScale AKS'
  location: resourceGroup().location
  properties: {
      policyDefinitionId: '/subscriptions/${subId}/providers/Microsoft.Authorization/policySetDefinitions/EnterpriseScale-AKS-Initiative'
  }
  identity: {
    type: 'SystemAssigned'
  }
}
