// Define parameters used by resources.

@description('The name of the User Assigned Managed Identity.')
param usermiName string = 'uami${uniqueString(resourceGroup().id)}'

@description('The name of the AKS Managed Cluster resource.')
param clusterName string = take('aks${uniqueString(resourceGroup().id)}', 10)

@description('DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = take('dnsaks${uniqueString(resourceGroup().id)}', 12)

@description('The location of the AKS Managed Cluster resource.')
param location string = resourceGroup().location

@description('The number of nodes for the AKS cluster.')
@minValue(1)
@maxValue(3)
param agentCount int = 1

@description('The size of the Virtual Machines (AKS nodes).')
param agentVMSize string = 'standard_d2s_v3'

// privDnsZonesubscriptionID: The subscription ID where the Private DNS Zone is located.
param privDnsZonesubscriptionID string = '<REPLACE-WITH-SUBSCRIPTIONID-WHERE-PRIVATEDNSZONE-IS-LOCATED>'
// privDnsZoneRgName: The name of the Resource Group where the Private DNS Zone is located.
param privDnsZoneRgName string = '<REPLACE-WITH-RESOURCEGROUP-WHERE-PRIVATEDNSZONE-IS-LOCATED>'
// privDnsZoneName: The name of the Private DNS Zone. Example: privatezonedns.com
param privDnsZoneName string = '<REPLACE-WITH-PRIVATEDNSZONE-NAME>'
// contributorRoleDefinitionID: The name of the Role Definition to assign to the Managed Identity. In this case this ID corresponds to the "Private DNS Zone Contributor" Role Definition.
param contributorRoleDefinitionID string = 'b12aa53e-6015-4669-85d0-8515ebb3ae7f'


// Define resources used by the template as modules.
// Resources created: AKS, User Assigned Identity and Role Assignment.
module aks 'modules/aks.bicep' ={
  name: clusterName
  params:{
    usermiName: usermiName
    clusterName: clusterName
    dnsPrefix: dnsPrefix
    location: location
    agentCount: agentCount
    agentVMSize: agentVMSize
  }  
}

module roleassigment 'modules/roleassigment.bicep' = {
  name: 'privDnsZoneContributorAssignmentName'
  scope: resourceGroup(privDnsZonesubscriptionID, privDnsZoneRgName)
  params:{        
    privDnsZoneName: privDnsZoneName
    contributorRoleDefinitionID: contributorRoleDefinitionID    
    usermiPrincipalId: aks.outputs.usermiOutputPrincipalId
  }
}
