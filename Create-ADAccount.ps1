Function Create-AdAccount{
    [cmdletbinding()]
    param(
    [Parameter(Mandatory)]
    [string]$Mirror,

    [Parameter(Mandatory)]
    [string]$FirstName,

    [Parameter(Mandatory)]
    [string]$LastName,

    [Parameter(Mandatory)]
    [string]$Title,

    [Parameter()]
    [ValidateNotNullorEmpty()]
    [bool]$Email
    )
# Ask for all information needed
Get-AdUser -Identity $Mirror
$Answer = Read-Host "Is this the correct mirror? (y or n)"

While($Answer -ne 'y') {
$Mirror = Read-Host "Mirror User"
Get-AdUser -Identity $Mirror
$Answer = Read-Host "Is this the correct mirror? (y or n)"

} 

$Finitial = 1
$Template = Get-AdUser -Identity $Mirror -Properties Title,Office,Manager,Department,ScriptPath,HomeDirectory,Company
$Username = $LastName+$FirstName.Substring(0,$Finitial) # Username=firstInitialLastName (e.g. User=Dexter Morgan, Username=morgand)
$Password = ConvertTo-SecureString -String "TacoBell01" -AsPlainText -Force
$Wholename = $FirstName + " " + $LastName

Do {
$User = $null
Write-Host "If you see an error message here, that's ok..."
$User = Get-ADUser $username -ErrorAction SilentlyContinue
If ($User)
{ Write-Host "Username: $username already exists. Adding another letter"
$username = $LastName+$FirstName.Substring(0,$Finitial++)
}
Else
{ $nullexit = $username
}
} Until ($nullexit -ne $null)

If ($email )
{New-ADUser `
-Instance($template) `
-Path($template.DistinguishedName -replace '^cn=.+?(?<!\\),') `
-DisplayName("$FirstName $LastName") `
-Name("$wholename") `
-GivenName($FirstName) `
-Surname($LastName) `
-SamAccountName($username) `
-UserPrincipalName($username +'@foobar.com') `
-AccountPassword($password) `
-ChangePasswordAtLogon($true) `
-Enabled($true) `
-EmailAddress("$FirstName" + "." + "$LastName" + "@foobar.com") `
-HomeDrive("H:") `
-HomeDirectory("\\foobar\" + $username) `
-Description($Title)
}
Else
{New-ADUser `
-Instance($template) `
-Path($template.DistinguishedName -replace '^cn=.+?(?<!\\),') `
-DisplayName("$FirstName $LastName") `
-Name("$wholename") `
-GivenName($FirstName) `
-Surname($LastName) `
-SamAccountName($username) `
-UserPrincipalName($username +'@foobar.com') `
-AccountPassword($password) `
-ChangePasswordAtLogon($true) `
-Enabled($true) `
-HomeDrive("H:") `
-HomeDirectory("\\foobar\" + $username) `
-Description($Title)
}
# Copy all groups Template is part of to new User Object
(Get-ADUser $Template -Properties memberOf).memberOf | ForEach { Add-ADGroupMember $_ $username }
}