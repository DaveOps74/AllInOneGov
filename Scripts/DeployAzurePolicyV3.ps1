### Configure Azure Activity logs to stream to specified Log Analytics workspace (Tenant Root Group) ###

# Global Parameters
$Location = "UK South"

$SentinelResourceGroupName = "rg-sentinel-uks-400"
$LogAnalyticsWorkspaceName = "law-sentinel-400"

$KeyVaultResourceGroupName = "rg-sentinelkv-uks-400"

$AzureActivityPolicyAssignmentName = "SOC AAL"
$AzureActivityPolicyAssignmentDisplayName = "SIEM - Configure Azure Activity logs to stream to specified Log Analytics workspace"

$AzureKeyVaultPolicyAssignmentName = "SOC KV"
$AzureKeyVaultPolicyAssignmentDisplayName = "SIEM - Configure diagnostic settings for Azure Key Vault to Log Analytics workspace"

$AzureLogicAppsPolicyAssignmentName = "SOC LAP"
$AzureLogicAppsPolicyAssignmentDisplayName = "SIEM - Configure diagnostic settings for Azure Logic Apps to Log Analytics workspace"

# Connect to your Azure account
##Connect-AzAccount

# Get Tenant ID
$tenantId = (Get-AzContext).Tenant.Id

# Get Subscription ID
$subscriptionId = (Get-AzContext).Subscription.Id

# Get Policy Definition(s)
$AzureActivityPolicyDefinitionId = "/providers/Microsoft.Authorization/policyDefinitions/2465583e-4e78-4c15-b6be-a36cbc7c8b0f"
$AzureKeyVaultPolicyDefinitionId = "/providers/Microsoft.Authorization/policyDefinitions/951af2fa-529b-416e-ab6e-066fd85ac459"
$AzureLogicAppsPolicyDefinitionId = "/providers/Microsoft.Authorization/policyDefinitions/b889a06c-ec72-4b03-910a-cb169ee18721"

$AzureActivityPolicyDefinition = Get-AzPolicyDefinition -Id $AzureActivityPolicyDefinitionId
$AzureKeyVaultPolicyDefinition = Get-AzPolicyDefinition -Id $AzureKeyVaultPolicyDefinitionId
$AzureLogicAppsPolicyDefinition = Get-AzPolicyDefinition -Id $AzureLogicAppsPolicyDefinitionId

# Set Scope for Policy Definitions
$AzureActivityPolicyScope = "/providers/Microsoft.Management/managementGroups/$tenantId"
$AzureKeyVaultPolicyScope = "/subscriptions/$subscriptionId/resourceGroups/$KeyVaultResourceGroupName"
$AzureLogicAppsPolicyScope = "/subscriptions/$subscriptionId/resourceGroups/$SentinelResourceGroupName"

# Get Log Analytics Workspace ID
$logAnalyticsWorkspaceId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName $SentinelResourceGroupName -Name $LogAnalyticsWorkspaceName).ResourceId

# Create User Assigned Managed Identity
$UserAssignedIdentity = New-AzUserAssignedIdentity -ResourceGroupName $SentinelResourceGroupName -Location $Location -Name "MyUserAssignedIdentity"

# Create Policy Assignment(s)
New-AzPolicyAssignment -Name $AzureActivityPolicyAssignmentName -DisplayName $AzureActivityPolicyAssignmentDisplayName -Scope $AzureActivityPolicyScope -PolicyDefinition $AzureActivityPolicyDefinition -PolicyParameterObject @{ logAnalytics = $logAnalyticsWorkspaceId } -IdentityId $UserAssignedIdentity.Id -Location $Location
New-AzPolicyAssignment -Name $AzureKeyVaultPolicyAssignmentName -DisplayName $AzureKeyVaultPolicyAssignmentDisplayName -Scope $AzureKeyVaultPolicyScope -PolicyDefinition $AzureKeyVaultPolicyDefinition -PolicyParameterObject @{ logAnalytics = $logAnalyticsWorkspaceId } -IdentityId $UserAssignedIdentity.Id -Location $Location
New-AzPolicyAssignment -Name $AzureLogicAppsPolicyAssignmentName -DisplayName $AzureLogicAppsPolicyAssignmentDisplayName -Scope $AzureLogicAppsPolicyScope -PolicyDefinition $AzureLogicAppsPolicyDefinition -PolicyParameterObject @{ logAnalytics = $logAnalyticsWorkspaceId } -IdentityId $UserAssignedIdentity.Id -Location $Location