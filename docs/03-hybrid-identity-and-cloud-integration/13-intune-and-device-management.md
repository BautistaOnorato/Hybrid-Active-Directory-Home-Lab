# 13 - Intune and Device Management

---

## 🎯 Objective

Implement modern device management in a hybrid Active Directory environment by integrating on-prem Active Directory with cloud-based endpoint governance through:

- Hybrid Microsoft Entra ID Join
- Microsoft Intune automatic enrollment
- Compliance policy enforcement
- Conditional Access (Zero Trust)
- Configuration profiles
- Windows Update Rings

---

## 🏗 Hybrid Join Preparation

### 1️⃣ OU Filtering in Entra Connect

To ensure that domain-joined workstations are synchronized to the cloud, OU filtering was configured in Microsoft Entra Connect.

The following OU was added to synchronization scope:

```
OU=Workstations,DC=bocorp,DC=local
```

This ensures that computer objects inside the Workstations OU are synchronized to the Microsoft Entra ID tenant.

---

### 2️⃣ Hybrid Microsoft Entra ID Join

Hybrid Join was configured in Microsoft Entra Connect with the following settings:

- Enable Hybrid Microsoft Entra ID Join
- Target: Windows domain-joined devices
- Service Connection Point (SCP) configured automatically

This allows domain-joined devices to automatically register with Microsoft Entra ID.

---

## 📂 Group Policy Configuration for Auto-Enrollment

Two Group Policy Objects were created and linked to the **Workstations OU**.

---

### GPO-WS-DeviceRegistration

**Purpose:**  
Enable automatic device registration in Microsoft Entra ID.

**Path:**

```
Computer Configuration
→ Policies
→ Administrative Templates
→ Windows Components
→ Device Registration
```

**Setting:**

- Register domain joined computers as devices → Enabled

---

### GPO-WS-IntuneAutoEnrollment

**Purpose:**  
Enable automatic MDM enrollment into Microsoft Intune.

**Path:**

```
Computer Configuration
→ Policies
→ Administrative Templates
→ Windows Components
→ MDM
```

**Setting:**

- Enable automatic MDM enrollment using default Azure AD credentials → Enabled
- Credential Type → User Credential

---

## ☁ Intune Auto-Enrollment Configuration

In Microsoft Entra ID:


Mobility (MDM and WIP) → Microsoft Intune

Configuration:

- MDM user scope → Some
- Assigned group → SG-Cloud-MDM-Users

Only users in this security group are automatically enrolled in Intune.

📸 **Intune Auto-Enrollment Configuration**

![Intune Auto-Enrollment](/screenshots/13/intune-user-scope.png)

---

## 🔄 Device Synchronization (WS-01)

On WS-01:

```
Settings → Accounts → Access work or school
→ Connect
→ Join this device to Azure Active Directory
```

After authentication and MFA:

- Device registered in Entra ID
- Device enrolled in Intune

Validation:

📸 **Device visible in Microsoft Entra ID**

![Device visible in Microsoft Entra ID](/screenshots/13/device-visible-in-entra-id.png)

📸 **Device visible in Microsoft Intune**

![Device visible in Microsoft Intune](/screenshots/13/device-visible-in-intune.png)

---

## 🔐 Compliance Policy Implementation

A compliance policy was created in Microsoft Intune.

---

### Policy: CP-Windows-Enterprise-Baseline

### Device Health

- Require BitLocker → Enabled
- Require Secure Boot → Enabled
- Require Code Integrity → Enabled

### System Security

- Require Firewall → Enabled
- Require TPM → Enabled
- Require Microsoft Defender Antimalware → Enabled

### Assignments

- Include → SG-Cloud-MDM-Users

---

## Compliance Validation

Device compliance was validated in:

Intune → Devices → WS-01 → Compliance

Result:

```
Status: Compliant
```

---

## 🛡 Conditional Access Enforcement

A Conditional Access policy was created in Microsoft Entra ID.

---

### Policy: CA-Require-Compliant-Device

#### Assignments

Users:
- Include → All users
- Exclude → Global Admin (break-glass protection)

Cloud apps:
- Office 365

Conditions:
- Device platforms → Windows

Access Controls:
- Grant access
- Require device to be marked as compliant

---

### Validation

📸 **Non-Compliant Device Access Blocked**

![Non-Compliant Device Access Blocked](/screenshots/13/non-compliant-device-blocked.png)

📸 **Compliant Device Access Allowed**

![Compliant Device Access Allowed](/screenshots/13/compliant-device-allowed.png)

---

## ⚙ Configuration Profiles

A configuration profile was deployed via Microsoft Intune.

---

### Profile: CFG-Windows-Edge-Security

Platform:
- Windows 10 and later
- Settings Catalog

#### Microsoft Edge Configuration

- Block access to URLs:
  - https://www.youtube.com
  - https://www.x.com
- Configure InPrivate mode availability → Disabled
- Configure Microsoft Defender SmartScreen → Enabled
- Prevent bypassing SmartScreen prompts for sites → Enabled
- Prevent bypassing SmartScreen warnings about downloads → Enabled

#### Assignments

- Include → SG-Cloud-MDM-Users

---

### Configuration Validation

📸 **InPrivate Mode Disabled**

![InPrivate Mode Disabled](/screenshots/13/inprivate-mode-disabled.png)

📸 **Blocked URLs (youtube)**

![Blocked URLs (youtube)](/screenshots/13/blocked-urls-youtube.png)

📸 **Blocked URLs (twitter)**

![Blocked URLs (twitter)](/screenshots/13/blocked-urls-twitter.png)

---

## 🔄 Windows Update Ring Migration

A Windows Update Ring was created in Microsoft Intune.

---

### Update Ring: UR-Windows-Enterprise-Standard

#### Configuration

- Microsoft product updates → Allow
- Windows drivers → Allow
- Quality update deferral → 7 days
- Feature update deferral → 30 days
- Upgrade devices to latest Windows 11 release → No
- Automatic update behavior → Auto install and restart at maintenance time
- Active hours → 8:00 AM – 5:00 PM
- Option to pause Windows updates → Disabled
- Option to check for Windows updates → Enabled
- Deadline for feature updates → 7 days
- Deadline for quality updates → 7 days
- Grace period → 2 days

#### Assignments

- Include → SG-Cloud-MDM-Users

---

### GPO to Intune Migration

The GPO `GPO-WS-WindowsUpdate` was disabled and unlinked from the Workstations OU

On WS-01:

```
gpupdate /force
```

Control of Windows Update transitioned fully to Intune.

---

### Update Validation

📸 **Windows Update settings in WS-01**

![Windows Update settings in WS-01](/screenshots/13/windows-update-settings-ws01.png)

![Windows Update settings in WS-01](/screenshots/13/windows-update-settings-ws01b.png)

---

## ✅ Outcome

By completing this section:

- Hybrid domain-joined devices are cloud-registered.
- Devices are automatically enrolled into Intune.
- Security posture is validated via compliance policies.
- Conditional Access enforces compliant device requirement.
- Configuration policies are cloud-managed.
- Windows Update governance migrated from GPO to Intune.