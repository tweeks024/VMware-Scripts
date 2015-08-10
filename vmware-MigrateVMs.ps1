#
# Script Name: vmware-MigrateVMs.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   4.14.2014


##### MAIN #####

# Migrate VMs to new hosts with different CPU family.  Update VM tools at after powered up on new hosts.

$items = Import-CSV C:\scripts\MigrateVMs.csv

foreach ($item in $items) {


$vmname = $item.vmname
$vmhost = $item.vmhost
$resourcepool = $item.resourcepool
$folder = $item.folder

Shutdown-VMGuest -VM $vmname -confirm:$false
timeout 75
Move-VM -VM $vmname -Destination $vmhost
Move-VM -VM $vmname -Destination $resourcepool
Move-VM -VM $vmname -Destination $folder
Start-VM $vmname
timeout 120
Update-Tools -VM $vmname

}