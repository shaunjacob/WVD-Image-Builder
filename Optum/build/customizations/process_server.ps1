# <ArtifactURL> is string replaced at build time
$url = "<ArtifactURL>"
$assets_dir = 'C:\assets'
$deploy_dir = 'C:\LHIProjects\LHI.MEDNet'
$output_file = "$assets_dir\LHI.MedNet.ProcessServerUI.Development.zip"


$dirs = @(
    $assets_dir
    $deploy_dir
)

forEach ($d in $dirs) {
    if (! (Test-Path -LiteralPath "$d")) {
        mkdir -p "$d"
    }
}

if (! (Test-Path -LiteralPath $output_file)) {
    Invoke-WebRequest -Uri "$url" -OutFile "$output_file"
}

Expand-Archive -Path "$output_file" -DestinationPath "$deploy_dir" -Force

#########################################
# SysInternals Autologon
#########################################
Invoke-WebRequest -uri 'https://download.sysinternals.com/files/AutoLogon.zip' -OutFile "$assets_dir\AutoLogon.zip"
Expand-Archive -Path "$assets_dir\AutoLogon.zip" -DestinationPath $assets_dir -Force
