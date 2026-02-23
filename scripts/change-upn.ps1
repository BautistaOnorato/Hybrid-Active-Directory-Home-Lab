Get-ADUser -Filter * -SearchBase "OU=Departments,DC=bocorp,DC=local" |
ForEach-Object {
    $newUPN = $_.SamAccountName + "@bocorp.online"
    Set-ADUser $_ -UserPrincipalName $newUPN
}