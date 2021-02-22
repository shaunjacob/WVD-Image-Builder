param(
    [string] $PsUsername = 'svc_processserver',
    [string] $PsDomain = 'MEDNETCLOUDPOC',
    [string] $PsPassword
)

Set-TimeZone -Name "Central Standard Time"

Start-Process -FilePath "c:\assets\Autologon64.exe" -ArgumentList "$PsUsername","$PsDomain","$PsPassword","/accepteula"

# C:\LHIProjects\LHI.MEDnet\LHI.MEDnet.ProcessServerUI\bin\LHI.MedNet.ProcessServer.exe
# Make domain user that PS is runnign as a local admin
0..9 | ForEach {
  $Sta = New-ScheduledTaskAction -Execute "C:\LHIProjects\LHI.MEDNet\LHI.MedNet.ProcessServer.exe"
  $Stt = New-ScheduledTaskTrigger -AtLogon -User "$PsDomain\$PSUsername"
  Register-ScheduledTask -Trigger $Stt -Action $Sta -TaskName "Start Process Server $_" -User "$PsDomain\$PSUsername" -Force
}

Restart-Computer -Confirm:$false -Force
