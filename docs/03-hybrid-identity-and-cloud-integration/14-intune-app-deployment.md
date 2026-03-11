# 14 - Intune App Deployment

---

## 🎯 Objective

Design and implement a centralized application deployment strategy using Microsoft Intune to simulate enterprise-grade software lifecycle management.

This phase focuses on:

- Deploying Microsoft 365 Apps automatically
- Packaging and deploying Win32 applications
- Implementing application supersedence (version upgrade control)
- Enabling self-service software via Company Portal
- Performing controlled remote uninstallation

The goal is to simulate a modern enterprise endpoint management model where application deployment, version control, and removal are centrally governed.

---

## 1️⃣ Microsoft 365 Apps Deployment

### 🎯 Purpose

Deploy core productivity applications automatically to hybrid-joined endpoints using Microsoft Intune.

Applications included:

- Word  
- Excel  
- Outlook  
- PowerPoint  
- Teams  

---

### ⚙ Configuration

**App Type:**  
Microsoft 365 Apps for Windows 10 and later  

**Architecture:**  
64-bit  

**Update Channel:**  
Current Channel  

**Remove previous Office versions:**  
Enabled  

**Assignment Type:**  
Required  

**Target Group:**  
Device-based security group containing `WS-01`

---

### 🧠 Design Rationale

- Core productivity applications must be automatically installed.
- Installation is enforced using **Required assignment**.
- Office activation is handled via Microsoft 365 E3 licensing.
- Versioning and updates are controlled centrally through Intune.

---

### ✅ Outcome

- Microsoft 365 Apps installed automatically on WS-01.

📸 **Office Applications**

![Office Applications](/screenshots/14/01.png)

---

## 2️⃣ Win32 App Deployment – 7-Zip v25.01

### 🎯 Purpose

Simulate deployment of a third-party enterprise utility using Win32 packaging.

---

### 🛠 Packaging Process

1. Downloaded 7-Zip installer (v25.01).
2. Created `install.cmd` for silent installation.
3. Converted package using **IntuneWinAppUtil.exe**.
4. Uploaded `.intunewin` package to Intune.

📸 **7zip v25.01 Win32 packaging**

![7zip v25.01 Win32 packaging](/screenshots/14/02.png)

---

### ⚙ App Configuration

**App Type:**  
Windows App (Win32)

**Install Behavior:**  
System

**Detection Rule:**  
File detection

Path:

```
C:\Program Files\7-Zip
```

File:

```
7z.exe
```

Detection method:
File exists

**Assignment Type:**  
Required

**Target Group:**  
Device-based security group

---

### 🧠 Design Rationale

- Win32 packaging allows silent installs and detection logic.
- File-based detection ensures proper installation verification.
- Required deployment enforces corporate software baseline.

---

### ✅ Outcome

- 7-Zip v25.01 installed automatically.
- Detection confirmed via file existence.
- Application lifecycle managed centrally.

📸 **7zip v25.01 intsalled**

![7zip v25.01 intsalled](/screenshots/14/03.png)

---

## 3️⃣ Supersedence – Upgrade to 7-Zip v26.00

### 🎯 Purpose

Simulate enterprise version upgrade governance.

---

### 🔄 Implementation Steps

1. Packaged 7-Zip v26.00 as a new Win32 app.
2. Configured **Supersedence** settings.
3. Selected previous version (v25.01) as superseded.
4. Enabled:
   - Uninstall previous version

5. Assigned v26.00 as **Required** to same device group.

📸 **Supersedence Settings**

![Supersedence Settings](/screenshots/14/04.png)

📸 **7zip v25.01 superseded**

![7zip v25.01 superseded](/screenshots/14/05.png)

---

### 🧠 Design Rationale

Supersedence enables:

- Automatic version replacement
- Clean uninstallation of legacy versions
- Controlled software lifecycle

---

### ✅ Outcome

- v25.01 uninstalled automatically.
- v26.00 installed seamlessly.
- Application lifecycle fully automated.

📸 **7zip v26.00 installed**

![7zip v26.00 installed](/screenshots/14/06.png)

---

## 4️⃣ Company Portal Deployment

### 🎯 Purpose

Enable self-service application model for end users.

---

### ⚙ Configuration

**App Type:**  
Microsoft Store app (new)

**Application:**  
Company Portal

**Assignment Type:**  
Required  

**Target Group:**  
Device-based security group

---

### 🧠 Design Rationale

Company Portal enables:

- User-driven application installation
- Optional software catalog
- Reduced helpdesk workload
- Modern software governance model

---

### ✅ Outcome

- Company Portal installed on WS-01.
- Device able to access available applications.

📸 **Company Portal Installed**

![Company Portal Installed](/screenshots/14/07.png)

---

## 5️⃣ Google Chrome Enterprise Deployment

### 🎯 Purpose

Simulate optional enterprise-approved software deployment using self-service model.

---

### 🛠 Packaging

1. Downloaded Chrome Enterprise MSI (64-bit).
2. Created silent installation command.
3. Converted to `.intunewin`.
4. Uploaded as Win32 app.

📸 **Google Chrome Enterprise Win32 Packaging**

![Google Chrome Enterprise Win32 Packaging](/screenshots/14/08.png)

---

### ⚙ App Configuration

**Install Behavior:**  
System  

**Detection Rule:**  
File detection  

Path:

```
C:\Program Files\Google\Chrome\Application
```

File:

```
chrome.exe
```

Detection method:
File exists

> MSI detection was initially configured but failed due to detection mismatch. File-based detection resolved the installation issue.

---

### 📦 Assignment Model

**Assignment Type:**  
Available for enrolled devices  

**Target Group:**  
Device-based security group

---

### 🧠 Design Rationale

- Chrome classified as optional software.
- Available deployment enables user-controlled installation.
- Enterprise-approved software catalog implemented.

---

### ✅ Outcome

- Chrome appeared in Company Portal.
- Installed manually by user.
- Detection rule validated successful installation.

📸 **Google appears in Company Portal**

![Google appears in Company Portal](/screenshots/14/09.png)

---

## 6️⃣ Manual Installation via Company Portal

### 🎯 Purpose

Validate self-service application deployment.

---

### Process

1. Opened Company Portal on WS-01.
2. Located Google Chrome Enterprise.
3. Selected Install.
4. Verified installation success.

---

### ✅ Outcome

- Chrome installed without administrative privileges.
- Installation governed entirely by Intune.

📸 **Google Chrome Enterprise Installed**

![Google Chrome Enterprise Installed](/screenshots/14/10.png)

---

## 7️⃣ Remote Uninstall Governance

### 🎯 Purpose

Simulate centralized removal of enterprise applications.

---

### Implementation

1. Edited Google Chrome Enterprise assignments.
2. Added new assignment:
   - Assignment type: **Uninstall**
   - Target group: Same device group

---

### 🧠 Design Rationale

Remote uninstall enables:

- Security-driven software removal
- Decommissioning unsupported software
- Centralized compliance enforcement
- Incident response capability

---

### ✅ Outcome

- Chrome automatically uninstalled from WS-01.
- Intune reflected updated installation status.
- Application governance lifecycle validated.

📸 **Google Chrome Enterprise Uninstalled**

![Google Chrome Enterprise Uninstalled](/screenshots/14/11.png)

---

## 🏗 Enterprise Design Principles Applied

This phase implemented real-world endpoint management concepts:

- Automatic deployment of core applications
- Controlled version upgrades via Supersedence
- Self-service software catalog
- Precise detection rules
- Centralized uninstall governance
- Full lifecycle management of Win32 applications

---

## ✅ Operational Outcome

By completing this section:

- Microsoft 365 Apps are centrally deployed and updated.
- Third-party applications are packaged and managed as Win32 apps.
- Version upgrades are automated using supersedence.
- Company Portal enables self-service software model.
- Optional applications can be installed manually.
- Applications can be removed remotely through Intune.