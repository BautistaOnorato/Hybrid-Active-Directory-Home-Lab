# Backup GPOs Script

$Date = Get-Date -Format "yyyy-MM-dd"

if (Test-Path -Path "C:\GPO-Backups") {
    Write-Host "GPO backup directory exists."
} else {
    New-Item -Path "C:\GPO-Backups" -ItemType Directory
}

$Path = "C:\GPO-Backups\$Date"

New-Item -Path $Path -ItemType Directory
Backup-GPO -All -Path $Path -Comment "Backup on $Date" -Verbose