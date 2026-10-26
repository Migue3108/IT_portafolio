<#
.SYNOPSIS
Automated folder backup with a 10-folder retention limit.
#>
$Src = "C:\sourcefolder"
$Dst = "C:\destination"
$TaskName = "AutoBackup-SourceFolder"
# 1. Task Registration
if (!(Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)) {
$PSArgs = "-WindowStyle Hidden -File '$PSCommandPath'"
$Act = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $PSArgs
$Trg = New-ScheduledTaskTrigger -Daily -At "02:00"
$TaskParams = @{
TaskName = $TaskName
Action = $Act
Trigger = $Trg
User = "SYSTEM"
RunLevel = "Highest"
}
Register-ScheduledTask @TaskParams
Write-Host "[INIT] Task registered successfully." -ForegroundColor Cyan
}
# 2. Execute Backup
$Timestamp = Get-Date -Format 'MMddyyyy-HHmm'
$Tgt = Join-Path $Dst "sourcefolder_$Timestamp"
if (!(Test-Path $Dst)) { New-Item -ItemType Directory -Path $Dst > $null }
if (Test-Path $Src) {
Copy-Item -Path $Src -Destination $Tgt -Recurse -Force
Write-Host "[SUCCESS] Backup completed at: $Tgt" -ForegroundColor Green
} else {
Write-Host "[ERROR] Source folder '$Src' not found." -ForegroundColor Red
exit
}
# 3. Retention Policy
$OldBackups = Get-ChildItem -Path $Dst -Directory -Filter "sourcefolder_*" |
Sort-Object CreationTime -Descending |
Select-Object -Skip 10
if ($OldBackups) {
$OldBackups | Remove-Item -Recurse -Force
Write-Host "[CLEANUP] $($OldBackups.Count) backups removed." -ForegroundColor Yellow
} else {
Write-Host "[INFO] Retention checked. <= 10 folders." -ForegroundColor DarkGray
}