$imageResourceGroup = 'AIB-RG'
$imageTemplateName = 'SJWin10Image'

#Start build asynchronously
Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -NoWait -PassThru