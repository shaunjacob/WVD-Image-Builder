param(
  [string] $VMResourceGroup         = 'RG-Processing',

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

$vmPrefix = 'ProcServ'

$currentVMs = Get-AzVM -ResourceGroupName $VMResourceGroup | Where-Object {
  $_.Name.StartsWith($vmPrefix)
} | Sort-Object { $_.Name }

$currentVMsCount = $currentVMs.Length

#################################
# Rolling upgrade
#################################

ForEach ($vm in $currentVMs) {
  # Remove VM
  $vm | CleanupVMs

  # Redeploy to bring new VM up on latest image
  $deployment = New-AzResourceGroupDeployment -ResourceGroupName $VMResourceGroup -TemplateFile "$PSScriptRoot/../processServer/processVm.json" -TemplateParameterFile "$PSScriptRoot/../processServer/processVm.parameters.json" -vmCount $currentVMsCount -vmPrefix $vmPrefix -customScriptExtensionContainer $CSExtensionStorageContainerUri -customScriptExtensionSASToken $CSExtensionStorageContainerSasToken -customScriptExtensionName $CSExtensionName -Verbose

  $deployment

  if ($deployment.ProvisioningState -eq 'Failed') {
    Write-Error "Deployment failed of $($vm.Name)"
    exit 1
  }
}
