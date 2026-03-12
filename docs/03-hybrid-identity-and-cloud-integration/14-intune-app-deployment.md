# 14 – Intune App Deployment

---

## 🎯 Objective

Implement a centralized application deployment strategy using Microsoft Intune to simulate enterprise-grade software lifecycle management.

This section covers:

- Deploying Microsoft 365 Apps automatically to enrolled workstations
- Packaging and deploying a third-party Win32 application (7-Zip)
- Automating a version upgrade using application supersedence
- Enabling a self-service software catalog via Company Portal
- Deploying an optional enterprise application through Company Portal
- Performing a controlled remote uninstallation via Intune

---

## 🏗 Architecture Overview

```
Microsoft Intune
        ↓
┌─────────────────────────────────────────────────────┐
│  Required Deployment          Available Deployment  │
│  (automatic install)          (user self-service)   │
│                                                     │
│  Microsoft 365 Apps           Google Chrome         │
│  7-Zip v26.00                 Enterprise            │
│  Company Portal                                     │
└─────────────────────────────────────────────────────┘
        ↓
WS-01 (SG-Cloud-MDM-Users)
```

### Application Lifecycle – 7-Zip

Supersedence was used to demonstrate controlled version upgrade management:

```
7-Zip v25.01 (Required)
        ↓
7-Zip v26.00 deployed with Supersedence
        ↓
v25.01 uninstalled automatically → v26.00 installed
```

---

## 1️⃣ Deploy Microsoft 365 Apps

Microsoft 365 Apps are deployed automatically as a required application to all enrolled workstations.

Navigate to:

```
Intune → Apps → Windows → Add → Microsoft 365 Apps for Windows 10 and later
```

### Configuration

| Setting | Value |
|---------|-------|
| Architecture | 64-bit |
| Update Channel | Current Channel |
| Remove previous Office versions | Yes |

### Apps Included

| Application |
|-------------|
| Word |
| Excel |
| Outlook |
| PowerPoint |
| Teams |

### Assignments

| Setting | Value |
|---------|-------|
| Assignment type | Required |
| Target group | Device-based security group containing WS-01 |

📸 **Microsoft 365 Apps installed on WS-01**

![Office Applications](/screenshots/14/01.png)

---

## 2️⃣ Deploy 7-Zip v25.01 (Win32)

7-Zip is packaged as a Win32 application to simulate third-party enterprise software deployment with silent installation and detection logic.

### 2.1 Package the Application

Download the 7-Zip v25.01 MSI installer and create a silent installation script:

**`install.cmd`**
```cmd
msiexec /i "7z2501-x64.msi" /qn /norestart
```

Convert the package using **IntuneWinAppUtil.exe**:

```cmd
IntuneWinAppUtil.exe -c <source_folder> -s install.cmd -o <output_folder>
```

Upload the generated `.intunewin` file to Intune:

```
Intune → Apps → Windows → Add → Windows app (Win32)
```

📸 **7-Zip v25.01 Win32 packaging**

![7zip v25.01 Win32 packaging](/screenshots/14/02.png)

---

### 2.2 App Configuration

| Setting | Value |
|---------|-------|
| Install behavior | System |
| Install command | `msiexec /i "7z2501-x64.msi" /qn /norestart` |
| Uninstall command | `msiexec /x "7z2501-x64.msi" /qn /norestart` |

### Detection Rule

| Setting | Value |
|---------|-------|
| Rule type | File detection |
| Path | `C:\Program Files\7-Zip` |
| File | `7z.exe` |
| Detection method | File exists |

### Assignments

| Setting | Value |
|---------|-------|
| Assignment type | Required |
| Target group | Device-based security group containing WS-01 |

📸 **7-Zip v25.01 installed on WS-01**

![7zip v25.01 installed](/screenshots/14/03.png)

---

## 3️⃣ Upgrade to 7-Zip v26.00 via Supersedence

7-Zip v26.00 was packaged following the same process as v25.01 and deployed with a supersedence relationship to automate the version upgrade.

### 3.1 Configure Supersedence

After uploading and configuring the v26.00 app in Intune, navigate to the **Supersedence** tab:

```
Intune → Apps → 7-Zip v26.00 → Supersedence → Add
```

| Setting | Value |
|---------|-------|
| Superseded app | 7-Zip v25.01 |
| Uninstall previous version | Yes |

📸 **Supersedence settings for 7-Zip v26.00**

![Supersedence Settings](/screenshots/14/04.png)

📸 **7-Zip v25.01 marked as superseded**

![7zip v25.01 superseded](/screenshots/14/05.png)

### 3.2 Assign v26.00

| Setting | Value |
|---------|-------|
| Assignment type | Required |
| Target group | Device-based security group containing WS-01 |

Once the assignment is processed, Intune uninstalls v25.01 and installs v26.00 automatically without any manual intervention on the endpoint.

📸 **7-Zip v26.00 installed on WS-01**

![7zip v26.00 installed](/screenshots/14/06.png)

---

## 4️⃣ Deploy Company Portal

Company Portal enables a self-service software catalog where users can install optional enterprise-approved applications without requiring administrator assistance.

Navigate to:

```
Intune → Apps → Windows → Add → Microsoft Store app (new) → Search: Company Portal
```

### Assignments

| Setting | Value |
|---------|-------|
| Assignment type | Required |
| Target group | Device-based security group containing WS-01 |

📸 **Company Portal installed on WS-01**

![Company Portal Installed](/screenshots/14/07.png)

---

## 5️⃣ Deploy Google Chrome Enterprise (Available)

Google Chrome Enterprise is deployed as an optional application available through Company Portal, simulating an enterprise-approved software catalog.

### 5.1 Package the Application

Download the Google Chrome Enterprise MSI (64-bit) and package it using **IntuneWinAppUtil.exe** following the same process as 7-Zip.

📸 **Google Chrome Enterprise Win32 packaging**

![Google Chrome Enterprise Win32 Packaging](/screenshots/14/08.png)

---

### 5.2 App Configuration

| Setting | Value |
|---------|-------|
| Install behavior | System |

### Detection Rule

| Setting | Value |
|---------|-------|
| Rule type | File detection |
| Path | `C:\Program Files\Google\Chrome\Application` |
| File | `chrome.exe` |
| Detection method | File exists |

> File-based detection was used instead of MSI detection after MSI detection failed due to a product code mismatch during initial testing.

### Assignments

| Setting | Value |
|---------|-------|
| Assignment type | Available for enrolled devices |
| Target group | Device-based security group containing WS-01 |

📸 **Google Chrome Enterprise available in Company Portal**

![Google appears in Company Portal](/screenshots/14/09.png)

---

### 5.3 Install via Company Portal

On **WS-01**, open Company Portal, locate **Google Chrome Enterprise**, and click **Install**.

📸 **Google Chrome Enterprise installed via Company Portal**

![Google Chrome Enterprise Installed](/screenshots/14/10.png)

---

## 6️⃣ Remote Uninstall – Google Chrome Enterprise

Remote uninstallation was configured to simulate centralized application removal, demonstrating Intune's ability to enforce software compliance and support incident response scenarios.

Navigate to the Chrome Enterprise app assignments in Intune and add a new assignment:

```
Intune → Apps → Google Chrome Enterprise → Assignments → Add group
```

| Setting | Value |
|---------|-------|
| Assignment type | Uninstall |
| Target group | Device-based security group containing WS-01 |

Once processed, Intune uninstalls Google Chrome Enterprise from WS-01 automatically.

📸 **Google Chrome Enterprise uninstalled from WS-01**

![Google Chrome Enterprise Uninstalled](/screenshots/14/11.png)

---

## ✅ Outcome

After completing this section:

- Microsoft 365 Apps are deployed automatically to enrolled workstations via a required assignment.
- 7-Zip is packaged and deployed as a Win32 application with file-based detection.
- Version upgrade from v25.01 to v26.00 is automated using Intune supersedence.
- Company Portal is deployed and provides a self-service software catalog to end users.
- Google Chrome Enterprise is available for optional installation through Company Portal.
- Remote uninstallation was validated, confirming centralized application lifecycle governance.