# 16 – Azure Backup

---

## 🎯 Objective

Implement Azure Backup to protect on-premises workloads hosted on DC-01, including file shares and System State.

This section covers:

- Creating the Azure resource group and Recovery Services Vault
- Installing and registering the MARS Agent on DC-01
- Securing backup credentials using Azure Key Vault
- Configuring a backup policy for on-premises file shares
- Configuring a backup policy for DC-01 System State
- Validating file share recovery through a restore simulation
- Configuring monitoring and alerting for backup job failures

---

## 🏗 Architecture Overview

```
DC-01 (On-Premises)
File Shares + System State
        ↓
MARS Agent
        ↓
Recovery Services Vault (RSV-Bocorp-Backup)
        ↓
├── File Share Backup Policy (daily)
└── System State Backup Policy (scheduled)
        ↓
Log Analytics Workspace (LAW-Bocorp-Backup)
        ↓
Alert Rule (KQL) → Action Group → Shared Mailbox
```

### Azure Components

| Resource | Name |
|----------|------|
| Resource Group | `RG-Bocorp-Backup` |
| Recovery Services Vault | `RSV-Bocorp-Backup` |
| Key Vault | `KV-Bocorp-Backup` |
| Log Analytics Workspace | `LAW-Bocorp-Backup` |
| Action Group | `AG-Backup-Fail` |
| Alert Rule | `Alert-Backup-Job-Failure` |

---

## 1️⃣ Create Azure Resources

### 1.1 Create Resource Group

Create a dedicated resource group to logically isolate all backup-related resources:

```
portal.azure.com → Resource groups → Create
```

| Setting | Value |
|---------|-------|
| Name | `RG-Bocorp-Backup` |
| Region | (lab deployment region) |

📸 **Resource group created**

![Resource Group](/screenshots/16/01.png)

---

### 1.2 Create Recovery Services Vault

```
portal.azure.com → Recovery Services vaults → Create
```

| Setting | Value |
|---------|-------|
| Name | `RSV-Bocorp-Backup` |
| Resource Group | `RG-Bocorp-Backup` |
| Region | (lab deployment region) |

---

## 2️⃣ Install and Register the MARS Agent

The Microsoft Azure Recovery Services (MARS) Agent must be installed on DC-01 to establish secure communication between the on-premises server and the Recovery Services Vault.

### 2.1 Download and Install the MARS Agent

Download the MARS Agent installer from the Recovery Services Vault:

```
RSV-Bocorp-Backup → Backup → Where is your workload running? On-Premises
→ What do you want to backup? Files and folders / System State
→ Download Agent
```

Run the installer on **DC-01** and complete the setup wizard.

📸 **MARS Agent setup on DC-01**

![MARS Agent Setup](/screenshots/16/02.png)

---

### 2.2 Register DC-01 with the Vault

After installation, register DC-01 with the Recovery Services Vault using the vault credentials file downloaded from the portal.

📸 **DC-01 registered with the Recovery Services Vault**

![Server Registration](/screenshots/16/03.png)

---

## 3️⃣ Secure Backup Credentials with Key Vault

A dedicated Key Vault was created to securely store the backup credentials used by the Recovery Services Vault.

```
portal.azure.com → Key vaults → Create
```

| Setting | Value |
|---------|-------|
| Name | `KV-Bocorp-Backup` |
| Resource Group | `RG-Bocorp-Backup` |

After creation, assign the **Key Vault Secrets Officer** role to the Recovery Services Vault managed identity to allow it to access the stored credentials:

```
KV-Bocorp-Backup → Access control (IAM) → Add role assignment
→ Key Vault Secrets Officer → Assign to RSV-Bocorp-Backup (managed identity)
```

📸 **Key Vault Secrets Officer role assigned to the Recovery Services Vault**

![Key Vault Secrets Officer role](/screenshots/16/04.png)

📸 **Key Vault overview**

![Key Vault Overview](/screenshots/16/05.png)

---

## 4️⃣ Configure File Share Backup

### 4.1 Configure the Backup Policy

On **DC-01**, open the **MARS Agent** console and configure the backup schedule:

```
Schedule a Backup → Add Items → select departmental share folders
```

| Setting | Value |
|---------|-------|
| Backup frequency | Daily |
| Retention range | (defined per policy) |
| Backup window | (scheduled during off-hours) |

📸 **Backup item selection**

![Backup Selection](/screenshots/16/06.png)

📸 **Backup schedule configured**

![Backup Schedule](/screenshots/16/07.png)

📸 **Retention policy configured**

![Retention Policy](/screenshots/16/08.png)

📸 **Backup policy confirmation**

![Backup Confirmation](/screenshots/16/09.png)

---

### 4.2 Run Initial Backup

Trigger the first backup manually to establish an initial recovery point:

```
MARS Agent console → Backup Now
```

Confirm the backup job completes successfully and the recovery point is visible in the Azure Portal.

📸 **First backup completed successfully**

![First Backup](/screenshots/16/10.png)

---

## 5️⃣ Validate File Share Recovery

A recovery simulation was performed to confirm that the restore workflow functions correctly end-to-end.

### Recovery Steps

1. Created a test file inside the `/Finance/` share folder
2. Executed a backup to capture the test file in a recovery point
3. Deleted the test file
4. Initiated a restore from the MARS Agent console using the **Mount recovery point as new volume** method
5. Copied the restored file back to its original location

📸 **File share recovery simulation**

![Recovery Simulation](/screenshots/16/11.png)

The test file was restored successfully with data integrity verified.

---

## 6️⃣ Configure System State Backup

System State backup protects the Domain Controller configuration, including Active Directory, the SYSVOL, boot files, and the registry. This enables full DC recovery if required.

### 6.1 Configure the Backup Policy

In the **MARS Agent** console, add a separate System State backup schedule:

```
Schedule a Backup → Add Items → System State
```

📸 **System State backup schedule configured**

![System State Backup Schedule](/screenshots/16/12.png)

📸 **System State retention policy configured**

![System State Retention Policy](/screenshots/16/13.png)

📸 **System State backup policy confirmation**

![System State Backup Confirmation](/screenshots/16/14.png)

---

### 6.2 Run Initial System State Backup

Trigger the first System State backup manually:

```
MARS Agent console → Backup Now → System State
```

Confirm the backup job completes successfully and the System State recovery point is visible in the Azure Portal.

---

## 7️⃣ Configure Monitoring and Alerting

### 7.1 Create Shared Mailbox for Backup Alerts

A dedicated shared mailbox was created in Microsoft 365 to receive all backup alert notifications, avoiding dependency on individual user accounts.

📸 **Shared mailbox for backup alerts**

![Shared Mailbox for Backup Alerts](/screenshots/16/15.png)

---

### 7.2 Create Action Group

```
portal.azure.com → Monitor → Alerts → Action groups → Create
```

| Setting | Value |
|---------|-------|
| Name | `AG-Backup-Fail` |
| Resource Group | `RG-Bocorp-Backup` |
| Notification type | Email |
| Email recipient | Backup shared mailbox |

A test notification was sent to confirm delivery to the shared mailbox.

📸 **Action group configured**

![Action Groups](/screenshots/16/16.png)

---

### 7.3 Create Log Analytics Workspace

A dedicated Log Analytics Workspace was deployed to enable advanced KQL-based alerting, providing more reliable and flexible monitoring than the built-in vault alerts.

```
portal.azure.com → Log Analytics workspaces → Create
```

| Setting | Value |
|---------|-------|
| Name | `LAW-Bocorp-Backup` |
| Resource Group | `RG-Bocorp-Backup` |

📸 **Log Analytics Workspace created**

![LAW-Bocorp-Backup](/screenshots/16/17.png)

---

### 7.4 Configure Diagnostic Settings on the Recovery Services Vault

Send backup logs from the Recovery Services Vault to the Log Analytics Workspace:

```
RSV-Bocorp-Backup → Monitoring → Diagnostic settings → Add diagnostic setting
```

| Setting | Value |
|---------|-------|
| Name | `DS-Bocorp-Backup` |
| Destination | Send to Log Analytics Workspace (`LAW-Bocorp-Backup`) |

Enable the following log categories:

| Log Category |
|-------------|
| Azure Backup Reporting Data |
| Core Azure Backup Data |
| Addon Azure Backup Job Data |
| Addon Azure Backup Alert Data |
| Azure Backup Operations |

---

### 7.5 Create Alert Rule

```
portal.azure.com → Monitor → Alerts → Alert rules → Create
```

**Alert Rule Name:** `Alert-Backup-Job-Failure`

#### Condition

| Setting | Value |
|---------|-------|
| Signal type | Custom log search |
| Query type | Aggregated logs |

**KQL Query:**

```kql
AddonAzureBackupAlerts
| where AlertSeverity == "Critical"
| where AlertStatus == "Active"
```

| Setting | Value |
|---------|-------|
| Measure | Table rows |
| Aggregation type | Count |
| Aggregation granularity | 5 minutes |
| Operator | Greater than |
| Threshold value | 0 |
| Frequency of evaluation | Every 5 minutes |

> The threshold is set to `0` so that any single Critical and Active alert triggers an immediate notification. This ensures backup failures are never silently missed.

#### Actions and Details

| Setting | Value |
|---------|-------|
| Action group | `AG-Backup-Fail` |
| Email subject | `Backup failure` |
| Severity | 0 – Critical |

📸 **Alert rule configuration**

![Alert Configuration](/screenshots/16/18.png)

![Alert Configuration](/screenshots/16/19.png)

![Alert Configuration](/screenshots/16/20.png)

---

## 🔎 Validation

A controlled backup failure was triggered to validate the full alerting pipeline end-to-end.

### Validation Steps

1. Triggered a backup failure scenario on DC-01
2. Confirmed logs populated in `LAW-Bocorp-Backup` via the Azure Portal
3. Confirmed the KQL query returned results for the failure event
4. Confirmed the alert rule state changed to **Fired**
5. Confirmed the email notification was delivered to the backup shared mailbox

📸 **Alert fired in Azure Monitor**

![Alert Fired](/screenshots/16/21.png)

📸 **Alert notification email received**

![Alert Email](/screenshots/16/22.png)

---

## ✅ Outcome

After completing this section:

- DC-01 is registered with `RSV-Bocorp-Backup` and protected by the MARS Agent.
- On-premises file shares are backed up daily with a validated recovery workflow.
- DC-01 System State is backed up on a scheduled basis, enabling full Domain Controller recovery.
- Backup credentials are secured in `KV-Bocorp-Backup`.
- Backup job logs are ingested into `LAW-Bocorp-Backup` via diagnostic settings.
- KQL-based alert rule detects backup failures within 5 minutes and notifies the backup shared mailbox.
- The full alerting pipeline was validated end-to-end through a controlled failure simulation.