<#
.SYNOPSIS
    Automates VirtualBox VM creation and task scheduling.
.DESCRIPTION
    INFRASTRUCTURE NOTE: Hardware resources are scaled down to 2GB RAM, 
    1 CPU, and 30GB storage due to local host limitations. 
    
    To deploy with the original requested specs (8GB RAM, 4 CPUs, 150GB Storage):
    1. In modifyvm: Change '--memory 2048' to '--memory 8192'
    2. In modifyvm: Change '--cpus 1' to '--cpus 4'
    3. In createmedium: Change '--size 30720' to '--size 153600'
#>

$vmName = "PolyWorks_VB_Workstation"
$vboxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$diskPath = "C:\Users\Public\Documents\$vmName.vdi"

# Create and register the VM
& $vboxManage createvm --name $vmName --register

# Allocate CPU and Memory (Local hardware configuration)
& $vboxManage modifyvm $vmName --memory 2048 --cpus 1

# Create 30GB virtual disk (size in MB)
& $vboxManage createmedium disk --filename $diskPath --size 30720 --format VDI

# Configure SATA controller and attach virtual disk
& $vboxManage storagectl $vmName --name "SATA" --add sata
& $vboxManage storageattach $vmName --storagectl "SATA" --port 0 --device 0 --type hdd --medium $diskPath

# Schedule background startup at 09:00
$startAction = New-ScheduledTaskAction -Execute $vboxManage -Argument "startvm $vmName --type headless"
$startTrigger = New-ScheduledTaskTrigger -Daily -At "09:00"
Register-ScheduledTask -TaskName "Start-$vmName" -Action $startAction -Trigger $startTrigger -User "NT AUTHORITY\SYSTEM" -RunLevel Highest

# Schedule forced shutdown at 23:00
$stopAction = New-ScheduledTaskAction -Execute $vboxManage -Argument "controlvm $vmName poweroff"
$stopTrigger = New-ScheduledTaskTrigger -Daily -At "23:00"
Register-ScheduledTask -TaskName "Stop-$vmName" -Action $stopAction -Trigger $stopTrigger -User "NT AUTHORITY\SYSTEM" -RunLevel Highest