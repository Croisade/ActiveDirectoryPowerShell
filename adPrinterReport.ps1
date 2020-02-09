$printerlist = import-csv ".\printerlist.csv" -header Value,Name,Description
$outfile = ".\PrinterReport.txt"
$SNMP = new-object -ComObject olePrn.OleSNMP
$ErrorActionPreference= 'silentlycontinue'

Function Email
{
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
$Username = "someone@example.com"
#Has to be ran as the same account that created the password
#Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File -FilePath username@domain.net.securestring
$Password = Get-content -Path .\EmailPassword.securestring | ConvertTo-SecureString

$to = "Example@someone.com"
#$cc = "user2@domain.com"
$subject = "Service Desk Printer Report"
$body = (Get-Content .\PrinterReport.txt) -join "`n"

$message = New-Object System.Net.Mail.MailMessage
$message.subject = $subject
$message.body = $body
$message.to.add($to)
#$message.cc.add($cc)
$message.from = $username

$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$smtp.send($message)
}
Function Status
{
$statustree = $snmp.gettree("43.18.1.1.8")
$status = $statustree|? {$_ -notlike "print*"} #Filters out unwanted warnings, including low ink warnings
$status = $status|? {$_ -notlike "*bypass*"}
$status = $status|? {$_ -notlike "*low*"}
$serial = $snmp.get(".1.3.6.1.2.1.43.5.1.1.17.1") #serial number
[string]$name = $snmp.get(".1.3.6.1.2.1.1.5.0")

[int]$blackpercentremaining = $snmp.get(".1.3.6.1.2.1.43.11.1.1.9.1.1")
[int]$cyanpercentremaining = $snmp.get(".1.3.6.1.2.1.43.11.1.1.9.1.2")
[int]$magentapercentremaining = $snmp.get(".1.3.6.1.2.1.43.11.1.1.9.1.3")
[int]$yellowpercentremaining = $snmp.get(".1.3.6.1.2.1.43.11.1.1.9.1.4")

if ($status.length -gt 0 -or $yellowpercentremaining -le 5 -or $magentapercentremaining -le 5 -or $cyanpercentremaining -le 5 -or $blackpercentremaining -le 5){write ($p.description +", " + $p.value + ", " + $name + ", " + $serial |add-content $outfile)}
if ($status.length -gt 0){write ($status)|add-content $outfile}
if ($blackpercentremaining -le 5){write "$($blackpercentremaining)% Black Toner" |add-content $outfile}
if ($cyanpercentremaining -le 5){write "$($cyanpercentremaining)% Cyan Toner" |add-content $outfile}
if ($magentapercentremaining -le 5){write "$($magentapercentremaining)% Magenta Toner" |add-content $outfile}
if ($yellowpercentremaining -le 5){write "$($yellowpercentremaining)% Yellow Toner" |add-content $outfile}
if ($status.length -gt 0 -or $yellowpercentremaining -le 5 -or $magentapercentremaining -le 5 -or $cyanpercentremaining -le 5 -or $blackpercentremaining -le 5){Write " " | Add-Content $outfile} #formatting
}

Function BStatus
{
$statustree = $snmp.gettree("43.18.1.1.8")
$status = $statustree|? {$_ -notlike "print*"} #status, including low ink warnings
$status = $status|? {$_ -notlike "*bypass*"}
$status = $status|? {$_ -notlike "*low*"}
$serial = $snmp.get(".1.3.6.1.2.1.43.5.1.1.17.1")
[string]$name = $snmp.get(".1.3.6.1.2.1.1.5.0")

[int]$blackpercentremaining = $snmp.get(".1.3.6.1.2.1.43.11.1.1.9.1.1")

if ($blackpercentremaining -le 5 -or $status.length -gt 0){write ($p.description +", " + $p.value + ", " + $name + ", " + $serial |add-content $outfile)}
if ($status.length -gt 0){write ($status)|add-content $outfile}
if ($blackpercentremaining -le 5){write "$($blackpercentremaining)% Black Toner" |add-content $outfile}
if ($status.length -gt 0 -or $blackpercentremaining -le 5){Write " " | Add-Content $outfile}
}

Write "Service Desk Printer Status Report"|out-file $outfile
write " "|add-content $outfile
 
foreach ($p in $printerlist){
 
if (!(test-connection $p.Value -Quiet -count 1)){write ($p.value + " is offline")|add-content $outfile}
if (test-connection $p.value -quiet -count 1){
$snmp.open($p.value,"public",2,3000)
$printertype = $snmp.Get(".1.3.6.1.2.1.25.3.2.1.3.1")
}
 
if ($printertype -like "*iR-ADV 6575*"){ 
BStatus
}
 
if ($printertype -like "*iR-ADV 8505 III*"){
BStatus
}

if ($printertype -like "*iR-ADV 4525*"){ 
BStatus
}

if ($printertype -like "*Canon iR-ADV C7565*"){ 
Status
}
 
if ($printertype -like "*MF732C/734C/735C*"){
Status
}
 
if ($printertype -like "*Canon iR-ADV C5560*"){
Status
}
 
 
 
}

#&$outfile
Email
