param(
  [Parameter(Mandatory=$true)] [string] $version,
  [Parameter(Mandatory=$true)] [string] $ArtifactURL
)
Install-Module -Name 'Az.ImageBuilder' -AllowPrerelease -Confirm:$false -Force
Install-Module -Name 'Az.ManagedServiceIdentity' -AllowPrerelease -Confirm:$false -Force

Set-PSDebug -Trace 2

$build_script = "$(Join-Path $PSScriptRoot 'scripts' 'build.ps1')"

$template_file = "$(Join-Path $PSScriptRoot 'templates' 'ProcessServer.tpl.json')"
((Get-Content -path $template_file -Raw) -replace '<ArtifactURL>',$ArtifactURL) | Set-Content -Path $template_file

& "$build_script" -version "$version" -templateFilePath "$template_file" -srcSku "2019-Datacenter" -srcOffer "WindowsServer" -srcPublisher "MicrosoftWindowsServer" -destOffer 'ProcessServer' -ArtifactURL "$ArtifactURL"
