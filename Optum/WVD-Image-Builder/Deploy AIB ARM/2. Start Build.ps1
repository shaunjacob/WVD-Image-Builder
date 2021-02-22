$imageResourceGroup = 'AIB-RG'
$imageTemplateName = 'nhall-WinUI-Tpl'

#Start build asynchronously
Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -NoWait -PassThru