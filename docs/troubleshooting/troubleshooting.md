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

## 🔍 Root Cause Analysis

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

## ✅ Resolution

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

## 🧠 Lessons Learned

- Avoid mounting ISOs from inside `C:\Users\` directories.
- Use a dedicated folder structure for lab resources.
- Always verify attached devices when a VM fails to start.
- Error `0x80070005` typically indicates NTFS permission issues.

---

## 🎯 Best Practices

- Store ISOs outside user profile directories
- Maintain a centralized lab resource structure
- Document incidents to improve troubleshooting efficiency
