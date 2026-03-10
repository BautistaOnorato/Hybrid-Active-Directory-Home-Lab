$installedApp = Get-WmiObject -Class Win32_Product | 
    Where-Object { $_.Name -like "*Action1*" }

if ($null -eq $installedApp) {
    $msiPath = "\\bocorp.local\SYSVOL\bocorp.local\Action1\action1_remote_agent.msi"
    Start-Process -FilePath "msiexec.exe" `
                  -ArgumentList "/i `"$msiPath`" /qn /norestart" `
                  -Wait
}