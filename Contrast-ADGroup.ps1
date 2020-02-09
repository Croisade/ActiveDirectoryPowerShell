Function Contrast-ADGroup{
      [cmdletbinding()]
      param(
          [Parameter(Mandatory)]
          [string]$Primary,

          [Parameter(Mandatory)]
          [string]$Secondary
      )
    Write-Host "$Primary is on the left, $Secondary is on the right"
    Compare-Object -ReferenceObject (Get-AdPrincipalGroupMembership $primary | select name | sort-object -Property name) -DifferenceObject (Get-AdPrincipalGroupMembership $Secondary | select name | sort-object -Property name) -property name -passthru

    
}


