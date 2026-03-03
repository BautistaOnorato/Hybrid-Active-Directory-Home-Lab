# 12 – Exchange Online Configuration

---

## 🎯 Objective

Configure Exchange Online shared mailbox functionality for the Finance department, implementing:

- Mail-enabled security group for access management  
- Shared mailbox creation  
- Full Access and Send As delegation  
- AutoMapping validation  
- Functional testing in Outlook Desktop (Classic)  

---

## 🏗 Architecture Overview

### Logical Access Model

```
Finance Users
        ↓
MSG-Finance-Mailbox (Mail-Enabled Security Group)
        ↓
Shared Mailbox Permissions (FullAccess + Send As)
        ↓
finance@bocorp.online
```

---

## 🧱 Design Decisions

- Permissions are assigned directly to users via script.  
- Membership is managed through a Mail-Enabled Security Group.  
- AutoMapping is enabled for seamless user experience.  
- No nested on-prem group delegation is used due to hybrid resolution limitations.  

---

## 🔹 Step 1 – Create Mail-Enabled Security Group (Admin Center)

The group is used to centrally manage membership.

### Procedure

1. Navigate to **Teams & Groups** → **Active teams & groups**
2. Click **Security groups**
3. Click **Add a mail-enabled security group**
4. Configure:
   - Name: `MSG-Finance-Mailbox`
   - Email: `financesg@bocorp.online`
6. Assign Finance users as members
7. Complete group creation

---

## 🔹 Step 2 – Create Shared Mailbox (Admin Center)

### Procedure

1. Navigate to **Teams & Groups** → **Shared mailboxes**
2. Click **Add a shared mailbox**
3. Configure:
   - Name: Finance Shared Mailbox
   - Email: `finance@bocorp.online`
4. Save

---

## 🔹 Step 3 – Assign Permissions via Script

Permissions assigned:

- FullAccess  
- Send As  
- AutoMapping enabled  

### Script Used
**Script:** [`finance-mailbox-permissions.ps1`](/scripts/finance-mailbox-permissions.ps1)

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

## 🔹 Step 4 – Validation

### Verify Full Access

```powershell
Get-MailboxPermission finance@bocorp.online |
Where-Object {$_.User -like "*@*"} |
Select User,AccessRights
```

#### Result
```
User                       AccessRights
----                       ------------
carlosmendez@bocorp.online {FullAccess}
analopez@bocorp.online     {FullAccess}
luisgarcia@bocorp.online   {FullAccess}
mariatorres@bocorp.online  {FullAccess}
```

### Verify Send As

```powershell
Get-RecipientPermission finance@bocorp.online |
Where-Object {$_.Trustee -like "*@*"} |
Select Trustee,AccessRights
```

#### Result
```
User                       AccessRights
----                       ------------
carlosmendez@bocorp.online {SendAs}
analopez@bocorp.online     {SendAs}
luisgarcia@bocorp.online   {SendAs}
mariatorres@bocorp.online  {SendAs}
```

---

## 🔹 Step 5 – Functional Testing

### Outlook Desktop (Classic)

Test scenario executed using a Finance user account:

- Shared mailbox appears automatically (AutoMapping validated)  
- Mailbox opens without credential prompt  
- Email successfully sent as `finance@bocorp.online`  
- Sender identity displays as Finance mailbox  

---

## ✅ Outcome

The Finance shared mailbox:

- Is centrally managed  
- Uses secure delegated access  
- Supports Send As functionality  
- Auto-maps correctly in Outlook