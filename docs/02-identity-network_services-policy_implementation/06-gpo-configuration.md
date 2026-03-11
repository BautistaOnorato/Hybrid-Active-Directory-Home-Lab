# 06 - Group Policy Configuration

---

## 🎯 Objective

Design and implement a structured Group Policy framework aligned with enterprise best practices to:

- Enforce domain-wide security standards
- Harden workstations and domain controllers
- Apply department-based user restrictions
- Reduce attack surface and lateral movement
- Ensure consistent configuration across the environment

Each section below documents the configured GPOs, their settings, and their purpose.

---

## 1️⃣ Domain GPO Configuration

---

### 1.1 Domain Root – Default Domain Policy (Password & Lockout Policy)

#### 🔐 Password Policy

| Setting | Value | Purpose |
|----------|--------|----------|
| Enforce password history | 24 | Prevent reuse of previously used passwords |
| Maximum password age | 90 days | Ensure periodic password rotation |
| Minimum password age | 1 day | Prevent immediate password cycling |
| Minimum password length | 12 | Increase password strength |
| Password must meet complexity requirements | Enabled | Enforce strong password composition |
| Store passwords using reversible encryption | Disabled | Prevent insecure password storage |

#### 🔐 Account Lockout Policy

| Setting | Value | Purpose |
|----------|--------|----------|
| Account lockout threshold | 5 attempts | Mitigate brute force attacks |
| Account lockout duration | 15 minutes | Temporary lockout to slow attack attempts |
| Reset account lockout counter after | 15 minutes | Align reset window with lockout duration |

---

### 1.2 GPO-Domain-AdvancedAudit

Advanced auditing enables detailed monitoring of authentication, object access, and system changes.

| Setting | Value | Purpose |
|----------|--------|----------|
| Audit Credential Validation | Success, Failure | Track authentication validation attempts |
| Audit Kerberos Authentication Service | Success, Failure | Monitor Kerberos ticket requests |
| Audit Kerberos Service Ticket Operations | Success, Failure | Detect abnormal service ticket usage |
| Audit User Account Management | Success, Failure | Track user creation, deletion, modification |
| Audit Security Group Management | Success, Failure | Monitor privilege escalation attempts |
| Audit Computer Account Management | Success, Failure | Track machine account changes |
| Audit Other Account Management Events | Success | Capture additional account events |
| Audit Logon | Success, Failure | Monitor interactive and network logons |
| Audit Logoff | Success | Track session termination |
| Audit Special Logon | Success | Identify privileged logons |
| Audit Other Logon/Logoff Events | Success | Capture extended logon events |
| Audit DPAPI Activity | Failure | Detect cryptographic abuse |
| Audit Process Creation | Success | Enable command-line process tracking |
| Audit Process Termination | Success | Track process lifecycle |
| Audit Directory Service Access | Failure | Monitor AD object access failures |
| Audit Directory Service Changes | Success | Detect AD modifications |
| Audit File System | Failure | Monitor unauthorized file access attempts |
| Audit Registry | Failure | Track registry access failures |
| Audit Authentication Policy Change | Success | Monitor authentication changes |
| Audit Authorization Policy Change | Success, Failure | Detect privilege policy modifications |
| Audit Audit Policy Change | Success, Failure | Prevent audit tampering |
| Audit Other Privilege Use Events | Success, Failure | Detect abnormal privilege usage |
| Audit Security System Extension | Success | Monitor security subsystem changes |
| Audit System Integrity | Success, Failure | Detect integrity violations |
| Audit Security State Change | Success | Track system security state changes |
| Audit Other System Events | Success, Failure | Capture critical system events |

---

### 1.3 GPO-Domain-WindowsFirewall

#### Domain Profile
* Firewall state: On
* Inbound connections: Block (default)
* Outbound connections: Allow (default)

#### Public Profile
* Firewall state: On
* Inbound connections: Block (default)
* Outbound connections: Allow (default)

#### Private Profile
* Firewall state: On
* Inbound connections: Block (default)
* Outbound connections: Allow (default)

---

### 1.4 GPO-Domain-SecurityOptions

<table>
    <thead>
        <tr>
            <th>Setting</th>
            <th>Value</th>
            <th>Purpose</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td colspan="3" style="text-align: center; background-color: #e0e0e0;"><strong>Accounts</strong></td>
        </tr>
        <tr>
            <td>Rename administrator account</td>
            <td>bocorp-adm</td>
            <td>Obfuscate default admin account</td>
        </tr>
        <tr>
            <td>Guest account status</td>
            <td>Disabled</td>
            <td>Prevent anonymous access</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center; background-color: #e0e0e0;"><strong>Domain controller</strong></td>
        </tr>
        <tr>
            <td>LDAP server signing requirements</td>
            <td>Require signing</td>
            <td>Prevent LDAP relay attacks</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center; background-color: #e0e0e0;"><strong>Interactive logon</strong></td>
        <tr>
        <tr>
            <td>Do not display last signed-in</td>
            <td>Enabled</td>
            <td>Reduce username harvesting</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center; background-color: #e0e0e0;"><strong>Microsoft network client</strong></td>
        <tr>
        <tr>
            <td>Digitally sign communications (client)</td>
            <td>Enabled</td>
            <td>Enforce SMB integrity</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center; background-color: #e0e0e0;"><strong>Microsoft network server</strong></td>
        </tr>
        <tr>
            <td>Digitally sign communications (server)</td>
            <td>Enabled</td>
            <td>Prevent SMB tampering</td>
        </tr>
        <tr>
            <td>Disconnect clients when logon hours expire</td>
            <td>Enabled</td>
            <td>Enforce time-based access</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center; background-color: #e0e0e0;"><strong>Network security</strong></td>
        </tr>
        <tr>
            <td>LAN Manager authentication level</td>
            <td>Send NTLMv2 response only. Refuse LM & NTLM</td>
            <td>Enforce modern authentication</td>
        </tr>
        <tr>
            <td>Minimum session security for NTLM SSP based (including secure RPC) clients</td>
            <td>Require NTLMv2 session security and 128-bit encryption</td>
            <td>Enforce secure communication</td>
        </tr>
        <tr>
            <td>Minimum session security for NTLM SSP based (including secure RPC) servers</td>
            <td>Require NTLMv2 session security and 128-bit encryption</td>
            <td>Enforce secure communication</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center; background-color: #e0e0e0;"><strong>User Account Control</strong></td>
        </tr>
        <tr>
            <td>Behavior of the elevation prompt for administrators in Admin Approval Mode</td>
            <td>Prompt for credentials on the secure desktop</td>
            <td>Prevent unauthorized elevation</td>
        </tr>
        <tr>
            <td>Behavior of the elevation prompt for standard users</td>
            <td>Prompt for credentials on the secure desktop</td>
            <td>Enforce credential validation</td>
        </tr>
        <tr>
            <td>Run all administrators in Admin Approval Mode</td>
            <td>Enabled</td>
            <td>Reduce attack surface of admin accounts</td>
        </tr>
        <tr>
            <td>Switch to the secure desktop when prompting for elevation</td>
            <td>Enabled</td>
            <td>Protect elevation prompts from spoofing</td>
        </tr>
        <tr>
            <td>Only elevate executables that are signed and validated</td>
            <td>Disabled</td>
            <td>Maintain compatibility with unsigned applications</td>
        </tr>
    </tbody>
</table>

---

# 2️⃣ Workstation GPO Configuration

---

## 2.1 GPO-WS-USBControl

| Setting | Value | Purpose |
|----------|--------|----------|
| CD/DVD – Deny execute/write | Enabled | Prevent data exfiltration |
| Floppy – Deny execute/write | Enabled | Remove legacy attack vector |
| Removable Disks – Deny execute/write | Enabled | Block malware via USB |
| Exclude GG-Workstation-Admins | Delegation: apply group policy - deny | Allow controlled administrative access |

---

## 2.2 GPO-WS-WindowsDefender

| Setting | Value | Purpose |
|----------|--------|----------|
| Turn off Microsoft Defender Antivirus | Disabled | Ensure AV is active |
| Turn off real-time protection | Disabled | Enable continuous protection |
| Turn on behavior monitoring | Enabled | Detect suspicious behavior |
| Join Microsoft MAPS | Advanced Membership | Improve threat intelligence |
| Send file samples when further analysis is required | Send Safe Samples Automatically | Enable cloud-based analysis |
| Scan all downloaded files and attachments | Enabled | Protect against internet threats |
| Monitor file and program activity on your computer | Enabled | Detect malicious activity |
| Scan removable drives | Enabled | Protect against USB threats |
| Configure removal of items from Quarantine folder | 30 days | Maintain forensic visibility |
| Specify the scan type to use for scheduled scans | Full Scan | Deep inspection |
| Specify the day of the week to run a scheduled scan | Sunday | Maintenance window |
| Specify the time of day to run a scheduled scan | 2:00 AM (120) | Off-hours scanning |

---

## 2.3 GPO-WS-BitLocker

| Setting | Value | Purpose |
|----------|--------|----------|
| Enforced drive encryption type on operating system drives | Full Encryption | Strong disk encryption |
| Require additional authentication at startup | Enabled | Protect against offline attacks |
| Deny write access to removable drives not protected by BitLocker | Enabled | Enforce encryption compliance |
| Configure use of passwords for fixed data drives | Enabled | Protect secondary drives |
| Store BitLocker recovery information in Active Directory Domain Services (AD DS) | Recovery passwords and key packages | Centralized recovery management |

---

## 2.4 GPO-WS-Firewall

📸 **Inbound Rules**

![Inbound Rules](/screenshots/06/01.png)

📸 **Outbound Rules**
![Outbound Rules](/screenshots/06/02.png)

---

## 2.5 GPO-WS-LocalAdminControl

<table>
    <thead>
        <tr>
            <th>Setting</th>
            <th>Value</th>
            <th>Purpose</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td colspan="3" style="text-align: center; background-color: #e0e0e0;"><strong>Administrators (built-in)</strong></td>
        </tr>
        <tr>
            <td>GG-Workstation-Admins</td>
            <td>Add</td>
            <td>Obfuscate default admin account</td>
        </tr>
        <tr>
            <td>Domain Admins</td>
            <td>Add</td>
            <td>Ensure enterprise control</td> 
        </tr>
        <tr>
            <td>Other members and groups</td>
            <td>Remove</td>
            <td>Prevent privilege sprawl</td>
        </tr>
    </tbody>
</table>

---

## 2.6 GPO-WS-WindowsUpdate

| Setting | Value | Purpose |
|----------|--------|----------|
| Configure Automatic Updates | Auto download + schedule | Ensure patch compliance |
| Scheduled install day and time | Sunday 3:00 AM | Maintenance window |
| Turn off auto-restart during active hours | 8 AM – 5 PM | Avoid user disruption |
| Specify deadline for feature updates | 7 days | Enforce timely upgrades |
| Specify deadline for quality updates | 7 days | Rapid security patching |
| Remove access to use all Windows Update features | Enabled | Prevent user bypass |
| Remove access to "Pause Updates" feature | Enabled | Enforce compliance |

---

# 3️⃣ Domain Controllers GPO Configuration

---

## 3.1 GPO-DC-WindowsDefender

| Setting | Value | Purpose |
|----------|--------|----------|
| Turn off Microsoft Defender Antivirus | Disabled | Ensure AV is active |
| Turn off real-time protection | Disabled | Enable continuous protection |
| Turn on behavior monitoring | Enabled | Detect suspicious behavior |
| Join Microsoft MAPS | Advanced Membership | Improve threat intelligence |
| Send file samples when further analysis is required | Send Safe Samples Automatically | Enable cloud-based analysis |
| Scan all downloaded files and attachments | Enabled | Protect against internet threats |
| Monitor file and program activity on your computer | Enabled | Detect malicious activity |
| Scan removable drives | Enabled | Protect against USB threats |
| Configure removal of items from Quarantine folder | 30 days | Maintain forensic visibility |
| Specify the scan type to use for scheduled scans | Quick Scan | Minimize DC load |
| Specify the day of the week to run a scheduled scan | Sunday | Maintenance window |
| Specify the time of day to run a scheduled scan | 2:00 AM (120) | Off-hours scanning |
| Path exclusions | C:\Windows\NTDS, C:\Windows\SYSVOL, C:\Windows\SYSVOL\domain, C:\Windows\SYSVOL\sysvol | Prevent AD performance impact |

---

## 3.2 GPO-DC-Firewall

📸 **Inbound Rules**

![Inbound Rules](/screenshots/06/03.png)


---

## 4️⃣ Department-Specific GPOs

---

### 4.1 Finance – GPO-Finance-DesktopWallpaper

| Setting | Value | Purpose |
|----------|--------|----------|
| Desktop Wallpaper | \\bocorp.local\SYSVOL\bocorp.local\Wallpapers\FINANCE_WP.jpg | Visual department identification |

---

### 4.2 IT – GPO-IT-DesktopWallpaper

| Setting | Value | Purpose |
|----------|--------|----------|
| Desktop Wallpaper | \\bocorp.local\SYSVOL\bocorp.local\Wallpapers\IT_WP.jpg | Visual department identification |

---

### 4.3 HR – GPO-HR-DesktopWallpaper

| Setting | Value | Purpose |
|----------|--------|----------|
| Desktop Wallpaper | \\bocorp.local\SYSVOL\bocorp.local\Wallpapers\HR_WP.jpg | Visual department identification |

---

### 4.4 Sales – GPO-Sales-DesktopWallpaper

| Setting | Value | Purpose |
|----------|--------|----------|
| Desktop Wallpaper | \\bocorp.local\SYSVOL\bocorp.local\Wallpapers\SALES_WP.jpg | Visual department identification |

---

## 5️⃣ GPO Backup Strategy

### 🎯 Objective

Establish a repeatable and structured backup mechanism for all existing Group Policy Objects to ensure:

- Recovery capability in case of accidental deletion or corruption  
- Versioned configuration baselines  
- Safer change management  

---

### 🛠️ Backup Automation Script

A PowerShell script was created to automate the backup process and generate date-based versioning.

#### 📂 Script: [`backup-gpo.ps1`](/scripts/backup-gpo.ps1)

```powershell
# Backup GPOs Script

$Date = Get-Date -Format "yyyy-MM-dd"

if (Test-Path -Path "C:\GPO-Backups") {
    Write-Host "GPO backup directory exists."
} else {
    New-Item -Path "C:\GPO-Backups" -ItemType Directory
}

$Path = "C:\GPO-Backups\$Date"

New-Item -Path $Path -ItemType Directory
Backup-GPO -All -Path $Path -Comment "Backup on $Date" -Verbose
```

---

## ✅ Operational Outcome

- All GPO configurations are versioned.
- A restorable baseline is created after Phase 2 completion.
- The environment gains rollback capability.
- Change management can be performed safely.
- The lab reflects enterprise-grade operational practices.

---

## ✅ Outcome

Implemented structured, scope-based Group Policy configurations across the environment:

- **Strengthened Domain Security:** Enforced strong password policies, NTLMv2-only authentication, LDAP signing, SMB signing, and secure UAC prompts to reduce credential abuse and relay attacks.
- **Enhanced Visibility:** Advanced Audit Policies provide detailed monitoring of authentication, directory changes, privilege use, and process activity.
- **Reduced Lateral Movement:** Workstation firewall rules restrict SMB communication and limit RDP access to authorized systems only.
- **Hardened Endpoints:** USB restrictions, BitLocker (XTS-AES 256), controlled local admin membership, and enforced update policies reduce endpoint compromise risk.
- **Protected Critical Infrastructure:** Dedicated Domain Controller policies ensure secure configuration while maintaining AD performance.
- **Standardized Environment:** Department-based GPOs enforce consistent user experience and organizational structure.
