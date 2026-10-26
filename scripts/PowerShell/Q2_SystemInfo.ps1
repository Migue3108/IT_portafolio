# Format timestamp to comply with Windows file naming conventions
$timestamp = Get-Date -Format "dd-MM-yy-HH-mm"
$destination = "C:\temp\SystemInfo${timestamp}.txt"
# Ensure target directory exists
if (-not (Test-Path -Path "C:\temp")) {
New-Item -ItemType Directory -Path "C:\temp" | Out-Null
}
# 1. CPU Usage
$cpu = (Get-CimInstance -ClassName Win32_Processor |
Measure-Object -Property LoadPercentage -Average).Average
$cpuString = "CPU usage: $cpu%"
# 2. Memory Usage (CIM returns KB, divide by 1MB to get GB)
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$memTotalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$memFreeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$memUsedGB = $memTotalGB - $memFreeGB
$memPercentage = [math]::Round(($memUsedGB / $memTotalGB) * 100, 2)
$memString = "Memory usage: $memPercentage% ($memUsedGB GB used out of " +
"$memTotalGB GB Total | $memFreeGB GB Free)"
3
# 3. Disk Usage for C: (CIM returns Bytes, divide by 1GB)
$disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
$diskTotalGB = [math]::Round($disk.Size / 1GB, 2)
$diskFreeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
$diskUsedGB = $diskTotalGB - $diskFreeGB
$diskPercentage = [math]::Round(($diskUsedGB / $diskTotalGB) * 100, 2)
$diskString = "Disk usage (C:): $diskPercentage% ($diskUsedGB GB used out of " +
"$diskTotalGB GB Total | $diskFreeGB GB Free)"
# Store strings in an array and export
$sysInfoArray = @(
"--- System Info Report ---",
$cpuString,
$memString,
$diskString,
"--------------------------"
)
$sysInfoArray | Out-File -FilePath $destination -Encoding UTF8
$msg = "System metrics successfully exported to: $destination"
Write-Host $msg -ForegroundColor Green