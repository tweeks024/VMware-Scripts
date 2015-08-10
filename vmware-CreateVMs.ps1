#
# Script Name: vmware-CreateVMs.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   11.18.2013


##### MAIN #####

# Take a csv and use values to provision new VMs.  Set-IP on VM and change network portgroup label.


$HostCred = $Host.UI.PromptForCredential(“Please enter credentials”, “Enter ESX host credentials”, “”, “”)
$GuestCred = $Host.UI.PromptForCredential(“Please enter credentials”, “Enter Guest credentials”, “”, “”)

$vmlist = Import-CSV C:\scripts\CreateVMs.csv

foreach ($item in $vmlist) {

$template = $item.template
$vmname = $item.vmname
$vmhost = $item.vmhost
$datastore = $item.datastore
$customization = $item.customization

New-VM -Template $template -Name $vmname -VMHost $vmhost -Datastore $datastore -OSCustomizationSpec $customization
Start-VM $vmname

}

timeout 600


foreach ($item in $vmlist) {
 
  $vmname = $item.vmname
  $ipaddr = $item.ipaddress
  $subnet = $item.subnet
  $gateway = $item.gateway
  $pdns = $item.pdns
  $sdns = $item.sdns
  $oldnetname = $item.oldnetname
  $newnetname = $item.newnetname
 

  $GuestInterface = Get-VMGuestNetworkInterface -VM $vmname -HostCredential $HostCred -GuestCredential $GuestCred -Name "LAN"

  Set-VMGuestNetworkInterface -VMGuestNetworkInterface $GuestInterface -HostCredential $HostCred -GuestCredential $GuestCred -IP $ipaddr -Netmask $subnet -Gateway $gateway -DNS $pdns,$sdns	
}


foreach ($item in $vmlist) {
 
 $vmname = $item.vmname
 $oldnetname = $item.oldnetname
 $newnetname = $item.newnetname	

	Get-VM $vmname | Get-NetworkAdapter | ?{$_.networkname -eq $oldnetname} | Set-NetworkAdapter -NetworkName $newnetname -Confirm:$false
		}