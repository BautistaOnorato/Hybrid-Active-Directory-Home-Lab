# 06 – GPO Configuration

---

## 🎯 Objective

Design and implement a structured Group Policy framework for the `bocorp.local` domain aligned with enterprise security best practices.

This section covers:

- Configuring domain-wide password and account lockout policies
- Implementing advanced audit policies for security monitoring
- Deploying firewall rules across domain controllers and workstations
- Hardening workstations with security baselines
- Applying department-specific configuration policies
- Automating GPO backups with a PowerShell script

---

## 🏗 Architecture Overview

GPOs are organized by scope and target to ensure clean inheritance and minimal overlap:

| GPO | Scope | Target |
|-----|-------|--------|
| Default Domain Policy | Domain root | All objects |
| GPO-Domain-AdvancedAudit | Domain root | All objects |
| GPO-Domain-WindowsFirewall | Domain root | All objects |
| GPO-Domain-SecurityOptions | Domain root | All objects |
| GPO-WS-USBControl | Workstations OU | Workstations |
| GPO-WS-WindowsDefender | Workstations OU | Workstations |
| GPO-WS-BitLocker | Workstations OU | Workstations |
| GPO-WS-Firewall | Workstations OU | Workstations |
| GPO-WS-LocalAdminControl | Workstations OU | Workstations |
| GPO-WS-WindowsUpdate | Workstations OU | Workstations |
| GPO-DC-WindowsDefender | Domain Controllers OU | Domain Controllers |
| GPO-DC-Firewall | Domain Controllers OU | Domain Controllers |
| GPO-Finance-DesktopWallpaper | Departments\Finance OU | Finance users |
| GPO-HR-DesktopWallpaper | Departments\HR OU | HR users |
| GPO-IT-DesktopWallpaper | Departments\IT OU | IT users |
| GPO-Sales-DesktopWallpaper | Departments\Sales OU | Sales users |

---

## 1️⃣ Domain GPO Configuration

---

### 1.1 Default Domain Policy – Password & Account Lockout

The Default Domain Policy enforces the password and lockout baseline for all domain accounts.

#### Password Policy

| Setting | Value | Purpose |
|---------|-------|---------|
| Enforce password history | 24 | Prevent reuse of recently used passwords |
| Maximum password age | 90 days | Ensure periodic password rotation |
| Minimum password age | 1 day | Prevent immediate password cycling |
| Minimum password length | 12 | Enforce strong password length |
| Password must meet complexity requirements | Enabled | Enforce strong password composition |
| Store passwords using reversible encryption | Disabled | Prevent insecure password storage |

#### Account Lockout Policy

| Setting | Value | Purpose |
|---------|-------|---------|
| Account lockout threshold | 5 attempts | Mitigate brute force attacks |
| Account lockout duration | 15 minutes | Temporary lockout to slow attack attempts |
| Reset account lockout counter after | 15 minutes | Align reset window with lockout duration |

---

### 1.2 GPO-Domain-AdvancedAudit

Advanced audit policies provide detailed visibility into authentication events, directory changes, privilege use, and process activity across all domain-joined machines.

| Setting | Value | Purpose |
|---------|-------|---------|
| Audit Credential Validation | Success, Failure | Track authentication validation attempts |
| Audit Kerberos Authentication Service | Success, Failure | Monitor Kerberos ticket requests |
| Audit Kerberos Service Ticket Operations | Success, Failure | Detect abnormal service ticket usage |
| Audit User Account Management | Success, Failure | Track user creation, deletion, and modification |
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

Windows Firewall is enforced across all profiles to ensure the firewall cannot be disabled by local users or administrators.

| Profile | Firewall State | Inbound | Outbound |
|---------|---------------|---------|---------|
| Domain | On | Block (default) | Allow (default) |
| Private | On | Block (default) | Allow (default) |
| Public | On | Block (default) | Allow (default) |

---

### 1.4 GPO-Domain-SecurityOptions

| Category | Setting | Value | Purpose |
|----------|---------|-------|---------|
| Accounts | Rename administrator account | `bocorp-adm` | Obfuscate the default admin account name |
| Accounts | Guest account status | Disabled | Prevent anonymous access |
| Domain Controller | LDAP server signing requirements | Require signing | Prevent LDAP relay attacks |
| Interactive Logon | Do not display last signed-in | Enabled | Reduce username harvesting at the login screen |
| Microsoft Network Client | Digitally sign communications (client) | Enabled | Enforce SMB integrity |
| Microsoft Network Server | Digitally sign communications (server) | Enabled | Prevent SMB tampering |
| Microsoft Network Server | Disconnect clients when logon hours expire | Enabled | Enforce time-based access control |
| Network Security | LAN Manager authentication level | Send NTLMv2 response only. Refuse LM & NTLM | Enforce modern authentication |
| Network Security | Minimum session security for NTLM SSP clients | Require NTLMv2 and 128-bit encryption | Enforce secure NTLM communication |
| Network Security | Minimum session security for NTLM SSP servers | Require NTLMv2 and 128-bit encryption | Enforce secure NTLM communication |
| User Account Control | Elevation prompt behavior for administrators | Prompt for credentials on the secure desktop | Prevent unauthorized elevation |
| User Account Control | Elevation prompt behavior for standard users | Prompt for credentials on the secure desktop | Enforce credential validation on elevation |
| User Account Control | Run all administrators in Admin Approval Mode | Enabled | Reduce the attack surface of admin accounts |
| User Account Control | Switch to the secure desktop when prompting for elevation | Enabled | Protect elevation prompts from spoofing |
| User Account Control | Only elevate executables that are signed and validated | Disabled | Maintain compatibility with unsigned applications |

---

## 2️⃣ Workstation GPO Configuration

---

### 2.1 GPO-WS-USBControl

Restricts removable media access on workstations to prevent data exfiltration and malware introduction via USB.

| Setting | Value | Purpose |
|---------|-------|---------|
| CD/DVD – Deny execute access | Enabled | Prevent execution from optical drives |
| CD/DVD – Deny write access | Enabled | Prevent data exfiltration via optical drives |
| Floppy – Deny execute access | Enabled | Remove legacy attack vector |
| Floppy – Deny write access | Enabled | Remove legacy attack vector |
| Removable Disks – Deny execute access | Enabled | Block malware execution via USB |
| Removable Disks – Deny write access | Enabled | Block data exfiltration via USB |

> `GG-Workstation-Admins` is excluded from this policy via Security Filtering to allow controlled administrative access to removable media when required.

---

### 2.2 GPO-WS-WindowsDefender

| Setting | Value | Purpose |
|---------|-------|---------|
| Turn off Microsoft Defender Antivirus | Disabled | Ensure antivirus remains active |
| Turn off real-time protection | Disabled | Enable continuous threat protection |
| Turn on behavior monitoring | Enabled | Detect suspicious behavioral patterns |
| Join Microsoft MAPS | Advanced Membership | Improve cloud-based threat intelligence |
| Send file samples when further analysis is required | Send Safe Samples Automatically | Enable cloud-based sample analysis |
| Scan all downloaded files and attachments | Enabled | Protect against internet-borne threats |
| Monitor file and program activity | Enabled | Detect malicious file and process activity |
| Scan removable drives | Enabled | Protect against USB-delivered threats |
| Configure removal of items from Quarantine folder | 30 days | Maintain forensic visibility before removal |
| Specify the scan type for scheduled scans | Full Scan | Deep inspection of all files |
| Specify the day of the week to run a scheduled scan | Sunday | Run during the maintenance window |
| Specify the time of day to run a scheduled scan | 2:00 AM | Run outside active hours |

---

### 2.3 GPO-WS-BitLocker

| Setting | Value | Purpose |
|---------|-------|---------|
| Enforce drive encryption type on OS drives | Full Encryption | Ensure the entire drive is encrypted |
| Require additional authentication at startup | Enabled | Protect against offline attacks |
| Deny write access to removable drives not protected by BitLocker | Enabled | Enforce encryption compliance on removable media |
| Configure use of passwords for fixed data drives | Enabled | Protect secondary internal drives |
| Store BitLocker recovery information in AD DS | Recovery passwords and key packages | Enable centralized recovery management via Active Directory |

---

### 2.4 GPO-WS-Firewall

Custom inbound and outbound firewall rules are deployed to workstations to restrict lateral movement and limit exposure.

📸 **Workstation inbound firewall rules**

![Inbound Rules](/screenshots/06/01.png)

📸 **Workstation outbound firewall rules**

![Outbound Rules](/screenshots/06/02.png)

---

### 2.5 GPO-WS-LocalAdminControl

Controls the membership of the local Administrators group on all workstations to prevent privilege sprawl.

| Action | Principal | Purpose |
|--------|-----------|---------|
| Add | `GG-Workstation-Admins` | Grant local admin rights to the designated IT group |
| Add | `Domain Admins` | Ensure enterprise-level administrative access |
| Remove | All other members | Eliminate unauthorized local admin accounts |

---

### 2.6 GPO-WS-WindowsUpdate

| Setting | Value | Purpose |
|---------|-------|---------|
| Configure Automatic Updates | Auto download and schedule installation | Ensure patch compliance |
| Scheduled install day and time | Sunday, 3:00 AM | Install updates during the maintenance window |
| Turn off auto-restart during active hours | 8:00 AM – 5:00 PM | Avoid user disruption during business hours |
| Specify deadline for feature updates | 7 days | Enforce timely feature update installation |
| Specify deadline for quality updates | 7 days | Enforce rapid security patching |
| Remove access to use all Windows Update features | Enabled | Prevent users from manually managing updates |
| Remove access to "Pause Updates" feature | Enabled | Prevent users from bypassing update compliance |

---

## 3️⃣ Domain Controller GPO Configuration

---

### 3.1 GPO-DC-WindowsDefender

Defender settings for domain controllers mirror the workstation policy with two key differences: scheduled scans use **Quick Scan** to minimize load on the DC, and path exclusions are configured for critical AD directories to prevent performance impact.

| Setting | Value | Purpose |
|---------|-------|---------|
| Turn off Microsoft Defender Antivirus | Disabled | Ensure antivirus remains active |
| Turn off real-time protection | Disabled | Enable continuous threat protection |
| Turn on behavior monitoring | Enabled | Detect suspicious behavioral patterns |
| Join Microsoft MAPS | Advanced Membership | Improve cloud-based threat intelligence |
| Send file samples when further analysis is required | Send Safe Samples Automatically | Enable cloud-based sample analysis |
| Scan all downloaded files and attachments | Enabled | Protect against internet-borne threats |
| Monitor file and program activity | Enabled | Detect malicious file and process activity |
| Scan removable drives | Enabled | Protect against USB-delivered threats |
| Configure removal of items from Quarantine folder | 30 days | Maintain forensic visibility before removal |
| Specify the scan type for scheduled scans | Quick Scan | Minimize performance impact on the DC |
| Specify the day of the week to run a scheduled scan | Sunday | Run during the maintenance window |
| Specify the time of day to run a scheduled scan | 2:00 AM | Run outside active hours |
| Path exclusions | `C:\Windows\NTDS` | Prevent AD database interference |
| Path exclusions | `C:\Windows\SYSVOL` | Prevent SYSVOL replication interference |
| Path exclusions | `C:\Windows\SYSVOL\domain` | Prevent AD policy interference |
| Path exclusions | `C:\Windows\SYSVOL\sysvol` | Prevent AD policy interference |

---

### 3.2 GPO-DC-Firewall

Custom inbound firewall rules are deployed to domain controllers to restrict access to sensitive services.

📸 **Domain Controller inbound firewall rules**

![Inbound Rules](/screenshots/06/03.png)

---

## 4️⃣ Department-Specific GPO Configuration

Desktop wallpapers are deployed per department to provide visual identification of the active user's department. Wallpaper images are hosted in SYSVOL to ensure all domain-joined machines can access them using machine credentials.

| GPO | Setting | Value |
|-----|---------|-------|
| GPO-Finance-DesktopWallpaper | Desktop Wallpaper path | `\\bocorp.local\SYSVOL\bocorp.local\Wallpapers\FINANCE_WP.jpg` |
| GPO-HR-DesktopWallpaper | Desktop Wallpaper path | `\\bocorp.local\SYSVOL\bocorp.local\Wallpapers\HR_WP.jpg` |
| GPO-IT-DesktopWallpaper | Desktop Wallpaper path | `\\bocorp.local\SYSVOL\bocorp.local\Wallpapers\IT_WP.jpg` |
| GPO-Sales-DesktopWallpaper | Desktop Wallpaper path | `\\bocorp.local\SYSVOL\bocorp.local\Wallpapers\SALES_WP.jpg` |

---

## 5️⃣ GPO Backup Strategy

A PowerShell script was created to automate GPO backups and maintain date-based versioning. Backups are stored locally on DC-01 under `C:\GPO-Backups\`.

### Script: [`backup-gpo.ps1`](/scripts/backup-gpo.ps1)

```powershell
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

Running this script after any GPO change ensures a restorable baseline is always available and change management can be performed safely.

---

## ✅ Outcome

After completing this section:

- Domain-wide password and lockout policies enforce a strong authentication baseline.
- Advanced audit policies provide detailed visibility into authentication, directory changes, and privilege use across all endpoints.
- Windows Firewall is enforced on all profiles across the domain.
- Security options harden NTLM authentication, SMB signing, LDAP signing, and UAC behavior.
- Workstation GPOs enforce USB restrictions, BitLocker encryption, Defender configuration, local admin control, and update compliance.
- Domain Controller GPOs apply dedicated Defender settings with AD path exclusions and custom firewall rules.
- Department wallpapers provide visual department identification on all workstations.
- GPO backups are automated with date-based versioning to support safe change management.
