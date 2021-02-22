$imageResourceGroup = 'AIB-RG'
$imageTemplateName = 'nhall-WinUI-Tpl-TEST'

$state = Get-AzImageBuilderTemplate -ImageTemplateName  $imageTemplateName -ResourceGroupName $imageResourceGroup
$state | Select-Object LastRunStatusRunState, LastRunStatusRunSubState, ProvisioningState, ProvisioningErrorMessage
