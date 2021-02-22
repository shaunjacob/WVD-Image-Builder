param(
  [string] $imageResourceGroup = 'AIB-RG',
  [string] $template = 'MicrosoftWindowsDesktop.office-365.20h2-evd-o365pp'
)

Install-Module -Name 'Az.ImageBuilder' -AllowPrerelease -Confirm:$false -Force

$interval  = 10     # How often to check
$max_wait  = 7200   # How long to wait: Two hours
$waited    = 0      # How long we've been waiting
$succeeded = $true  # Did the build succeed within $max_wait

$aibtpl = Get-AzImageBuilderTemplate -ImageTemplateName $template -ResourceGroupName $imageResourceGroup
while ($aibtpl.LastRunStatusRunState -ne 'Succeeded') {
  Write-Host ("{0} run state is {1} ... Sleeping for {2}s" -f $aibtpl.Name, $aibtpl.LastRunStatusRunState, $interval)
  Start-Sleep $interval

  $waited += $interval

  if ($waited -gt $max_wait) {
    $succeeded = $false
    break
  }

  $aibtpl = Get-AzImageBuilderTemplate -ImageTemplateName $template -ResourceGroupName $imageResourceGroup
}

if (-not $succeeded) {
  Write-Error "Build timed out"
  Write-Error ($aibtpl | Select-Object Name, LastRunStatusRunState, LastRunStatusRunSubState, ProvisioningState, ProvisioningErrorMessage, LastRunStatusMessage)
  exit 1
}
