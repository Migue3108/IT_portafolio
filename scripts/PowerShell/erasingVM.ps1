# 1. Remove the Scheduled Tasks
Unregister-ScheduledTask -TaskName "Start-PolyWorks_VB_Workstation" -Confirm:$false
Unregister-ScheduledTask -TaskName "Stop-PolyWorks_VB_Workstation" -Confirm:$false
Write-Host "Scheduled tasks removed." -ForegroundColor Yellow

# 2. Define VirtualBox paths
$vmName = "PolyWorks_VB_Workstation"
$vboxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# 3. Power off the VM (in case it is currently running)
& $vboxManage controlvm $vmName poweroff

# 4. Unregister and delete the VM along with its virtual hard disk (.vdi)
& $vboxManage unregistervm $vmName --delete
Write-Host "Virtual Machine and disk files deleted." -ForegroundColor Yellow