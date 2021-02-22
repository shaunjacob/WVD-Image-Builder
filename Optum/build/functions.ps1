function CleanupWVDObjects {
  [CmdletBinding()]

  param(
    [string] $Hostpool,
    [string] $ResourceGroup
  )

  Get-AzWvdSessionHost -HostPoolName $Hostpool -ResourceGroup $ResourceGroup | Where-Object {
    $_.AllowNewSession -eq $false
  } | ForEach {
    $sessionHost = $_.Name.split('/')[1]
    $prefix = $sessionHost.Substring(0, 10)

    Remove-AzWvdSessionHost -ResourceGroup $ResourceGroup -HostPoolName $HostPool -Name $sessionHost -Verbose

    Get-AzResource -ResourceGroupName $ResourceGroup | Where-Object {
      $_.Name.StartsWith($prefix) -And $_.ResourceType -eq 'Microsoft.Compute/virtualMachines'
    } | CleanupVMs
  }
}

function CleanupVMs {
  [CmdletBinding()]

  param(
    [Parameter(ValueFromPipeline)] $vm
  )

  process {
    # All associated resources attached to VMs are prefixed with VM name
    $resourcePrefix = $vm.Name
    $resourceGroup = $vm.ResourceGroupName

    Write-Host "Removing $($vm.Name) VM"
    $vm | Remove-AzVM -Confirm:$false -Force -Verbose

    Write-Host "Removing all resources starting with VM.Name: $resourcePrefix"
    Get-AzResource -ResourceGroupName $resourceGroup | Where-Object {
      $_.Name.StartsWith($resourcePrefix)
    } | Remove-AzResource -Confirm:$false -Force -Verbose
  }
}
