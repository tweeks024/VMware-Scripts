#
# Script Name: vmware-ConsolidateDisks.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   11.14.2014


##### MAIN #####

# Find all VMs where disks need consolidation and consolidate.  Log to file.  Used to work around bug in Commvault Simpana 9 where not all VM disks were correctly consolidated.
# Uses Microsoft Technet Function for Write-Log from https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0

. c:\scripts\Function-Write-Log.ps1

Add-PSSnapin vmware.vimAutomation.core
$File = "D:\Scripts\VMware-ConsolidateDisks\log.txt"
Connect-VIServer vcenter
$VM = 'Get-VM | Where-Object {$_.Extensiondata.Runtime.ConsolidationNeeded}'

Get-VM | Where-Object {$_.Extensiondata.Runtime.ConsolidationNeeded} | ForEach-Object {$_.ExtensionData.ConsolidateVMDisks()}

Write-Log -Message "$VM" -Path C:\Scripts\VMDiskConsolidate\output.log


##### Alerting #####

#Get log output.  If any failures, send failure report otherwise send success report.

$LogOuput = Get-Content C:\scripts\VMDiskConsolidate\output.log
$Body = Write-Output $LogOuput | Out-String
Send-MailMessage -to tom.weeks@corp.com -from "NTAlerts <ntalerts@corp.com>" -subject "VM Disks Consolidated" -body $Body -priority High -smtpServer mail.corp.com 

##### Log Maintenance #####

#Rename log to yyyy-MM-dd.log and then remove .log files older than 180 logs.  Log removed files to LogCleanup.txt.
        
Get-ChildItem C:\Scripts\VMDiskConsolidate\out* | Rename-Item -NewName "$(get-date -f yyyy-MM-dd).log"

$Now = Get-Date
$Days = "180"
$TargetFolder = "C:\Scripts\VMDiskConsolidate"
$Extension = "*.log"
$LastWrite = $Now.AddDays(-$Days)

$Files = Get-ChildItem $TargetFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($File in $Files) 
    {
    if ($File -ne $NULL)
        {
        Write-Output "$Now Deleting File $File"  >> C:\Scripts\VMDiskConsolidate\LogCleanup.txt
        Remove-Item $File.FullName | Out-Null
        }
    else
        {
        Write-Output "$No New Files to Delete!"  >> C:\Scripts\VMDiskConsolidate\LogCleanup.txt
        }
    }