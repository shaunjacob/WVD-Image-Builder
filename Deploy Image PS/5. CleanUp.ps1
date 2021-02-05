$imageResourceGroup = 'AIB-RG'
$imageTemplateName = 'SJWin10Image'

#CleanUp
Remove-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup