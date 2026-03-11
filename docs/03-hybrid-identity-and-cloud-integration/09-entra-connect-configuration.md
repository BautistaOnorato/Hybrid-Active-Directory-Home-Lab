# 09 - Entra Connect Installation and Synchronization

---

## 🎯 Objective

Install and configure Microsoft Entra Connect to establish secure synchronization between on-premises Active Directory and Microsoft Entra ID.

This section enables:

- Hybrid identity integration
- Password Hash Synchronization (PHS)
- Seamless Single Sign-On (SSO)
- OU-based filtering
- Cloud authentication using verified UPNs

---

## 🧠 Architecture Overview

The hybrid identity architecture implemented in this lab:

- **On-Prem Domain:** bocorp.local  
- **Public Domain:** bocorp.online  
- **Authentication Method:** Password Hash Synchronization (PHS)  
- **SSO Method:** Seamless Single Sign-On  
- **Filtering Strategy:** OU-based filtering  
- **Installation Location:** DC-01  

### Architecture Diagram

```
On-Prem AD (bocorp.local)
        │
        │  Entra Connect (PHS Sync)
        ▼
Microsoft Entra ID (bocorp.online)
        │
        ▼
Microsoft 365 / Intune / Exchange Online
```

This model ensures:

- Cloud authentication resilience  
- Reduced infrastructure complexity  
- Enterprise-aligned hybrid design  

---

## 1️⃣ Download and Install Entra Connect

---

### 1.1 Download

Downloaded the latest version of Microsoft Entra Connect Sync from:

```
portal.azure.com → Microsoft Entra ID → Entra Connect
```

---

### 1.2 Launch Installer

Executed the installer on **DC-01** using administrative privileges.

When prompted: Express Settings or Customize? Selected:

```
Customize
```

---

## 🧠 Why Custom Installation?

Custom setup allows:

- Explicit authentication method selection  
- Seamless SSO configuration  
- OU filtering  
- Avoiding unnecessary features  

---

## 2️⃣ Configure Sign-In Method

📸 **User Sign-In Method Selection**

![User Sign-In Method Selection](/screenshots/09/01.png)

---

### 🔐 Why Password Hash Synchronization?

- Authentication occurs in the cloud  
- No dependency on DC availability for cloud login  
- Simplified hybrid architecture  
- Microsoft-recommended model for most environments  

---

## 3️⃣ Connect to Microsoft Entra ID

Entered:

- Global Administrator credentials  

This step authorizes synchronization with the Microsoft Entra tenant.

---

## 4️⃣ Connect to Active Directory Domain Services

Entered:

- Domain Administrator credentials for bocorp.local  

The wizard automatically:

- Creates synchronization service account  
- Assigns required directory permissions  
- Configures synchronization rules  

📸 **AD DS Connection**

![AD DS Connection](/screenshots/09/02.png)

---

## 5️⃣ Domain and OU Filtering

Selected:

```
Sync selected domains and OUs
```

Enabled synchronization only for:

- OU=Departments  

📸 **OU Filtering**

![OU Filtering](/screenshots/09/03.png)

---

### 🧠 Why OU-Based Filtering?

- Prevents unnecessary object synchronization  
- Reduces attack surface  
- Avoids syncing infrastructure containers  

---

## 6️⃣ Optional Features

Left default options except:

- Seamless SSO enabled  

Did NOT enable:

- Password Writeback  
- Device Writeback  
- Group Writeback
- Exchange Hybrid  
- Azure AD App Proxy  

These can be configured later if required.

---

## 7️⃣ Installation and Initial Synchronization

Completed installation.

Entra Connect automatically initiated the first synchronization cycle.

📸 **Configuration Complete**

![Configuration Complete](/screenshots/09/04.png)

---

## 🔎 Post-Installation Validation

---

### Verify Users in Entra ID

Navigate to:

```
Microsoft 365 admin center → Users → Active Users
```

Confirm:

- Users appear in the directory  
- Sign-in name uses `@bocorp.online`  

📸 **Synced Users View**

![Synced Users](/screenshots/09/05.png)
---

### Test Cloud Authentication

From a browser session:

1. Navigate to:
   ```
   https://m365.cloud.microsoft
   ```
2. Sign in using:
   ```
   carlosmendez@bocorp.online
   ```

Result:

- Successful authentication  
- Password matches on-prem credentials  

📸 **Microsoft 365 Login Success**

![Microsoft 365 Login Success](/screenshots/09/06.png)

---

### Validate Seamless SSO

From a domain-joined workstation inside the network:

1. Open a browser  
2. Navigate to:
   ```
   https://m365.cloud.microsoft
   ```

Result:

- Automatic authentication without credential prompt  

---

## ✅ Outcome

After completing this section:

- Hybrid identity is fully operational  
- Password Hash Synchronization is active  
- Seamless SSO is enabled  
- On-prem AD remains authoritative  
- Users authenticate consistently across environments
