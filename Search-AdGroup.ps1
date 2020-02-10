function Search-AdGroup{
    [cmdletbinding()]
    param(
    [parameter(Mandatory)]
    [string]$Group
    )
    Get-ADGroup -Filter {Name -like $Group}  | Select-Object -Property SamAccountName
}

