$imageResourceGroup = 'AIB-RG'
$templates = @(
  'MicrosoftWindowsDesktop.office-365.20h2-evd-o365pp',
  'OptumServe.ProcessServer.2019-Datacenter'
)

while ($true) {
  $templates.ForEach({
    Get-AzImageBuilderTemplate -ImageTemplateName $_ -ResourceGroupName $imageResourceGroup |
      Select-Object Name, LastRunStatusRunState, LastRunStatusRunSubState, ProvisioningState, ProvisioningErrorMessage, LastRunStatusMessage

    Start-Sleep 5
  })
}
