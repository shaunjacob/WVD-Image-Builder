$imageResourceGroup = 'AIB-RG'
$imageTemplateName = 'SJWin10Image2'

#CleanUp
Remove-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup