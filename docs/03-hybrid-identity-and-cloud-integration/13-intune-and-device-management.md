# 13 – Intune and Device Management

---

## 🎯 Objective

Implement modern device management in the hybrid Active Directory environment by integrating on-premises domain-joined workstations with Microsoft Intune.

This section covers:

- Configuring OU filtering in Entra Connect to synchronize workstation objects
- Enabling Hybrid Microsoft Entra ID Join via Entra Connect
- Creating GPOs to enable automatic device registration and MDM enrollment
- Configuring Intune auto-enrollment in Microsoft Entra ID
- Implementing a device compliance policy
- Enforcing compliance through a Conditional Access policy
- Deploying a configuration profile to manage Microsoft Edge security settings
- Migrating Windows Update management from GPO to Intune

---

## 🏗 Architecture Overview

```
On-Prem AD (bocorp.local)
Domain-joined workstations
        ↓
Hybrid Microsoft Entra ID Join
(GPO-WS-DeviceRegistration + Entra Connect SCP)
        ↓
Microsoft Entra ID (bocorp.online)
        ↓
Intune Auto-Enrollment
(GPO-WS-IntuneAutoEnrollment)
        ↓
Microsoft Intune
Compliance Policies + Configuration Profiles
        ↓
Conditional Access
(CA-Require-Compliant-Device)
```

### Why Hybrid Join Instead of Entra ID Join?

Hybrid Join was selected over a full Entra ID Join to maintain compatibility with on-premises resources such as file shares, GPOs, and domain authentication, while simultaneously enabling cloud-based management through Intune. This reflects the standard migration path for organizations transitioning from purely on-premises management to a modern cloud-managed model.

---

## 1️⃣ Hybrid Join Preparation

### 1.1 Configure OU Filtering in Entra Connect

To synchronize workstation computer objects to Entra ID, the `Workstations` OU was added to the Entra Connect synchronization scope.

Open **Microsoft Entra Connect** on DC-01 and update the OU filtering configuration to include:

```
OU=Workstations,DC=bocorp,DC=local
```

---

### 1.2 Enable Hybrid Microsoft Entra ID Join

In **Microsoft Entra Connect**, navigate to the Hybrid Join configuration and enable the following:

| Setting | Value |
|---------|-------|
| Enable Hybrid Microsoft Entra ID Join | Yes |
| Target | Windows domain-joined devices |
| Service Connection Point (SCP) | Configured automatically |

The SCP is written to the on-premises Active Directory and allows domain-joined devices to discover the Entra ID tenant during the registration process.

---

## 2️⃣ Configure GPOs for Auto-Enrollment

Two GPOs were created and linked to `OU=Workstations,DC=bocorp,DC=local` to automate device registration and MDM enrollment.

---

### 2.1 GPO-WS-DeviceRegistration

Enables automatic device registration in Microsoft Entra ID for domain-joined workstations.

Navigate to the following path inside the GPO:

```
Computer Configuration → Policies → Administrative Templates
→ Windows Components → Device Registration
```

| Setting | Value |
|---------|-------|
| Register domain joined computers as devices | Enabled |

---

### 2.2 GPO-WS-IntuneAutoEnrollment

Enables automatic MDM enrollment into Microsoft Intune using the device's Entra ID credentials.

Navigate to the following path inside the GPO:

```
Computer Configuration → Policies → Administrative Templates
→ Windows Components → MDM
```

| Setting | Value |
|---------|-------|
| Enable automatic MDM enrollment using default Azure AD credentials | Enabled |
| Credential Type | User Credential |

---

## 3️⃣ Configure Intune Auto-Enrollment

In Microsoft Entra ID, configure the MDM user scope to control which users trigger automatic Intune enrollment:

```
portal.azure.com → Microsoft Entra ID → Mobility (MDM and WIP) → Microsoft Intune
```

| Setting | Value |
|---------|-------|
| MDM user scope | Some |
| Assigned group | `SG-Cloud-MDM-Users` |

Only users in `SG-Cloud-MDM-Users` will trigger automatic Intune enrollment when signing in on a Hybrid-joined device.

📸 **Intune auto-enrollment configuration**

![Intune Auto-Enrollment](/screenshots/13/01.png)

---

## 4️⃣ Device Synchronization – WS-01

On **WS-01**, connect the device to Microsoft Entra ID:

```
Settings → Accounts → Access work or school → Connect → Join this device to Azure Active Directory
```

Authenticate with a user account that belongs to `SG-Cloud-MDM-Users` and complete MFA when prompted.

After authentication, the device registers in Entra ID and enrolls in Intune automatically.

📸 **WS-01 visible in Microsoft Entra ID**

![Device visible in Microsoft Entra ID](/screenshots/13/02.png)

📸 **WS-01 visible in Microsoft Intune**

![Device visible in Microsoft Intune](/screenshots/13/03.png)

---

## 5️⃣ Configure Device Compliance Policy

A compliance policy was created in Microsoft Intune to define the security requirements that devices must meet to be considered compliant.

**Policy Name:** `CP-Windows-Enterprise-Baseline`

Navigate to:

```
Intune → Devices → Compliance policies → Create policy → Windows 10 and later
```

### Device Health

| Setting | Value |
|---------|-------|
| Require BitLocker | Yes |
| Require Secure Boot | Yes |
| Require Code Integrity | Yes |

### System Security

| Setting | Value |
|---------|-------|
| Require Firewall | Yes |
| Require TPM | Yes |
| Require Microsoft Defender Antimalware | Yes |

### Assignments

| Setting | Value |
|---------|-------|
| Include | `SG-Cloud-MDM-Users` |

---

### Compliance Validation

Navigate to:

```
Intune → Devices → WS-01 → Compliance
```

Confirm the device status shows:

```
Status: Compliant
```

---

## 6️⃣ Configure Conditional Access – Require Compliant Device

A Conditional Access policy was created to enforce device compliance as a condition for accessing Microsoft 365 resources.

**Policy Name:** `CA-Require-Compliant-Device`

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Security → Conditional Access → New policy
```

| Section | Setting | Value |
|---------|---------|-------|
| Users | Include | All users |
| Users | Exclude | Global Admin account (break-glass protection) |
| Target resources | Include | Office 365 |
| Conditions | Device platforms | Windows |
| Grant | Access control | Grant access – Require device to be marked as compliant |
| Enable policy | State | On |

📸 **Non-compliant device access blocked**

![Non-Compliant Device Access Blocked](/screenshots/13/04.png)

📸 **Compliant device access allowed**

![Compliant Device Access Allowed](/screenshots/13/05.png)

---

## 7️⃣ Deploy Configuration Profile – Edge Security

A configuration profile was deployed to enforce Microsoft Edge security settings on all enrolled devices.

**Profile Name:** `CFG-Windows-Edge-Security`

Navigate to:

```
Intune → Devices → Configuration profiles → Create profile
→ Platform: Windows 10 and later → Settings Catalog
```

### Microsoft Edge Settings

| Setting | Value |
|---------|-------|
| Block access to URLs | `https://www.youtube.com`, `https://www.x.com` |
| Configure InPrivate mode availability | Disabled |
| Configure Microsoft Defender SmartScreen | Enabled |
| Prevent bypassing SmartScreen prompts for sites | Enabled |
| Prevent bypassing SmartScreen warnings about downloads | Enabled |

### Assignments

| Setting | Value |
|---------|-------|
| Include | `SG-Cloud-MDM-Users` |

📸 **InPrivate mode disabled on WS-01**

![InPrivate Mode Disabled](/screenshots/13/06.png)

📸 **YouTube blocked on WS-01**

![Blocked URLs (youtube)](/screenshots/13/07.png)

📸 **X (Twitter) blocked on WS-01**

![Blocked URLs (twitter)](/screenshots/13/08.png)

---

## 8️⃣ Migrate Windows Update Management to Intune

Windows Update management was migrated from GPO to Intune to consolidate endpoint governance under a single management plane.

**Update Ring Name:** `UR-Windows-Enterprise-Standard`

Navigate to:

```
Intune → Devices → Windows update rings → Create profile
```

| Setting | Value |
|---------|-------|
| Microsoft product updates | Allow |
| Windows drivers | Allow |
| Quality update deferral | 7 days |
| Feature update deferral | 30 days |
| Upgrade devices to latest Windows 11 release | No |
| Automatic update behavior | Auto install and restart at maintenance time |
| Active hours | 8:00 AM – 5:00 PM |
| Option to pause Windows updates | Disabled |
| Option to check for Windows updates | Enabled |
| Deadline for feature updates | 7 days |
| Deadline for quality updates | 7 days |
| Grace period | 2 days |

### Assignments

| Setting | Value |
|---------|-------|
| Include | `SG-Cloud-MDM-Users` |

After the Intune update ring was validated, the existing GPO was disabled:

```
GPO-WS-WindowsUpdate → Right-click → Link Enabled (uncheck)
```

On **WS-01**, run `gpupdate /force` to apply the change. Control of Windows Update transitions fully to Intune.

📸 **Windows Update settings managed by Intune on WS-01**

![Windows Update settings in WS-01](/screenshots/13/09.png)

![Windows Update settings in WS-01](/screenshots/13/10.png)

---

## ✅ Outcome

After completing this section:

- The `Workstations` OU is synchronized to Microsoft Entra ID via Entra Connect.
- Hybrid Microsoft Entra ID Join is enabled and the SCP is configured in on-premises AD.
- Domain-joined workstations register in Entra ID and enroll in Intune automatically via GPO.
- `CP-Windows-Enterprise-Baseline` enforces BitLocker, Secure Boot, Firewall, TPM, and Defender compliance requirements.
- `CA-Require-Compliant-Device` blocks access to Office 365 from non-compliant devices.
- `CFG-Windows-Edge-Security` enforces URL blocking, InPrivate mode restriction, and SmartScreen settings via Intune.
- Windows Update governance is fully migrated from GPO to the Intune update ring.