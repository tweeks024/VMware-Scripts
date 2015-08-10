#
# Script Name: vmware-change-network.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   7.21.2014


##### MAIN #####

# Switch VMs from one portgroup to another.  Run a ping test to ensure change was successful.  If fails, changes are rolled back.  Designed to move from standard virtual switches to VDS switches.

$vmlist = Import-CSV C:\scripts\VMs.csv

foreach ($item in $vmlist) {

 $vmname = $item.vmname
 $oldnetname = $item.oldnetname
 $newnetname = $item.newnetname
 $ipaddress = $item.ipaddress


	Get-VM $vmname | Get-NetworkAdapter | ?{$_.networkname -eq $oldnetname} | Set-NetworkAdapter -NetworkName $newnetname -Confirm:$false
	
	$Status = (Test-Connection $ipaddress -BufferSize 16 -Count 1 -ea 0 -quiet)
	
	if ($Status -ne "True") 
		{
		Get-VM $vmname | Get-NetworkAdapter | ?{$_.networkname -eq $newnetname} | Set-NetworkAdapter -NetworkName $oldnetname -Confirm:$false
		Write-Output "Network Migration Failure for $ipaddress"  >> C:\Scripts\NetChangeLog.txt
		}
	else 
		{
		Write-Output "Network Migration Success for $ipaddress"  >> C:\Scripts\NetChangeLog.txt
		}
}