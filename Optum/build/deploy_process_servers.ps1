param(
  [string] $ServiceBusResourceGroup = 'rg-mitch-test-1',
  [string] $ServiceBusNamespace     = 'mitch-test-1',
  [string] $VMResourceGroup         = 'RG-Processing',

  [Parameter(
    HelpMessage="Number of messages used to autoscale (Total VMs = Total messages / This value)"
  )] [int] $MessagesPerServer = 1000,

  [Parameter(
    Mandatory=$true,
    HelpMessage="The storage container URL that hosts the Custom Script Extension"
  )] [string] $CSExtensionStorageContainerUri,

  [Parameter(
    Mandatory=$true,
    HelpMessage="The SAS token to the Custom Script Extension"
  )] [string] $CSExtensionStorageContainerSasToken,

  [Parameter(
    Mandatory=$true,
    HelpMessage="The name of the Custom Script Extension powershell script"
  )] [string] $CSExtensionName
)

. "$PSScriptRoot/functions.ps1"

# This holds the total message count across all Process Server queues
$messageCount = 0

# VM resources will have this prefix
$vmPrefix = 'ProcServ'

# Count up messages across all PSCH queues
Get-AzServiceBusQueue -ResourceGroupName $ServiceBusResourceGroup -Namespace $ServiceBusNamespace | Where-Object {
  $_.Name.StartsWith('psch')
} | ForEach { $messageCount += $_.MessageCount }

$currentVMs = Get-AzVM -ResourceGroupName $VMResourceGroup | Where-Object {
  $_.Name.StartsWith($vmPrefix)
} | Sort-Object { $_.Name }

$currentVMsCount = $currentVMs.Length

# Will assert this many VMs are running
$vmTotal = [Math]::Ceiling($messageCount / $MessagesPerServer)

@{
  "Messages in queues" = $messageCount;
  "Current VM count" = $currentVMsCount;
  "Target VM count" = $vmTotal;
} | Format-Table

if ($currentVMsCount -eq $vmTotal) {
  Write-Host "We're right sized. Nothing to do."
  exit 0
}

if ($currentVMsCount -gt $vmTotal) {
  Write-Host "Environment is oversized by $($currentVMsCount - $vmTotal) VMs"
  Write-Host "Scaling down down to $vmTotal VMs"

  # Shutdown and remove tail end of excess VMs
  $currentVMs[$currentVMsCount..$vmTotal] | CleanupVMs

  # TODO Remove SQL rows
} else {
  Write-Host "Environment is undersized by $($vmTotal - $currentVMsCount) VMs"
  Write-Host "Scaling up to $vmTotal VMs"

  #Import-Module -Name SqlServer
  $psUsername = 'svc_processserver'
  $psCategory = 'PROCESSSCHEDULER'
  $psExecutable = 'C:\LHIProjects\LHI.MEDNet\LHI.MedNet.ProcessServer.exe'

  # Foreach new VM...
  ($currentVMsCount..$vmTotal) | ForEach {
    $MachineName = "$vmPrefix-$_"

    # Foreach instance... (there are 10 instances per VM)
    (1..10) | ForEach {
      $query = "INSERT INTO ProcessServers VALUES ((SELECT MAX(ProcessServerId) + 1 FROM ProcessServers), '$MachineName-$_, '$psCategory', '$psUsername', '$psExecutable', 'A', 'N', '', 0, 0, 0, getdate(), getdate(), getdate(), getdate(), 0, NULL, 0, 'A', getdate(), 'Automation', getdate(), 'Automation', 1600, NULL, 50001)"

      Write-Host $query
    }
  }

  $deployment = New-AzResourceGroupDeployment -ResourceGroupName $VMResourceGroup -TemplateFile "$PSScriptRoot/../processServer/processVm.json" -TemplateParameterFile "$PSScriptRoot/../processServer/processVm.parameters.json" -vmCount $vmTotal -vmPrefix $vmPrefix -customScriptExtensionContainer $CSExtensionStorageContainerUri -customScriptExtensionSASToken $CSExtensionStorageContainerSasToken -customScriptExtensionName $CSExtensionName -Verbose

  $deployment

  if ($deployment.ProvisioningState -eq 'Failed') {
    Write-Error "Deployment failed"
  }
}
