# 08 – Entra Domain Configuration and UPN Alignment

---

## 🎯 Objective

Configure a custom public domain in Microsoft Entra ID and align on-premises Active Directory User Principal Names (UPNs) to prepare the environment for hybrid identity synchronization.

This section covers:

- Verifying the custom domain `bocorp.online` in Microsoft Entra ID
- Adding an alternate UPN suffix to the on-premises Active Directory
- Updating all user accounts to use the new UPN suffix via PowerShell
- Validating UPN alignment before running Entra Connect

---

## 🏗 Architecture Overview

The internal Active Directory domain `bocorp.local` is a non-routable domain and cannot be used for Microsoft 365 authentication. To enable hybrid identity, users must authenticate to cloud services using a verified public domain.

```
On-Prem AD (bocorp.local)
        ↓
Alternate UPN Suffix added: bocorp.online
        ↓
Users updated: user@bocorp.local → user@bocorp.online
        ↓
Microsoft Entra ID (bocorp.online – verified)
        ↓
Microsoft 365 / Exchange Online / Intune
```

### Why UPN Alignment Is Required

| Problem | Solution |
|---------|----------|
| `bocorp.local` is non-routable and cannot be verified in Entra ID | Verify `bocorp.online` as a custom domain in Microsoft Entra ID |
| Users synchronized with `@bocorp.local` UPNs generate unverified domain warnings | Add `bocorp.online` as an alternate UPN suffix in on-prem AD |
| Cloud sign-in would use an unverified domain, causing authentication failures | Update all user UPNs to `@bocorp.online` before synchronization |

> Adding the alternate UPN suffix does **not** rename the domain. The internal domain remains `bocorp.local`. The suffix only allows users to be assigned a routable UPN for cloud authentication.

---

## 1️⃣ Verify the Custom Domain in Microsoft Entra ID

### 1.1 Add the Domain

Navigate to the Microsoft 365 Admin Center and add the custom domain:

```
https://admin.cloud.microsoft → Settings → Domains → Add domain
```

Enter `bocorp.online` and proceed to the verification step.

---

### 1.2 Create the DNS TXT Verification Record

Microsoft Entra ID generates a TXT record to verify ownership of the domain. The record must be added to the DNS zone of `bocorp.online` at the domain registrar.

| Type | Host | Value |
|------|------|-------|
| TXT | @ | MS=ms83153720 |

In **Hostinger**, navigate to:

```
Domains → DNS / Nameservers → Add Record
```

Create the record with the values above and save. Allow 5–15 minutes for DNS propagation, then return to the Microsoft 365 Admin Center and click **Verify**.

📸 **Domain verification successful in Microsoft Entra ID**

![Domain Verification Success](/screenshots/08/01.png)

---

## 2️⃣ Add Alternate UPN Suffix in Active Directory

On **DC-01**, open **Active Directory Domains and Trusts**:

```
Active Directory Domains and Trusts → Right-click the root node → Properties
```

Under **Alternative UPN suffixes**, add:

```
bocorp.online
```

Click **Apply** → **OK**.

📸 **Alternate UPN suffix bocorp.online added**

![Alternate UPN Suffix](/screenshots/08/02.png)

---

## 3️⃣ Update User Principal Names

All users in the `Departments` OU were updated to use the new UPN suffix via PowerShell.

### Script: [`change-upn.ps1`](/scripts/change-upn.ps1)

```powershell
Get-ADUser -Filter * -SearchBase "OU=Departments,DC=bocorp,DC=local" |
ForEach-Object {
    $newUPN = $_.SamAccountName + "@bocorp.online"
    Set-ADUser $_ -UserPrincipalName $newUPN
}
```

The script retrieves all user accounts under `OU=Departments`, preserves the existing `SamAccountName`, and updates only the UPN suffix from `@bocorp.local` to `@bocorp.online`.

---

## 🔎 Validation

### Verify the UPN Update

Open **Active Directory Users and Computers** on DC-01, navigate to any user account in the `Departments` OU, and confirm the UPN suffix on the **Account** tab:

```
User logon name: <username>@bocorp.online
```

📸 **User account showing updated UPN suffix**

![User UPN Updated](/screenshots/08/03.png)

### Verify DNS Propagation

Before proceeding to Entra Connect configuration, confirm the TXT record is resolving correctly:

```powershell
Resolve-DnsName -Name bocorp.online -Type TXT
```

---

## ✅ Outcome

After completing this section:

- `bocorp.online` is verified as a custom domain in Microsoft Entra ID.
- The alternate UPN suffix `bocorp.online` is registered in the on-premises Active Directory.
- All department users have been updated to authenticate as `user@bocorp.online`.
- The environment is fully prepared for directory synchronization with Microsoft Entra Connect.
