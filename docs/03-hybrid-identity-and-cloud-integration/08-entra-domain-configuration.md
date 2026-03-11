# 08 - Entra Domain Configuration and UPN Alignment

---

## 🎯 Objective

Configure and verify a custom public domain in Microsoft Entra ID and align on-premises Active Directory User Principal Names (UPNs) to ensure a clean and conflict-free hybrid identity deployment.

This section ensures:

- `bocorp.online` is verified in Microsoft Entra ID  
- On-prem users authenticate using a routable public domain  
- Hybrid synchronization does not generate duplicate objects  
- Microsoft 365 sign-in reflects enterprise identity standards  

---

## 🧠 Architectural Context

The internal Active Directory domain:

```
bocorp.local
```

is a non-routable domain and cannot be used for Microsoft 365 authentication.

To enable hybrid identity, users must authenticate using a verified public domain:

```
user@bocorp.online
```

This requires:

1. Verifying the custom domain in Microsoft Entra ID  
2. Adding an alternate UPN suffix in Active Directory  
3. Updating all user accounts to use the new UPN suffix  

---

## 1️⃣ Custom Domain Verification in Microsoft Entra ID

---

### 1.1 Add Custom Domain

1. Sign in to:
   ```
   https://admin.cloud.microsoft/
   ```
2. Navigate to:
   ```
   Settings → Domains
   ```
3. Click:
   ```
   + Add domain
   ```
4. Enter:
   ```
   bocorp.online
   ```

---

### 1.2 DNS TXT Record Validation (Hostinger)

Microsoft Entra ID will generate a TXT record to verify ownership of the domain.

Example:

| Type | Host | Value |
|------|------|--------|
| TXT  | @    | MS=ms83153720 |

### Steps in Hostinger

1. Navigate to Domains → DNS / Nameservers  
2. Create a new DNS record:
   - Type: `TXT`
   - Host: `@`
   - Value: `MS=ms83153720`
   - TTL: Default
3. Save changes

Wait 5–15 minutes for DNS propagation.

Return to Microsoft Entra ID and click:

```
Verify
```

📸 **Domain Verification Success**

![Domain Verification Success](/screenshots/08/01.png)

---

## 2️⃣ Configure Alternate UPN Suffix in Active Directory

---

### 2.1 Open Active Directory Domains and Trusts

On **DC-01**:

1. Open:
   ```
   Active Directory Domains and Trusts
   ```
2. Right-click the root node
3. Select:
   ```
   Properties
   ```

---

### 2.2 Add Alternate UPN Suffix

In **Alternative UPN suffixes**, add:

```
bocorp.online
```

Click:

```
Apply → OK
```

📸 **Alternate UPN Suffix Configuration**

![Alternate UPN Suffix](/screenshots/08/02.png)

---

## 🧠 Why This Is Required

This does **not** rename the domain.

The internal domain remains:

```
bocorp.local
```

The alternate UPN suffix only allows users to authenticate as:

```
user@bocorp.online
```

This ensures cloud compatibility while preserving internal AD structure.

---

## 3️⃣ Update User Principal Names (UPN)

---

### 3.1 Bulk Update via PowerShell

On **DC-01**, run [`change-upn.ps1`](/scripts/03.ps1) :

```powershell
Get-ADUser -Filter * -SearchBase "OU=Departments,DC=bocorp,DC=local" |
ForEach-Object {
    $newUPN = $_.SamAccountName + "@bocorp.online"
    Set-ADUser $_ -UserPrincipalName $newUPN
}
```

---

### 🔎 Script Explanation

- Retrieves all users in the `Departments` OU  
- Preserves existing `SamAccountName`  
- Updates only the UPN suffix  
- Prepares users for hybrid synchronization  

---

### 3.2 Manual Verification

1. Open:
   ```
   Active Directory Users and Computers
   ```
2. Open any user account
3. Navigate to the **Account** tab
4. Confirm:

```
User logon name: user@bocorp.online
```

📸 **User Account UPN Updated**

![User UPN Updated](/screenshots/08/03.png)

---

## ✅ Outcome

After completing this section:

- On-prem Active Directory remains authoritative  
- Users authenticate using a verified public domain  
- Hybrid identity alignment is clean and structured  
- The environment is fully prepared for Password Hash Synchronization (PHS)  
