#
# Script Name: vmware-CreateVLANsOnVDSSwitch.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   8.21.2014


##### MAIN #####

# Take a list of vlans and create them on a VDS switch.  


$VLanList = (Import-csv c:\scripts\vlans.csv)

foreach ($VLan in $VLanList) {
		$VlanName = $VLan.Name
		$VlanID = $VLan.VLAN
		New-VDPortGroup -VDSwitch dvSwitch01 -name $VLanName -vlanid $VlanID -NumPorts 8
	}