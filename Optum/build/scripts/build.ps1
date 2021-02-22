param(
    [string] $templateFilePath,
    [string] $version,
    [string] $ArtifactURL        = '',
    [string] $location           = 'eastus',
    [string] $imageResourceGroup = 'AIB-RG',
    [string] $identityName       = 'OSAIBIdentity',
    [string] $sigGalleryName     = 'OptumServeSIG',
    [string] $destPublisher      = 'OptumServe',
    [string] $destOffer          = 'en-US',
    [string] $vmSize             = 'Standard_D2_v2',
    [string] $srcPublisher       = 'MicrosoftWindowsDesktop',
    [string] $srcOffer           = 'office-365',
    [string] $srcSku             = '20h2-evd-o365pp'
)

$Sku = $srcSku
$destCombined = $destPublisher + '.' + $destOffer + '.' + $Sku

# Image definition name
$imageDefName = $destCombined

# Image template name
$imageTemplateName = $destCombined

# Get identity details
$identityNameResource = Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName

if ((Get-AzGalleryImageDefinition -ResourceGroupName $imageResourceGroup -GalleryName $sigGalleryName).Name -notcontains $imageDefName) {

    $paramNewAzGalleryImageDefinition = @{
        GalleryName       = $sigGalleryName
        ResourceGroupName = $imageResourceGroup
        Location          = $location
        Name              = $imageDefName
        OsState           = 'generalized'
        OsType            = 'Windows'
        Publisher         = $destPublisher
        Offer             = $destOffer
        Sku               = $Sku
        ErrorAction       = 'SilentlyContinue'
    }
    New-AzGalleryImageDefinition @paramNewAzGalleryImageDefinition
}

$imageVersions = Get-AzGalleryImageVersion -GalleryImageDefinitionName $imageDefName -ResourceGroupName $imageResourceGroup -GalleryName $sigGalleryName
$verList = foreach ($ver in $imageVersions.Name) {
    [version]$ver
}
$topVersion = $verList | Sort-Object -Descending | Select-Object -First 1
$pVersion = [version]::Parse($Version)

if($topVersion) {
  $pTopVersion = [version]::Parse($topVersion)
} else {
  # First build. Much Wow. Such New.
  $pTopVersion = [version]::Parse('0.0.0')
}

if ( $pVersion -le $pTopVersion ) {
    Write-Error "Specified Version $Version not greater than $topVersion"
    break
}
#$gallery = Get-AzGallery -ResourceGroupName $imageResourceGroup -GalleryName $sigGalleryName

$imageDefinition = Get-AzGalleryImageDefinition -ResourceGroupName $imageResourceGroup -GalleryName $sigGalleryName -Name $imageDefName

if ((Get-AzImageBuilderTemplate).Name -contains $imageTemplateName) {
    Remove-AzImageBuilderTemplate -ImageTemplateName  $imageTemplateName -ResourceGroupName $imageResourceGroup
}

$paramNewAzResourceGroupDeployment = @{
    ResourceGroupName = $imageResourceGroup
    TemplateFile      = $templateFilePath

    Version           = $version
    vmSize            = $vmSize
    imageId           = $imageDefinition.Id
    identityId        = $identityNameResource.Id
    SrcPublisher      = $srcPublisher
    SrcOffer          = $srcOffer
    SrcSKU            = $Sku
    DestPublisher     = $destPublisher
    DestOffer         = $destOffer
    ArtifactURL       = $ArtifactURL
}
New-AzResourceGroupDeployment @paramNewAzResourceGroupDeployment -Verbose

$paramInvokeAzResourceAction = @{
    ResourceName      = $imageTemplateName
    ResourceGroupName = $imageResourceGroup
    ResourceType      = 'Microsoft.VirtualMachineImages/imageTemplates'
    Action            = 'Run'
    Force             = $true
}
Invoke-AzResourceAction @paramInvokeAzResourceAction

# Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -NoWait -PassThru
