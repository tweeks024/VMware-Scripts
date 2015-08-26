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


$VMCount = Get-Datastore $DataStores.Name | Select @{N="NumVM";E={@($_ | Get-VM).Count}}

$DataStoreStats = Get-DataStore $DataStores.Name |  Get-View

$Capacity = $DataStoreStats | select -expandproperty summary | select @{N="Capacity (GB)"; E={[math]::round($_.Capacity/1GB,2)}}
$Free = $DataStoreStats | select -expandproperty summary | select @{N="Free Space (GB)";E={[math]::round($_.FreeSpace/1GB,2)}}
$Provisioned = $DataStoreStats | select -expandproperty summary | select @{N="Provisioned (GB)"; E={[math]::round(($_.Capacity - $_.FreeSpace + $_.Uncommitted)/1GB,2) }}

Write-Log -Message "$DataStores.Name,$VMCount,$Capacity,$Free,$Provisioned" -Path c:\scripts\datastores.csv


}