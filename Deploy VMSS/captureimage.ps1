param(
    [parameter(mandatory = $true, ValueFromPipelineByPropertyName)]$virtualMachineName,
    [parameter(mandatory = $true, ValueFromPipelineByPropertyName)]$resourceGroupName,
    [parameter(mandatory = $true, ValueFromPipelineByPropertyName)]$hostpoolName
)

$virtualMachineName = "webappservice"
$resourceGroupName = "database-testing"
$imageName = "webappservoce-20210211"
$vm = Get-AzVM -name $virtualMachineName -ResourceGroupName $resourceGroupName
$diskName = $vm.StorageProfile.OsDisk.name
New-AzImage -Image $image -ImageName $imageName -resourcegroupname $ResourceGroupName
$managedImage = Get-AzImage -ImageName $imageName -resourcegroupname $ResourceGroupName



$imageName = "mednetdev-restapi-12022021"
$galleryName = "sjsig"
$galleryImageDefintion = "mednetdev"
$imageversion = "1.0.0"
New-AzImage -Image $image -ImageName $imageName -resourcegroupname $ResourceGroupName
$managedImage = Get-AzImage -ImageName $imageName -resourcegroupname $ResourceGroupName



$image = New-AzImageConfig -Location $vm.location -SourceVirtualMachineId $vm.Id 
# Create the image based on the connected disk on the update VM
Write-Output "Creating image $imageName based on $($vm.name)"
New-AzImage -Image $image -ImageName $imageName -resourcegroupname $ResourceGroupName
$managedImage = Get-AzImage -ImageName $imageName -resourcegroupname $ResourceGroupName

import-module az.compute
$date = get-date -format "yyyy-MM-dd"
$version = $date.Replace("-", ".")

function test-VMstatus($virtualMachineName) {
    $vmStatus = Get-AzVM -name $virtualMachineName -resourcegroup $resourceGroupName -Status
    return "$virtualMachineName status " + (($vmstatus.Statuses | ? { $_.code -match 'Powerstate' }).DisplayStatus)
}

function add-firewallRule($NSG, $localPublicIp, $port) {
    # Pick random number for setting priority. It will exclude current priorities.
    $InputRange = 100..200
    $Exclude = ($NSG | Get-AzNetworkSecurityRuleConfig | select Priority).priority
    $RandomRange = $InputRange | Where-Object { $Exclude -notcontains $_ }
    $priority = Get-Random -InputObject $RandomRange
    $nsgParameters = @{
        Name                     = "Allow-$port-Inbound-$localPublicIp"
        Description              = "Allow port $port from local ip address $localPublicIp"
        Access                   = 'Allow'
        Protocol                 = "Tcp" 
        Direction                = "Inbound" 
        Priority                 = $priority 
        SourceAddressPrefix      = $localPublicIp 
        SourcePortRange          = "*"
        DestinationAddressPrefix = "*" 
        DestinationPortRange     = $port
    }
    $NSG | Add-AzNetworkSecurityRuleConfig @NSGParameters  | Set-AzNetworkSecurityGroup 
}
# Stopping VM for creating clean snapshot
Stop-AzVM -name $virtualMachineName -resourcegroup $resourceGroupName -Force -StayProvisioned

do {
    $status = test-vmStatus -virtualMachineName $virtualMachineName
    $status
} until ( $status -match "stopped")

# If VM is stopped, create snapshot Before Sysprep
$vm = Get-AzVM -name $virtualMachineName -ResourceGroupName $resourceGroupName
$snapshot = New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $vm.location -CreateOption copy
$snapshotName = ($vm.StorageProfile.OsDisk.name).Split("-")
$snapshotName = $snapshotName[0] + "-" + $snapshotName[1] + "-" + $date + "-BS"
Write-Output "Creating snapshot $snapshotName for $virtualMachineName"
$createSnapshot = New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName 

#Source: https://docs.microsoft.com/nl-nl/azure/virtual-machines/windows/capture-image-resource
# If snapshot is created start VM again and run a sysprep
if ($null -eq $createSnapshot) {
    Write-Error "No snapshot created"
    break; 
}
Start-AzVM -name $virtualMachineName -resourcegroup $resourceGroupName 
Write-Output "Snapshot created, starting machine."
do {
    $status = test-vmStatus -virtualMachineName $virtualMachineName
    $status
} until ($status -match "running")


# When the VM is stopped it is time to generalize the VM 
# Source https://docs.microsoft.com/nl-nl/azure/virtual-machines/windows/capture-image-resource
Write-Output "$virtualMachineName is going to be generalized"
Set-AzVm -ResourceGroupName $resourceGroupName -Name $virtualMachineName -Generalized



# Get the update VM for creating new image based on connected disk
$diskName = $vm.StorageProfile.OsDisk.name
# Replace the Before Sysprep to After Sysprep
$image = New-AzImageConfig -Location $vm.location -SourceVirtualMachineId $vm.Id 
# Create the image based on the connected disk on the update VM
Write-Output "Creating image $imageName based on $($vm.name)"
New-AzImage -Image $image -ImageName $imageName -resourcegroupname $ResourceGroupName
$managedImage = Get-AzImage -ImageName $imageName -resourcegroupname $ResourceGroupName




# Source: https://docs.microsoft.com/en-us/azure/virtual-machines/image-version-managed-image-powershell
# Creating image version based on the image created few steps ago

$gallery = Get-AzGallery -Name $galleryName

# Configuring paramaters
$imageVersionParameters = @{
    GalleryImageDefinitionName = $galleryImageDefintion
    GalleryImageVersionName    = $imageversion
    GalleryName                = $gallery.Name
    ResourceGroupName          = $gallery.ResourceGroupName
    Location                   = $gallery.Location
    Source                     = $managedImage.id.ToString()
}
# Doing the job
New-AzGalleryImageDefinition -ResourceGroupName $resourceGroupName -GalleryName $galleryName -Name $galleryImageDefintion -Location "australiaeast" -Publisher "Microsoft" -Offer "Office" -Sku "OS" -OsType "Windows" -OsState "Generalized"
New-AzGalleryImageVersion @imageVersionParameters

$bodyValues = [Ordered]@{
    hostPool               = $hostpoolName
    virtualMachineName     = $VirtualMachineName
    resourceGroupName      = $resourceGroupName
    virtualMachinePublicIp = $virtualMachinePublicIp
    username               = $username
    password               = $password
}
$bodyValues