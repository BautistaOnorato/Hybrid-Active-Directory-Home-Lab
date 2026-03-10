# E02 – Action1 Patch Management

---

## 🎯 Objective

Integrate Action1 into the lab environment to implement cloud-based endpoint management, providing:

- Centralized agent deployment across all Windows endpoints
- Software inventory visibility across the environment
- Patch management with separated policies for workstations and servers
- Vulnerability assessment and CVE tracking
- Remote PowerShell execution for helpdesk task simulation

---

## 🧠 Architectural Context

Action1 is a cloud-based patch management and remote management platform. In this lab, it complements the existing on-premises GPO and Intune management layers by providing an additional visibility and control plane for software inventory, missing updates, and vulnerability reporting.

---

## 🔹 Design Decision – GPO vs Intune for Agent Deployment

Two deployment methods were evaluated before selecting GPO:

| Method | Reason |
|--------|--------|
| Microsoft Intune | WS-01 and WS-02 are enrolled in Intune. DC-01 is not an MDM-managed endpoint by design. |
| GPO | ✔ All three endpoints are domain-joined. GPO reaches DC-01, WS-01, and WS-02 without dependency on Intune enrollment. |

GPO was selected as the deployment method because it covers the full scope of monitored endpoints regardless of their cloud management status.

---

## 1️⃣ Agent Deployment

---

### 1.1 Download the Action1 Agent Installer

The Action1 agent installer was downloaded directly from the Action1 console:

```
https://app.action1.com → Endpoints → New Endpoints → Install Agent
```

> The installer downloaded from the Action1 console has the organization code embedded. Endpoints register automatically to the correct tenant upon installation without additional configuration.

---

### 1.2 Host the Installer in SYSVOL

The installer was hosted in SYSVOL to make it accessible to all domain-joined computers using their machine credentials.

```powershell
New-Item -Path "C:\Windows\SYSVOL\sysvol\bocorp.local\Action1" -ItemType Directory

Copy-Item -Path "C:\Users\Administrator\Downloads\action1_remote_agent.msi" `
          -Destination "C:\Windows\SYSVOL\sysvol\bocorp.local\Action1\"
```

Verified UNC path accessibility:

```powershell
Test-Path "\\bocorp.local\SYSVOL\bocorp.local\Action1\action1_remote_agent.msi"
```

---

### 1.3 Create the Deployment Script

A PowerShell wrapper script was created to handle idempotent installation — the agent is only installed if not already present on the endpoint.

**Script:** [`deploy-action1.ps1`](/scripts/deploy-action1.ps1)

```powershell
$installedApp = Get-WmiObject -Class Win32_Product | 
    Where-Object { $_.Name -like "*Action1*" }

if ($null -eq $installedApp) {
    $msiPath = "\\bocorp.local\SYSVOL\bocorp.local\Action1\action1_remote_agent.msi"
    Start-Process -FilePath "msiexec.exe" `
                  -ArgumentList "/i `"$msiPath`" /qn /norestart" `
                  -Wait
}
```

The script was saved to:

```
C:\Windows\SYSVOL\sysvol\bocorp.local\Action1\deploy-action1.ps1
```

---

### 1.4 Create and Configure the GPO

A dedicated GPO was created to deploy the Action1 agent as a startup script.

**GPO Name:** `GPO-Action1-AgentDeployment`

**Startup Script Path:**

```
Computer Configuration
→ Policies
→ Windows Settings
→ Scripts (Startup/Shutdown)
→ Startup
→ PowerShell Scripts
→ \\bocorp.local\SYSVOL\bocorp.local\Action1\deploy-action1.ps1
```

---

### 1.5 Security Group and Filtering

A dedicated security group was created to control which machines receive the GPO.

**Group:** `GG-Action1-Endpoints`  
**Location:** `OU=Global,OU=_Groups,DC=bocorp,DC=local`  
**Members:** DC-01, WS-01, WS-02

Security filtering was updated:

- **Authenticated Users** → Removed
- **GG-Action1-Endpoints** → Added with Read + Apply Group Policy permissions

---

### 1.6 GPO Links

The GPO was linked to both OUs containing monitored endpoints:

- `bocorp.local → Workstations`
- `bocorp.local → Domain Controllers`

---

### 1.7 Validation

On each Windows host:

```powershell
gpupdate /force
```

After reboot, agent installation was confirmed:

```powershell
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Action1*" }
```

📸 **Action1 console showing all three endpoints registered**

![Action1 Endpoints](/screenshots/E02/05.png)

---

## 2️⃣ Endpoint Organization

Two endpoint groups were created in the Action1 console to enable separate policy management.

| Group | Members |
|-------|---------|
| Bocorp - Workstations | WS-01, WS-02 |
| Bocorp - Servers | DC-01 |

This separation ensures that update policies, automation schedules, and approval workflows can be configured independently for servers and workstations.

📸 **Bocorp - Workstations group**

![Bocorp - Workstations group](/screenshots/E02/06.png)

📸 **Bocorp - Servers group**

![Bocorp - Servers group](/screenshots/E02/07.png)

---

## 3️⃣ Software Inventory

The software inventory was reviewed from:

```
Installed Software
```

The report confirmed the following software across all endpoints:

| Software | Endpoints | Deployment Method |
|----------|-----------|------------------|
| Action1 Agent | 3 | GPO |
| Zabbix Agent 2 | 3 | GPO |
| Microsoft 365 Apps for enterprise | 2 (WS-01/2) | Intune |
| 7-Zip (x64) | 2 (WS-01/2) | Intune |
| Microsoft Azure Recovery Services Agent | 1 (DC-01) | Manual |
| Microsoft Azure AD Connect Agent | 1 (DC-01) | Manual |

> Company Portal was not detected in the inventory. This is expected behavior — Action1's software inventory targets Win32 applications and does not enumerate Microsoft Store apps.

---

## 4️⃣ Patch Management

---

### 4.1 Missing Updates Baseline

Before configuring update policies, a baseline of missing updates was collected per endpoint.

| Endpoint | Missing Updates | Critical | Important | Unspecified |
|----------|----------------|----------|-----------|-------------|
| DC-01 | 5 | 1 | 1 | 3 |
| WS-01 | 2 | 0 | 0 | 2 |
| WS-02 | 5 | 0 | 0 | 5 |

---

### 4.2 Update Ring – Workstations

An automated Update Ring was created for the workstation group.

**Name:** `UR-Workstations-AutoUpdate`  
**Target:** Bocorp - Workstations

| Setting | Value |
|---------|-------|
| Updates to deploy | All |
| Approval | Do not require approval |
| Delay | 7 days since release |
| Reboot | Automatically, outside active hours |
| Schedule | Weekly, Sunday 3:00 AM |
| Deactivate Windows Update | Enabled |

> A 7-day delay was configured to avoid deploying updates on release day, which is a common practice to allow time for the community to identify problematic patches before broad deployment.

> The **Deactivate updates in Windows settings** option was enabled to ensure Action1 takes full control of the update process on workstations, preventing Windows Update from installing patches outside the configured maintenance window.

---

### 4.3 Update Ring – Servers

A separate Update Ring with manual approval was created for DC-01.

**Name:** `UR-Servers-ManualApproval`  
**Target:** Bocorp - Servers

| Setting | Value |
|---------|-------|
| Updates to deploy | All |
| Approval | Require update approval |
| Reboot | Show message |
| Schedule | Weekly, Sunday 2:00 AM |
| Deactivate Windows Update | Enabled |

> Manual approval is required for DC-01 because domain controllers should never be rebooted automatically outside a planned maintenance window. An unplanned DC reboot directly impacts authentication for all domain users.

> The schedule was set one hour before the workstation ring to allow time for manual approval and installation before the workstation maintenance window begins.

---

### 4.4 Manual Update Approval – DC-01

The pending updates for DC-01 were reviewed and approved manually from:

```
Update Approval
```

The critical update was identified and approved. The update status changed to **Approved**, queuing installation for the next scheduled maintenance window.

📸 **Update Approval view showing DC-01 updates approved**

![Update Approval](/screenshots/E02/11.png)

---

## 5️⃣ Vulnerability Reporting

A vulnerability assessment was executed from:

```
Vulnerabilities
```

### Findings

Two CVEs were identified on WS-01, both related to the WireGuard installation.

| CVE | CVSS Score | CISA KEV | Published | Status | Software |
|-----|------------|----------|-----------|--------|----------|
| CVE-2021-46873 | 5.3 (Medium) | No | Jan 29, 2023 | Overdue | WireGuard 0.5.3 |
| CVE-2023-35838 | 5.7 (Medium) | No | Aug 9, 2023 | Overdue | WireGuard 0.5.3 |

### Remediation Status

Remediation was investigated. At the time of this documentation, **WireGuard 0.5.3 is the latest available version** for Windows. No updated version addressing these CVEs has been released by the vendor.

### Risk Acceptance

Since no vendor fix is available, these vulnerabilities are documented as **accepted risk** with the following justification:

- No newer version is available to remediate the CVEs
- WireGuard is used exclusively in a controlled lab environment
- The affected endpoints are not exposed to untrusted networks during normal lab operation
- CVEs will be re-evaluated when a new WireGuard version is released

---

## 6️⃣ Remote PowerShell Execution

A remote script execution was configured to simulate a common helpdesk task — forcing a Group Policy update on all workstations without requiring physical or RDP access.

---

### 6.1 Script Created

A script was created in the Action1 Script Library:

**Name:** `Helpdesk - Force GPUpdate`

```powershell
$result = gpupdate /force
Write-Output $result
```

---

### 6.2 Automation Configured

An automation was created to execute the script remotely:

```
Automations → New Automation → Run Script
```

| Setting | Value |
|---------|-------|
| Script | Helpdesk - Force GPUpdate |
| Target | Bocorp - Workstations |
| Schedule | Run Once, immediately |
| Name | Script-ForceGPUpdate-Workstations |


📸 **Execution results**

![Remote Script Execution](/screenshots/E02/10.png)

---

## ✅ Outcome

After completing this integration:

- Action1 agent is deployed on all three Windows endpoints via GPO.
- Endpoints are organized into separate groups for workstations and servers.
- Software inventory is centralized and validated against known deployments.
- Automated update policies enforce patch compliance on workstations.
- Manual approval workflow is in place for the domain controller.
- Vulnerability assessment identified and documented two WireGuard CVEs.
- Remote PowerShell execution validated centralized helpdesk task delivery.
