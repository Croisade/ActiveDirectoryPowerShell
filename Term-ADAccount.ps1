Function Termination{

Get-ADUser -Identity $i -Properties MemberOf | ForEach-Object {
  $_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false
}

#Changes description to terminated + today's date
Set-ADUSER -identity $i -Description "TERMINATED $date"

#posts email address if a user has one
get-aduser -Identity $i -Property 'emailaddress' | Select-Object -property emailaddress

#Disabled account
Disable-ADAccount -Identity $i

#converts string to object
$userObject = Get-ADUser -Identity $i

#moves to disabled
$userObject | Move-ADObject -TargetPath "OU=DisabledAccounts,DC=nfii,DC=com"

Write-Host "$i has been disabled"
}
Function EndScript{
if ($Host.Name -eq "ConsoleHost")
{
    Write-Host "Press any key to continue..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}
}

$date = Get-Date -UFormat "%m / %d"

#If there are no arguments, terminate a single user.
If($args.Length -eq 0){

#reads input for a user. Asks for confirmation that this is the correct user. If any character but 'y' is selected it will repeat
While($answer -ne 'y') {
$i = Read-Host "Terminated User:"
Get-AdUser -Identity $i
$answer = Read-Host "Is this the correct mirror? (y or n)"
}

Termination
EndScript 
}
Else{
#this script can also accept multi arguments for multiple employee termination.
foreach ($i in $args){

Get-AdUser -Identity $i
}

If( $args -ne $null){
$answer = Read-Host "Is this the correct mirror? (y or n)"
}

While($answer -ne 'y') {
$user1 = Read-Host "Terminated User:"
foreach ($i in $args){

Get-AdUser -Identity $i
$answer = Read-Host "Is this the correct mirror? (y or n)"
}

}


foreach ($i in $args){
Termination
}
EndScript
}