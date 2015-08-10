#
# Script Name: vmware--VM-reIP.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   11.18.2013


##### MAIN #####

# Re-IP VMs using VM tools guest agent and then change portgroup.


Connect-VIServer vcenter
  
$HostCred = $Host.UI.PromptForCredential(“Please enter credentials”, “Enter ESX host credentials”, “”, “”)
$GuestCred = $Host.UI.PromptForCredential(“Please enter credentials”, “Enter Guest credentials”, “”, “”)

$vmlist = Import-CSV C:\scripts\ReIPVMs.csv
 
foreach ($item in $vmlist) {
 

  $vmname = $item.vmname
  $ipaddr = $item.ipaddress
  $subnet = $item.subnet
  $gateway = $item.gateway
  $pdns = $item.pdns
  $sdns = $item.sdns
  $oldnetname = $item.oldnetname
  $newnetname = $item.newnetname
 

  $GuestInterface = Get-VMGuestNetworkInterface -VM $vmname -HostCredential $HostCred -GuestCredential $GuestCred -Name LAN

  Set-VMGuestNetworkInterface -VMGuestNetworkInterface $GuestInterface -HostCredential $HostCred -GuestCredential $GuestCred -IP $ipaddr -Netmask $subnet -Gateway $gateway -DNS $pdns,$sdns	
}

pause 30

$vmlist2 = Import-CSV C:\scripts\ReIPVMs.csv

foreach ($item in $vmlist2) {
 
  $vmname = $item.vmname
  $oldnetname = $item.oldnetname
  $newnetname = $item.newnetname	

	Get-VM $vmname | Get-NetworkAdapter | ?{$_.networkname -eq $oldnetname} | Set-NetworkAdapter -NetworkName $newnetname -Confirm:$false
		}