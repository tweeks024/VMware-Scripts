#
# Script Name: vmware-ConsolidateDisks.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   11.14.2014


##### MAIN #####

# Find all VMs where disks need consolidation and consolidate.  Log to file.  Used to work around bug in Commvault Simpana 9 where not all VM disks were correctly consolidated.

Add-PSSnapin vmware.vimAutomation.core
$File = "D:\Scripts\VMware-ConsolidateDisks\log.txt"
Connect-VIServer vcenter
echo "################ Starting Maintenance ################" | Out-File $File -append 
Get-Date | Out-File $File -append
echo "Attempting to consolidate disks for the following VMs:" | Out-File $File -append 
Get-VM | Where-Object {$_.Extensiondata.Runtime.ConsolidationNeeded} | Out-File $File -append
Get-VM | Where-Object {$_.Extensiondata.Runtime.ConsolidationNeeded} | ForEach-Object {$_.ExtensionData.ConsolidateVMDisks()} | Out-File $File -append
echo "|||||||||||||||| Maintenance Complete ||||||||||||||||" | Out-File $File -append