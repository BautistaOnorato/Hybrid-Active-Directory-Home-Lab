# Troubleshooting

## Introduction

This document contains a record of issues encountered during the deployment and configuration of the Active Directory Lab environment.

The purpose of this file is to:

- Document errors and unexpected behavior
- Provide root cause analysis
- Describe applied solutions
- Capture lessons learned and best practices

Maintaining this troubleshooting log helps improve problem-solving efficiency, ensures consistency in future deployments, and builds structured operational documentation.

---

## Issue 01 – WS-02 Failed to Start After Being Created from a Checkpoint

### 📌 Description

After creating **WS-02** from a checkpoint of WS-01, the virtual machine failed to start and displayed the following error in Hyper-V:

📸 **Screenshot of the error**

![1. Issue error screenshot](/screenshots/tb-01.png)

### 🔍 Root Cause Analysis

The issue was **not** related to:

- Active Directory  
- Checkpoints  
- Network configuration  
- Duplicate SIDs  

The problem was caused by the virtual machine having an ISO mounted from inside a user profile directory:

```
C:\Users\bauti\Desktop\...
```

The Hyper-V Virtual Machine Management Service runs under a system account that does **not** have permission to access user profile directories.  

This resulted in the error:

```
0x80070005 - Access Denied
```

---

### ✅ Resolution

Since the ISO was not required, the issue was resolved by:

1. Opening **Hyper-V Manager**
2. Navigating to:
   ```
   WS-02 → Settings → DVD Drive
   ```
3. Removing the mounted ISO file
4. Applying the changes
5. Starting the virtual machine again

The VM started successfully.

---

### 🧠 Lessons Learned

- Avoid mounting ISOs from inside `C:\Users\` directories.
- Use a dedicated folder structure for lab resources.
- Always verify attached devices when a VM fails to start.
- Error `0x80070005` typically indicates NTFS permission issues.

---

### 🎯 Best Practices

- Store ISOs outside user profile directories
- Maintain a centralized lab resource structure
- Document incidents to improve troubleshooting efficiency

---

## Issue 02 – Group Policy Failed Due to Firewall Rule Blocking SYSVOL Access

### 📌 Description

After applying a new firewall hardening GPO and running:

```powershell
gpupdate /force
```

The following error appeared on **WS-01**:

```
Windows could not read the file 
\\bocorp.local\SysVol\bocorp.local\Policies\{GUID}\gpt.ini 
from a domain controller.
```

As a result, Group Policy settings failed to apply.

---

### 🔍 Root Cause Analysis

The issue was caused by a custom outbound firewall rule created to prevent lateral movement via SMB.

The following rules were configured in the workstation firewall GPO:

**Block Lateral Movement (SMB)**  
- Rule Type: Port  
- Protocol: TCP  
- Local Port: 445  
- Action: Block  
- Profile: Domain  
- Remote IP Address: `10.10.10.0/24`

**Exception for Lateral Movement (SMB)**  
- Rule Type: Port  
- Protocol: TCP  
- Local Port: 445  
- Action: Allow  
- Profile: Domain  
- Remote IP Address: `10.10.10.10`

Although an exception was created for the Domain Controller (`10.10.10.10`), the broader block rule (`10.10.10.0/24`) still included that IP range.

In Windows Defender Firewall, **Block rules take precedence over Allow rules** when both apply to the same traffic.

As a result:

- SMB traffic to the Domain Controller was blocked
- SYSVOL could not be accessed
- `gpt.ini` could not be read
- Group Policy processing failed

---

### ✅ Resolution

The issue was resolved by:

1. **Removing the Allow exception rule for 10.10.10.10**
2. Modifying the scope of the Block rule to exclude the Domain Controller IP

The new Remote IP scope for the Block rule was configured as:

```
10.10.10.1-9
10.10.10.11-254
```

This excluded `10.10.10.10` from the blocked range.

After applying the change:

```powershell
gpupdate /force
```

Group Policy processing completed successfully.

---

### 🧠 Lessons Learned

- Blocking SMB outbound traffic can break Active Directory functionality.
- SYSVOL access depends on SMB (TCP 445).
- Firewall rule precedence must be carefully considered.
- Avoid overlapping block and allow rules when possible.
- When implementing lateral movement protection, explicitly exclude Domain Controllers from block ranges.

---

### 🎯 Best Practices

- Never block SMB outbound traffic to Domain Controllers.
- Use precise IP ranges instead of broad subnets when restricting lateral movement.
