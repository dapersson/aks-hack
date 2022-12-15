// params
param resourcename string
param admingroupobjectid string
param allowedhostIp string
@secure()
param vmpwd string
param location string = resourceGroup().location
@allowed([
  'dev'
  'tst'
  'prd'
])
param env string = 'dev'

param deployAks bool = true
param deployVm bool = true

// Variables
var name = '${resourcename}-${env}'


module umi 'umi.bicep' = {
  name: 'umiDeploy'
  params: {
    location: location
    name: name
  }
}

module vnet 'vnet.bicep' = {
  name: 'vnetDeploy'
  params: {
    addressprefix: '10.0.0.0/22'
    location: location
    name: name
    subnets: [
      {
        name: 'sn-aks'
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
    ]
  }
  dependsOn: [
    umi
  ]
}

module privateDnsZone 'privatednszone.bicep' = {
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

module storage 'storageaccount.bicep' = {
  name: 'stgDeploy'
  params: {
    location: location
    name: name
  }
  dependsOn: [
    umi
  ]
}

module la 'loganalytics.bicep' = {
  name: 'laDeploy'
  params: {
    location: location
    name: name
  }
}

module acr 'acr.bicep' = {
  name: 'acrDeploy'
  params: {
    location: location
    name: name
  }
  dependsOn: [
    umi
  ]
}

module akv 'akv.bicep' = {
  name: 'akvDeploy'
  params: {
    location: location
    name: name
  }
  dependsOn: [
    umi
  ]
}

module aks 'aks.bicep' = if (deployAks) {
  name: 'aksDeploy'
  params: {
    aksSubnetId: vnet.outputs.subnetIdaks
    dnsServiceIP: '10.2.0.10'
    dockerBridgeCidr: '172.17.0.1/16'
    name: name
    nodeResourceGroup: 'rg-${name}-aks'
    serviceCidr: '10.2.0.0/24'
    location: location
    adminGroupObjectIDs: admingroupobjectid
    kubernetesVersion: '1.24.6' // az aks get-versions --location westeurope --output table
    privateDnsZoneId: privateDnsZone.outputs.privateDNSZoneId
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
