Write-Host "Starting shared mailbox permission assignment..."

Connect-ExchangeOnline -ShowProgress $true

$groupMembers = Get-DistributionGroupMember -Identity "MSG-Finance-Mailbox"

foreach ($member in $groupMembers) {

    Write-Host "Processing $($member.PrimarySmtpAddress)..."

    # Grant Full Access with AutoMapping
    Add-MailboxPermission `
        -Identity "finance@bocorp.online" `
        -User $member.PrimarySmtpAddress `
        -AccessRights FullAccess `
        -InheritanceType All `
        -AutoMapping $true

    # Grant Send As
    Add-RecipientPermission `
        -Identity "finance@bocorp.online" `
        -Trustee $member.PrimarySmtpAddress `
        -AccessRights SendAs `
        -Confirm:$false
}

Write-Host "Completed successfully."