//Parameters values for the deployment. These parameters are coming from the main.bicep parameters.
@description('The name of the User Assigned Managed Identity for all the Azure Services.')
param usermiName string

@description('The name of the AKS Managed Cluster resource.')
param clusterName string

@description('DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('The location of the AKS Managed Cluster resource.')
param location string

@description('The number of nodes for the AKS cluster.')
param agentCount int

@description('The size of the Virtual Machine (AKS nodes).')
param agentVMSize string

// Resources for the deployment

// Creates a User Assigned Managed Identity resource.
resource usermi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: usermiName
  location: location
}

// Creates an AKS Managed Cluster resource and assigns the User Assigned Managed Identity "usermi"
resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${usermi.id}': {         
      }
    }
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
  }
}

//Outputs properties from the User Identity resource
output usermiOutputName string = usermi.name
output usermiOutputPrincipalId string = usermi.properties.principalId
