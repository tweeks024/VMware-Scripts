# Script Name: vmware-DatastoreStatistics.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   8.26.2015


##### MAIN #####
# Uses Microsoft Technet Function for Write-Log from https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0

. c:\scripts\Function-Write-Log.ps1


$DataStores = Get-DataStore


forEach ($item in $DataStores) {

$VMCount = Get-Datastore $item.name | Select @{N="NumVM";E={@($_ | Get-VM).Count}} | Select -ExpandProperty NumVM

$DataStoreStats = Get-DataStore $item.name |  Get-View

$Capacity = $DataStoreStats | select -expandproperty summary | select @{N="Capacity"; E={[math]::round($_.Capacity/1GB,2)}} | Select -ExpandProperty Capacity
$Free = $DataStoreStats | select -expandproperty summary | select @{N="Free";E={[math]::round($_.FreeSpace/1GB,2)}} | Select -ExpandProperty Free
$Provisioned = $DataStoreStats | select -expandproperty summary | select @{N="Provisioned"; E={[math]::round(($_.Capacity - $_.FreeSpace + $_.Uncommitted)/1GB,2) }} | Select -ExpandProperty Provisioned

Write-Log -Message "$item.name,$VMCount,$Capacity,$Free,$Provisioned" -Path c:\scripts\datastores.csv

}