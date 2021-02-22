param(
  [string] $Hostpool = 'OptumServe-Test',
  [string] $ResourceGroup = 'WVD-RG',

  # Total number of new VMs to add to host pool
  [int] $PoolSize = 5,

  # Cleanup old hostpool resources now?
  [bool] $CleanupNow = $false
)

. "$PSScriptRoot/functions.ps1"

# Get RDS Registration token
# $RdsRegistrationInfotoken will be set
# TODO: Make better
. "$PSScriptRoot/../WVD-Image-Builder/Update WVD HostPool Pipeline/RdsRegistrationInfotoken.ps1"
$RdsToken = ($RdsRegistrationInfotoken | ConvertTo-SecureString -AsPlainText -Force)

# Enumerate VMs in current host pool
$old_hosts = Get-AzWvdSessionHost -HostPoolName $Hostpool -ResourceGroup $ResourceGroup

# Bring up new hosts w/ latest image
$prefix = "WVD-$(Get-Date -Format 'MMddHH')"

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile "$PSScriptRoot/../WVD-Image-Builder/Update WVD HostPool Pipeline/arm-wvd-AddVirtualMachinesTemplate.json" -TemplateParameterFile "$PSScriptRoot/../WVD-Image-Builder/Update WVD HostPool Pipeline/arm-wvd-AddVirtualMachinesTemplate.parameters.json" -hostpoolToken $RdsToken -vmNumberOfInstances $PoolSize -vmNamePrefix $prefix -hostpoolName $Hostpool -Verbose

# Drain old hosts
$old_hosts | ForEach {
  # OptumServe-Test/WVD-SH-SIG-0.mednetcloudpoc.com
  $name = $_.Name.split('/')[1]

  Update-AzWvdSessionHost -HostPoolName $Hostpool -ResourceGroup $ResourceGroup -Name $name -AllowNewSession:$false -Confirm:$false -Verbose
}

# Cleanup old hosts objects
if ($CleanupNow) {
  CleanupWVDObjects -Hostpool $Hostpool -ResourceGroup $ResourceGroup
}
