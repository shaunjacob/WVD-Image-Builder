$imageResourceGroup = 'AIB-RG'
$imageTemplateName = 'SJWin10Image2'

$state = Get-AzImageBuilderTemplate -ImageTemplateName  $imageTemplateName -ResourceGroupName $imageResourceGroup
$state | Select-Object LastRunStatusRunState, LastRunStatusRunSubState, ProvisioningState, ProvisioningErrorMessage
