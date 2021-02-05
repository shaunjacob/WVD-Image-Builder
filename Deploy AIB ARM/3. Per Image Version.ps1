$imageResourceGroup = 'AIB-RG'
$imageTemplateName = 'SJWin10Image2'

#Start build asynchronously
Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -NoWait -PassThru