# 12 – Exchange Online Configuration

---

## 🎯 Objective

Configure a shared mailbox for the Finance department in Exchange Online, implementing centralized email access with proper delegation and access management.

This section covers:

- Creating a Mail-Enabled Security Group to manage shared mailbox membership
- Creating the Finance shared mailbox in the Microsoft 365 Admin Center
- Assigning Full Access and Send As permissions via PowerShell
- Validating AutoMapping and Send As functionality in Outlook Desktop

---

## 🏗 Architecture Overview

```
Finance Users
        ↓
MSG-Finance-Mailbox (Mail-Enabled Security Group)
        ↓
Shared Mailbox Permissions (Full Access + Send As)
        ↓
finance@bocorp.online
```

### Design Decisions

| Decision | Justification |
|----------|--------------|
| Mail-Enabled Security Group for membership management | Centralizes access control — adding or removing a user from the group automatically reflects in mailbox access |
| Permissions assigned via PowerShell script | Ensures consistent assignment across all group members without manual per-user configuration |
| AutoMapping enabled | The shared mailbox appears automatically in Outlook without requiring users to add it manually |
| No nested on-prem group delegation | Hybrid resolution limitations prevent on-prem groups from being used directly for Exchange Online permission assignment |

---

## 1️⃣ Create Mail-Enabled Security Group

Navigate to the Microsoft 365 Admin Center and create the security group:

```
https://admin.cloud.microsoft → Teams & Groups → Active teams & groups → Security groups → Add a mail-enabled security group
```

Configure the group with the following settings:

| Setting | Value |
|---------|-------|
| Name | MSG-Finance-Mailbox |
| Email | `financesg@bocorp.online` |

Add all Finance department users as members of the group.

---

## 2️⃣ Create the Finance Shared Mailbox

Navigate to the Microsoft 365 Admin Center and create the shared mailbox:

```
https://admin.cloud.microsoft → Teams & Groups → Shared mailboxes → Add a shared mailbox
```

Configure the mailbox with the following settings:

| Setting | Value |
|---------|-------|
| Name | Finance Shared Mailbox |
| Email | `finance@bocorp.online` |

---

## 3️⃣ Assign Mailbox Permissions

Permissions are assigned to all members of `MSG-Finance-Mailbox` using a PowerShell script that iterates through the group membership and grants both Full Access and Send As on the shared mailbox.

### Script: [`finance-mailbox-permissions.ps1`](/scripts/finance-mailbox-permissions.ps1)

```powershell
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
```

---

## 🔎 Validation

### Verify Full Access Permissions

```powershell
Get-MailboxPermission finance@bocorp.online |
Where-Object { $_.User -like "*@*" } |
Select-Object User, AccessRights
```

Expected output:

```
User                            AccessRights
----                            ------------
carlosmendez@bocorp.online      {FullAccess}
analopez@bocorp.online          {FullAccess}
luisgarcia@bocorp.online        {FullAccess}
mariatorres@bocorp.online       {FullAccess}
```

---

### Verify Send As Permissions

```powershell
Get-RecipientPermission finance@bocorp.online |
Where-Object { $_.Trustee -like "*@*" } |
Select-Object Trustee, AccessRights
```

Expected output:

```
Trustee                         AccessRights
-------                         ------------
carlosmendez@bocorp.online      {SendAs}
analopez@bocorp.online          {SendAs}
luisgarcia@bocorp.online        {SendAs}
mariatorres@bocorp.online       {SendAs}
```

---

### Validate in Outlook Desktop

Test the following scenarios from a Finance user account in Outlook Desktop (Classic):

| Test | Expected Result |
|------|----------------|
| Shared mailbox visibility | Mailbox appears automatically in the folder pane (AutoMapping) |
| Open shared mailbox | Mailbox opens without a credential prompt |
| Send email as Finance mailbox | Sender identity displays as `finance@bocorp.online` |

---

## ✅ Outcome

After completing this section:

- `MSG-Finance-Mailbox` centralizes shared mailbox membership management.
- `finance@bocorp.online` is accessible by all Finance department users.
- Full Access and Send As permissions are assigned consistently via PowerShell.
- AutoMapping delivers the shared mailbox automatically in Outlook Desktop.
- Finance users can send email on behalf of the shared mailbox address.