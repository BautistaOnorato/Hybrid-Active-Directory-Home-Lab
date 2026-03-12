# 09 – Entra Connect Installation and Synchronization

---

## 🎯 Objective

Install and configure Microsoft Entra Connect on DC-01 to establish directory synchronization between the on-premises Active Directory and Microsoft Entra ID.

This section covers:

- Downloading and installing Microsoft Entra Connect on DC-01
- Selecting Password Hash Synchronization as the authentication method
- Enabling Seamless Single Sign-On
- Configuring OU-based filtering to control which objects are synchronized
- Validating directory synchronization and cloud authentication

---

## 🏗 Architecture Overview

```
On-Premises AD (bocorp.local)
        ↓
Microsoft Entra Connect (DC-01)
Password Hash Synchronization + Seamless SSO
        ↓
Microsoft Entra ID (bocorp.online)
        ↓
Microsoft 365 / Exchange Online / Intune
```

### Authentication Method – Password Hash Synchronization

Several authentication methods were evaluated before selecting PHS:

| Method | Reason |
|--------|--------|
| Pass-through Authentication (PTA) | Requires an always-available on-prem authentication agent — adds infrastructure dependency |
| Active Directory Federation Services (AD FS) | Requires dedicated federation servers — significant infrastructure overhead |
| Password Hash Synchronization (PHS) | ✔ Authentication occurs in the cloud — no dependency on DC availability for cloud sign-in |

PHS is the Microsoft-recommended model for most environments and is the simplest hybrid identity configuration to deploy and maintain.

### OU Filtering

Only the `Departments` and `Global` OUs are included in the synchronization scope:

| OU | Synchronized |
|----|-------------|
| `OU=Departments,DC=bocorp,DC=local` | ✔ Yes |
| `OU=Global,OU=_Groups,DC=bocorp,DC=local` | ✔ Yes |
| All other OUs | ✘ No |

Synchronizing the `Departments` OU brings all department user accounts into Entra ID. Synchronizing the `Global` OU brings the Global Security Groups into Entra ID, enabling group-based licensing and role assignments in Microsoft 365. All other OUs — including service accounts, administrative users, and infrastructure containers — are excluded to reduce the attack surface and keep the Entra ID tenant clean.

---

## 1️⃣ Download and Install Entra Connect

### 1.1 Download

On **DC-01**, download the latest version of Microsoft Entra Connect Sync from the Azure Portal:

```
portal.azure.com → Microsoft Entra ID → Entra Connect → Download
```

---

### 1.2 Launch the Installer

Run the installer as Administrator and select **Customize** when prompted to choose between Express Settings and Customize.

> Express Settings configures synchronization automatically but does not allow selecting the authentication method, enabling Seamless SSO, or configuring OU filtering — all of which are required for this lab.

---

## 2️⃣ Configure Sign-In Method

On the **User Sign-In** screen, select:

```
Password Hash Synchronization
```

Enable:

```
✔ Enable Single Sign-On
```

📸 **User Sign-In method selection**

![User Sign-In Method Selection](/screenshots/09/01.png)

---

## 3️⃣ Connect to Microsoft Entra ID

Enter **Global Administrator** credentials for the `bocorp.online` tenant when prompted.

This step authorizes Entra Connect to write synchronized objects into the Microsoft Entra ID directory.

---

## 4️⃣ Connect to Active Directory Domain Services

Enter **Domain Administrator** credentials for `bocorp.local` when prompted.

The wizard automatically:

- Creates a dedicated synchronization service account in Active Directory
- Assigns the required directory read permissions to the service account
- Configures the synchronization rules for the connected directory

📸 **Active Directory connection configured**

![AD DS Connection](/screenshots/09/02.png)

---

## 5️⃣ Configure OU Filtering

On the **Domain and OU Filtering** screen, select:

```
Sync selected domains and OUs
```

Enable synchronization only for the following OUs:

```
OU=Departments,DC=bocorp,DC=local
OU=Global,OU=_Groups,DC=bocorp,DC=local
```

Deselect all other OUs and containers.

📸 **OU filtering configured for the Departments OU**

![OU Filtering](/screenshots/09/03.png)

---

## 6️⃣ Optional Features

On the **Optional Features** screen, leave all options at their defaults. Seamless SSO was already enabled on the Sign-In method screen in step 2.

The following features were explicitly left disabled:

| Feature | Reason |
|---------|--------|
| Password Writeback | Not required — on-prem AD remains the authoritative password source |
| Device Writeback | Handled by Hybrid Join configuration in Intune |
| Group Writeback | Not required for this lab |
| Exchange Hybrid | No on-premises Exchange server in this environment |
| Azure AD App Proxy | Not required for this lab |

---

## 7️⃣ Complete Installation

Review the configuration summary and click **Install**. Entra Connect initiates the first synchronization cycle automatically after installation completes.

📸 **Installation and initial synchronization complete**

![Configuration Complete](/screenshots/09/04.png)

---

## 🔎 Validation

### Verify Synchronized Users in Microsoft Entra ID

Navigate to the Microsoft 365 Admin Center and confirm that department users appear with `@bocorp.online` UPNs:

```
https://admin.cloud.microsoft → Users → Active Users
```

📸 **Synchronized users visible in Microsoft 365 Admin Center**

![Synced Users](/screenshots/09/05.png)

---

### Validate Cloud Authentication

From a browser, sign in to Microsoft 365 using a synchronized user account:

```
https://m365.cloud.microsoft
```

Enter credentials using the `@bocorp.online` UPN and confirm successful authentication. The password used must match the on-premises Active Directory password for the account.

📸 **Microsoft 365 login successful with synchronized credentials**

![Microsoft 365 Login Success](/screenshots/09/06.png)

---

### Validate Seamless SSO

From a domain-joined workstation inside the lab network, open a browser and navigate to:

```
https://m365.cloud.microsoft
```

Confirm that authentication completes automatically without prompting for credentials.

---

## ✅ Outcome

After completing this section:

- Microsoft Entra Connect is installed and running on DC-01.
- Password Hash Synchronization is active between `bocorp.local` and `bocorp.online`.
- Seamless Single Sign-On is enabled for domain-joined workstations.
- Only the `Departments` and `Global` OUs are synchronized to Microsoft Entra ID.
- Synchronized users can authenticate to Microsoft 365 using their on-premises credentials.
- The environment is ready for MFA and Conditional Access configuration.