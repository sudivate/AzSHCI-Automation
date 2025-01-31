#This scripts configures insights for a cluster by creating DCR, installing AMA and eassociating DCR.


$subscriptionId = ""
$resourceGroup = ""
$tenantId = ""
$DCRFilePath = "path to DCRAssociation.json"
$AMATestRuleName = "AMATestRule"

 

# Using CLI

 

az login --tenant $tenantID
az account set -s  $subscriptionId
az monitor data-collection rule create --name $AMATestRuleName --resource-group $resourceGroup --rule-file $DCRFilePath --description "Test DCR Rule for AMA" --location "East US"

 


$clusters = az stack-hci cluster list --resource-group $resourceGroup --query "[].name" -o tsv

 

foreach ($cluster in $clusters) {
    $currentCluster = $cluster
    $currentClusterId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.AzureStackHCI/clusters/$currentCluster"
    Write-Host ("Installing AMA extension for cluster $currentCluster")
        az stack-hci extension create `
                            --arc-setting-name "default" `
                            --cluster-name $currentCluster `
                            --extension-name "AzureMonitorWindowsAgent" `
                            --resource-group $resourceGroup `
                            --auto-upgrade true `
                            --publisher "Microsoft.Azure.Monitor" `
                            --type "AzureMonitorWindowsAgent"

        Write-Host ("creating data association rule for $currentCluster")
        az monitor data-collection rule association create `
                                --name "AMATestName$currentCluster" `
                                --resource $currentClusterId `
                                --rule-id $dcrRuleId 
}

 

# Using Powershell

 

# Connect to Azure
Connect-AzAccount -Tenant $tenantID
Set-AzContext -Subscription $subscriptionId

 

 

# Get the list of clusters
$clusters = Get-AzResource -ResourceGroupName $resourceGroup -ResourceType "Microsoft.AzureStackHCI/clusters" 

 


# Create the Data Collection Rule

 

$rule = New-AzDataCollectionRule -RuleName $AMATestRuleName -ResourceGroupName $resourceGroup -RuleFile $DCRFilePath -Description "Test DCR Rule for AMA" -Location "East US"
$dcrRuleId = $rule.Id

  

# Loop through each cluster
foreach ($cluster in $clusters) {
    $currentCluster = $cluster.Name
    $currentClusterId = $cluster.Id

        Write-Host ("Installing AMA extension for cluster $currentCluster")
        # Install the AMA extension
        New-AzStackHciExtension `
            -ClusterName $currentCluster `
            -ResourceGroupName $resourceGroup `
            -ArcSettingName "default" `
            -Name "AzureMonitorWindowsAgent" `
            -ExtensionParameterPublisher "Microsoft.Azure.Monitor" `
            -ExtensionParameterType "AzureMonitorWindowsAgent"

    #please complete the above operation before triggering this operation
        Write-Host ("creating data association rule for $currentCluster")
        New-AzDataCollectionRuleAssociation `
            -AssociationName "AMATestName$currentCluster" `
            -TargetResourceId $currentClusterId `
            -RuleId $dcrRuleId

}