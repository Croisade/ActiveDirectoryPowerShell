function Add-ADGroup {
	[cmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$UserName,

		[Parameter(Mandatory)]
		[string]$Group
	)
	
	Add-ADGroupMember -Identity $Group -Members $UserName		
	$Members = Get-ADGroupMember -Identity $Group | Select -ExpandProperty SAMAccountNAme

	If ($Members -contains $UserName) {
      	Write-Host "$UserName has been added to $Group" -ForegroundColor Green
 	} 
	Else {
        Write-Host "$UserName has not been added to $Group" -ForegroundColor Red
}
}


