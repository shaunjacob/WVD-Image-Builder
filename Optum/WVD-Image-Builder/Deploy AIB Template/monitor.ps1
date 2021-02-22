$imageResourceGroup = 'AIB-RG'
# $imageTemplateName = 'MicrosoftWindowsDesktop.office-365.20h2-evd-o365pp'
$imageTemplateName = 'MicrosoftWindowsServer.WindowsServer.2019-Datacenter'
while ($true) {
    Get-AzImageBuilderTemplate -ImageTemplateName  $imageTemplateName -ResourceGroupName $imageResourceGroup |
         Select-Object LastRunStatusRunState, LastRunStatusRunSubState, ProvisioningState, ProvisioningErrorMessage, LastRunStatusMessage
    Start-Sleep 5
    Clear-Host
}