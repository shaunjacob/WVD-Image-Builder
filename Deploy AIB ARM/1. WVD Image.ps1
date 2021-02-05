#Create a gallery definition.
$imageResourceGroup = 'AIB-RG'
$location = 'eastus'
$imageDefName = 'SJDemoImage2'
$myGalleryName = 'SJSIG'
$imageTemplateName = 'SJWin10Image2'
$runOutputName = 'SJDistResults'
$identityNameResourceId = Get-Content .\E2\TempFiles\identityNameId.txt
$sigGalleryName = '/subscriptions/b415de9f-3b82-4533-8637-f8899cc26583/resourceGroups/AIB-RG/providers/Microsoft.Compute/galleries/SJSIG/images/SJDemoImage2'
. E1\Get-AzureImageInfo.ps1


$templateUrl="https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/14_Building_Images_WVD/armTemplateWVD.json"
$templateFilePath = ".\E2\armTemplateWVD.json"

Invoke-WebRequest -Uri $templateUrl -OutFile $templateFilePath -UseBasicParsing

((Get-Content -path $templateFilePath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<rgName>',$imageResourceGroup) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<region>',$location) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<runOutputName>',$runOutputName) | Set-Content -Path $templateFilePath

((Get-Content -path $templateFilePath -Raw) -replace '<imageDefName>',$imageDefName) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<sharedImageGalName>',$sigGalleryName) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<region1>',$location) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<imgBuilderId>',$idenityNameResourceId) | Set-Content -Path $templateFilePath


New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $templateFilePath -Api-Version "2020-02-14" -ImageTemplateName $imageTemplateName -svclocation $location
