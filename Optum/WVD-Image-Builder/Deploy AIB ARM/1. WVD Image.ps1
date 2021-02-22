#Create a gallery definition.
$imageResourceGroup = 'AIB-RG'
$location = 'eastus'
$imageDefName = 'nhall-WinUI-Image'
$myGalleryName = 'OptumServeSIG'
$imageTemplateName = 'nhall-WinUI-Tpl'
$runOutputName = 'nhall-DistResults'
$subscriptionID = '9c40734a-50b6-4900-8110-23f052b0a1c4'
$identityNameResourceId = Get-Content .\identity\identityNameId.txt
$sigGalleryName = '/subscriptions/9c40734a-50b6-4900-8110-23f052b0a1c4/resourceGroups/AIB-RG/providers/Microsoft.Compute/galleries/OptumServeSIG/images/nhall-WinUI-Image'
# . E1\Get-AzureImageInfo.ps1


$templateUrl="https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/14_Building_Images_WVD/armTemplateWVD.json"
$templateFilePath = ".\Deploy AIB ARM\armTemplateWVD.json"

Invoke-WebRequest -Uri $templateUrl -OutFile $templateFilePath -UseBasicParsing

((Get-Content -path $templateFilePath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<rgName>',$imageResourceGroup) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<region>',$location) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<runOutputName>',$runOutputName) | Set-Content -Path $templateFilePath

((Get-Content -path $templateFilePath -Raw) -replace '<imageDefName>',$imageDefName) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<sharedImageGalName>',$sigGalleryName) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<region1>',$location) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<imgBuilderId>',$identityNameResourceId) | Set-Content -Path $templateFilePath


# Create RG Deployment from given JSON template
# New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $templateFilePath -Api-Version "2020-02-14" -ImageTemplateName $imageTemplateName -svclocation $location

# CHANGEME
$imageTemplateName = 'CustomBuild..'
New-AzResourceGroupDeployment -ResourceGroupName 'AIB-RG' -TemplateFile .\tpl\winui.tpl.json -Api-Version "2020-02-14" -ImageTemplateName $imageTemplateName -svclocation 'eastus'

# Build image from template
# Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -NoWait -PassThru     

