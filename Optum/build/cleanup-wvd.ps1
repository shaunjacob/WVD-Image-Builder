param(
  [string] $Hostpool = 'OptumServe-Test',
  [string] $ResourceGroup = 'WVD-RG'
)

. "$PSScriptRoot/functions.ps1"

CleanupWVDObjects -Hostpool $Hostpool -ResourceGroup $ResourceGroup
