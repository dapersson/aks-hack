// params
param resourcename string
param admingroupobjectid string = ''
param allowedhostIp string = ''
@secure()
param vmpwd string = ''
param location string = resourceGroup().location
@allowed([
  'dev'
  'tst'
  'prd'
])
param env string = 'dev'


param deployInit bool = true
param deployAzServices bool = true
param deployAks bool = false
param deployVm bool = false

// Variables
var name = '${resourcename}-${env}'
var networkPlugin = 'kubenet' // 'kubenet' | 'azure'

module umi 'umi.bicep' = {
  name: 'umiDeploy'
  params: {
    location: location
    name: name
  }
}

module privateDnsZone 'privatednszone.bicep' = if(deployInit) {
  name: 'privateDnsZoneDeploy'
  params: {
    privateDnsZoneName: '${name}.privatelink.${toLower(location)}.azmk8s.io'
    name: name
    vnetId: vnet.outputs.vnetId
  }
  dependsOn: [
    umi
  ]
}

module storage 'storageaccount.bicep' = if(deployInit) {
  name: 'stgDeploy'
  params: {
    location: location
    name: name 
  }
  dependsOn: [
    umi
  ]
}

module vnet 'vnet.bicep' = if(deployInit){
  name: 'vnetDeploy'
  params: {
    addressprefix: '10.0.0.0/21'
    location: location
    name: name
    snkubenetAddrPrefix: '10.0.3.0/24'
    subnets: [
      {
        name: 'sn-aks-cni'
        subnetprefix: '10.0.0.0/23'
      }
      {
        name: 'sn-vms'
        subnetprefix: '10.0.2.0/27'
      }
      {
        name: 'sn-pe'
        subnetprefix: '10.0.2.32/27'
      }
      {
        name: 'sn-aks-kubenet'
        subnetprefix: '10.0.3.0/24'
      }
      
    ]
  }
  dependsOn: [
    umi
  ]
}



module la 'loganalytics.bicep' = if(deployAzServices) {
  name: 'laDeploy'
  params: {
    location: location
    name: name
  }
}

module acr 'acr.bicep' = if(deployAzServices) {
  name: 'acrDeploy'
  params: {
    location: location
    name: name
  }
  dependsOn: [
    umi
  ]
}

module akv 'akv.bicep' = if(deployAzServices) {
  name: 'akvDeploy'
  params: {
    location: location
    name: name
  }
  dependsOn: [
    umi
  ]
}

module akscni 'aks.bicep' = if (networkPlugin == 'azure' && deployAks) {
  name: 'aksCniDeploy'
  params: {
    aksSubnetId: vnet.outputs.subnetIdakscni
    dnsServiceIP: '10.2.0.10'
    dockerBridgeCidr: '172.17.0.1/16'
    name: name
    nodeResourceGroup: 'rg-${name}-aks'
    serviceCidr: '10.2.0.0/24'
    location: location
    adminGroupObjectIDs: admingroupobjectid
    kubernetesVersion: '1.24.6' // az aks get-versions --location westeurope --output table
    privateDnsZoneId: privateDnsZone.outputs.privateDNSZoneId
    networkPlugin: networkPlugin

  }
  dependsOn: [
    umi
    akv
    acr
    la
  ]
}

module akskubenet 'aks.bicep' = if (networkPlugin == 'kubenet' && deployAks) {
  name: 'aksKubenetDeploy'
  params: {
    aksSubnetId: vnet.outputs.subnetIdakskubenet
    dnsServiceIP: '172.10.0.10'
    dockerBridgeCidr: '172.17.0.1/16'
    podCidr: '10.240.100.0/22'
    serviceCidr: '172.10.0.0/16'
    name: name
    nodeResourceGroup: 'rg-${name}-aks'
    location: location
    adminGroupObjectIDs: admingroupobjectid
    kubernetesVersion: '1.24.3' // az aks get-versions --location westeurope --output table
    privateDnsZoneId: privateDnsZone.outputs.privateDNSZoneId
    networkPlugin: networkPlugin
  }
  dependsOn: [
    umi
    akv
    acr
    la
    
  ]
}

module vm1 'vm.bicep' = if(deployVm) {
  name: 'vm1Deploy'
  params: {
    allowedhostIp: allowedhostIp
    name: name
    subnetid: vnet.outputs.subnetIdvms
    location:location
    vm_pwd:vmpwd
    storageAccountName: storage.outputs.storageAccountName
  }
}
