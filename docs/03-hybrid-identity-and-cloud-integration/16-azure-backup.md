# 16 – Azure Backup Configuration (On-Premises File Shares & System State)

---

## 🎯 Objective

Implement Azure Backup to protect on-premises workloads hosted on **DC-01**, including:

- File shares  
- System State (Domain Controller protection)

This configuration provides cloud-based backup, recovery validation, alerting, and operational monitoring.

---

## 🏗 Environment Overview

### 🖥 On-Prem Server

- **DC-01**
  - Domain Controller
  - Hosts file shares

### ☁ Azure Components

- **Resource Group:** `RG-Bocorp-Backup`
- **Recovery Services Vault:** `RSV-Bocorp-Backup`
- **Key Vault:** `KV-Bocorp-Backup`
- **Action Group:** `AG-Bocorp-Backup`
- **Shared Mailbox:** Backup Shared Mailbox

---

## 1️⃣ Azure Resource Preparation

### 1.1 Create Resource Group

Created a dedicated resource group:

```
RG-Bocorp-Backup
```

**Purpose:**

- Logical isolation of backup resources

📸 **Resource Group**

![Resource Group](/screenshots/16/01.png)

---

### 1.2 Create Recovery Services Vault

Created:

```
RSV-Bocorp-Backup
```

**Configuration:**

- Region aligned with lab deployment
- Standard storage redundancy

**Purpose:**

- Centralized backup management
- Policy definition
- Recovery operations

---

## 2️⃣ Backup Infrastructure Configuration

### 2.1 Install and Configure MARS Agent on DC-01

Steps performed:

1. Downloaded Microsoft Azure Recovery Services (MARS) Agent  
2. Installed MARS Agent on DC-01  
3. Registered DC-01 with the Recovery Services Vault  

This established secure communication between DC-01 and Azure Backup.

📸 **MARS Agent Setup**

![MARS Agent Setup](/screenshots/16/02.png)

📸 **Server Registration**

![Server Registration](/screenshots/16/03.png)

---

### 2.2 Credential Protection via Key Vault

Created:

```
KV-Bocorp-Backup
```

**Purpose:**

- Secure storage of backup credentials
- Protection of vault registration secrets

**Configuration:**

- Assigned permissions allowing the Recovery Services Vault to access required credentials

📸 **Key Vault Secrets Officer role assigned to Recovery Services Vault**

![Key Vault Secrets Officer role](/screenshots/16/04.png)

📸 **Key Vault Overview**

![Key Vault Overview](/screenshots/16/05.png)

---

## 3️⃣ File Share Backup Configuration

### 3.1 Configure Backup Policy

Defined backup policy for:

- On-prem file shares hosted on DC-01

**Policy Configuration:**

- Daily backups
- Defined retention period
- Scheduled backup window

📸 **Backup Selection**

![Backup Selection](/screenshots/16/06.png)

📸 **Backup Schedule**

![Backup Schedule](/screenshots/16/07.png)

📸 **Retention Policy**

![Retention Policy  ](/screenshots/16/08.png)

📸 **Backup Confirmation**

![Backup Confirmation](/screenshots/16/09.png)
---

### 3.2 Initial Backup Execution

Performed manual **Back Up Now** to trigger initial backup.

**Validation:**

- Backup job completed successfully
- Recovery points visible in Azure Portal
- Status: **Completed**

📸 **First Backup**

![First Backup](/screenshots/16/10.png)

---

## 4️⃣ Recovery Validation – File Shares

### 4.1 Recovery Simulation

Simulated recovery scenario:

1. Created test file inside `/Finance/`
2. Executed backup
3. Deleted the file
4. Restored using:
   - **Mount recovery point as new volume** method
5. Copied required file back to original location

**Validation Result:**

- File restored successfully
- Data integrity verified
- Recovery workflow confirmed functional

📸 **Recovery Simulation**

![Recovery Simulation](/screenshots/16/11.png)

---

## 5️⃣ System State Backup Configuration

### 5.1 Enable System State Protection

Configured MARS Agent to include:

- System State backup of DC-01

---

### 5.2 Execute System State Backup

Performed manual System State backup.

**Validation:**

- Backup job completed successfully
- System State recovery point available in Azure

This enables full Domain Controller recovery if required.

📸 **System State Backup Schedule**

![System State Backup Schedule](/screenshots/16/12.png)

📸 **System State Retention Policy**

![System State Retention Policy](/screenshots/16/13.png)

📸 **System State Backup Confirmation**

![System State Backup Confirmation](/screenshots/16/14.png)

---

## 6️⃣ Monitoring & Alerting

---

### 6.1 Create Shared Mailbox (Microsoft 365)

Created a dedicated shared mailbox for backup alerts.

📸 **Shared Mailbox for Backup Alerts**

![Shared Mailbox for Backup Alerts](/screenshots/16/15.png)

**Purpose:**

- Centralized operational notifications  
- Enterprise-aligned alert handling  
- Avoid dependency on individual user accounts  

---

### 6.2 Create Action Group

Created:

```
AG-Backup-Fail
```

**Configuration:**

- Email notification targeting the backup shared mailbox  
- Standard alert processing configuration  

**Validation:**

- Test notification successfully delivered  

📸 **Action Groups**

![Action Groups](/screenshots/16/16.png)

---

### 6.3 Log Analytics Workspace Integration

To enable advanced monitoring and reliable alerting, a dedicated Log Analytics workspace was deployed.

#### Create Log Analytics Workspace

Created:

```
LAW-Bocorp-Backup
```

Assigned to:

```
RG-Bocorp-Backup
```

**Purpose:**

- Centralized log ingestion  
- Advanced KQL-based alerting  
- Enterprise-grade monitoring architecture  
- Better reliability compared to built-in vault alerts 

📸 **LAW-Bocorp-Backup**

![LAW-Bocorp-Backup](/screenshots/16/17.png)

---

#### Configure Diagnostic Settings on Recovery Services Vault

Navigated to:

```
RSV-Bocorp-Backup → Monitoring → Diagnostic settings
```

Created new diagnostic setting:

```
DS-Bocorp-Backup
```

**Logs Enabled:**

The following categories were configured:

- Azure Backup Reporting Data  
- Core Azure Backup Data  
- Addon Azure Backup Job Data  
- Addon Azure Backup Alert Data  
- Azure Backup Operations  

**Destination:**

- **Send to Log Analytics Workspace**
- Workspace selected: `LAW-Bocorp-Backup`

This configuration ensures that all backup job events, operational logs, and alert data are centralized inside Log Analytics for querying and monitoring.

---

### 6.4 Configure Custom Log-Based Alert Rule

Configured alert rule:

```
Alert-Backup-Job-Failure
```

The alert uses a **custom KQL query** against Log Analytics.

---

#### Condition Configuration

- **Signal:** Custom log search  
- **Query type:** Aggregated logs  

#### 🔎 Search Query (KQL)

```kql
AddonAzureBackupAlerts
| where AlertSeverity == "Critical"
| where AlertStatus == "Active"
```

#### Aggregation Settings

- **Measure:** Table rows  
- **Aggregation type:** Count  
- **Aggregation granularity:** 5 minutes  
- **Operator:** Greater than  
- **Threshold value:** 0  
- **Frequency of evaluation:** Every 5 minutes  

#### Why Threshold = 0?

The logic is:

> If at least one Critical and Active alert exists → trigger notification.

This guarantees immediate alerting when a backup failure occurs.

---

#### Actions

- **Action Group:** `AG-Backup-Fail`  
- **Email Subject:** `Backup failure`

---

#### Details

- **Severity:** 0 – Critical  

📸 **Alert Configuration**

![Alert Configuration](/screenshots/16/18.png)
![Alert Configuration](/screenshots/16/19.png)
![Alert Configuration](/screenshots/16/20.png)

---

## 6.5 Alert Validation (Failure Simulation)

Performed controlled backup failure testing to validate the new monitoring architecture.

### Validation Steps

1. Triggered backup failure scenario  
2. Verified logs populated in Log Analytics  
3. Confirmed alert rule evaluation  
4. Alert state changed to **Fired**  
5. Email notification delivered to shared mailbox  

### Result

- Log ingestion working correctly  
- KQL query returning expected results  
- Alert rule triggering reliably  
- Email notification confirmed  

📸 **Alert Fired**

![Alert Fired](/screenshots/16/21.png)

📸 **Alert Email**

![Alert Email](/screenshots/16/22.png)

---

## 7️⃣ Final Validation Checklist

| Component | Status |
|------------|--------|
| Resource Group created | ✅ |
| Recovery Services Vault operational | ✅ |
| MARS Agent installed on DC-01 | ✅ |
| DC-01 registered in vault | ✅ |
| Key Vault configured | ✅ |
| File share backup working | ✅ |
| System State backup working | ✅ |
| Recovery test successful | ✅ |
| Alerting configured | ✅ |
| Failure notification validated | ✅ |

---

## ✅ Outcome

By completing this configuration:

- On-prem file shares are protected in Azure.
- Domain Controller system state is backed up securely.
- Recovery processes are validated.
- Backup failures trigger automatic notifications.
