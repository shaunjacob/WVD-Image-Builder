# <ArtifactURL> is string replaced during build time
$winui_url = "<ArtifactURL>"
$output_file = "C:\assets\LHI.MEDnet.zip"
$expand_dir = "C:\Program Files (x86)\LHI.MEDnet"

Set-TimeZone -Name "Central Standard Time"

if (! (Test-Path -LiteralPath C:\assets)) {
    mkdir C:\assets
}

if (! (Test-Path -LiteralPath $output_file)) {
    Invoke-WebRequest -Uri $winui_url -OutFile $output_file
}

if (! (Test-Path -LiteralPath $expand_dir)) {
  mkdir "$expand_dir"
}

Expand-Archive -Path $output_file -DestinationPath $expand_dir -Force

##########################################
# SQL Management Studio
##########################################
$ssms_url = 'https://aka.ms/ssmsfullsetup'
$ssms_outfile = 'C:\assets\SSMS-Setup-ENU.exe'
$ssms_install_args = '/Install /Quiet /Norestart'

Invoke-WebRequest -Uri $ssms_url -outfile $ssms_outfile
& $ssms_outfile $ssms_install_args.split(' ')
