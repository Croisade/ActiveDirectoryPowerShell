Function Ad-Unlock{
  [cmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$Identity
  )
  Get-AdUser -Identity $Identity
  $Answer = Read-Host "Is this the correct user? (Y or N)"

  While($Answer -ne 'y') {
    $Identity = Read-Host "Template User"
    Get-AdUser -Identity $Identity
    $Answer = Read-Host "Is this the correct user? (Y or N)"
  }
  Unlock-ADAccount -Identity $Identity
  
  $lockedstatus = Get-Aduser $Identity -prop * | Select-Object lockedout
  If ($lockedstatus -eq "True") {
    Write-Host "$Identity is still locked" -ForegroundColor Red
  }
  Else{
    Write-Host "$Identity has been unlocked" -ForegroundColor Green
  }
}
