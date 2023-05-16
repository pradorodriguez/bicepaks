// Paramters used by the Azure Resources

// usermiPrincipalId: The Principal ID of the User Assigned Managed Identity "usermi".
param usermiPrincipalId string
// privDnsZoneRgName: The name of the Resource Group where the Private DNS Zone is located.
param privDnsZoneName string
// contributorRoleDefinitionID: The name of the Role Definition to assign to the Managed Identity. In this case this ID corresponds to the "Private DNS Zone Contributor" Role Definition.
param contributorRoleDefinitionID string 

// Variables for the Azure Resources
// privDnsZoneContributorId: Returns the unique identifier of the "contributorRoleDefinitionID" Role Definition.
var privDnsZoneContributorId = resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionID)
// privDnsZoneContributorAssignmentName: Creates a value in the format of a globally unique identifier (GUID) based on the values provided as parameters
var privDnsZoneContributorAssignmentName = guid(usermiPrincipalId,contributorRoleDefinitionID,resourceGroup().id)

// References an existing Private DNS Zone resource in another subscription and resource group.
resource privateDNS 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privDnsZoneName 
}

// Creates a Role Assignment resource to assign the "Private DNS Zone Contributor" Role Definition to the User Assigned Managed Identity "usermi".
// The Role Assignment is scoped to the Private DNS Zone resource.
resource contributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: privDnsZoneContributorAssignmentName  
  scope: privateDNS 
  properties: {
    roleDefinitionId: privDnsZoneContributorId
    principalId: usermiPrincipalId      
  }
}
