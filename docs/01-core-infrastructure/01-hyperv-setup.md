# 01 – Hyper-V Setup

---

## 🎯 Objective

Enable and configure Hyper-V on a Windows 10 Home host and prepare the virtualization layer required for the lab environment.

This step establishes the foundation where all virtual machines (Domain Controller and Workstations) will operate.

---

## 🖥 Host Environment

- Host OS: Windows 10 Home
- Virtualization Platform: Hyper-V
- Virtual Switch Type: External

---

## 🔧 Enabling Hyper-V on Windows 10 Home

Since Hyper-V is not exposed by default in Windows 10 Home, a batch script was used to manually install the necessary packages via DISM.

### Script Used (`enable-hyperv.bat`)

```bat
pushd "%~dp0"
dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyperv.txt
for /f %%i in ('findstr /i . hyperv.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"
del hyper-v.txt
Dism /online /enable-feature /featurename:Microsoft-Hyper-V -All /LimitAccess /ALL
pause
```

---

## 🌐 Virtual Switch Configuration (External)

---

### Why External?

An External Virtual Switch was selected because:
* The lab will later require synchronization with Microsoft Entra ID (Azure AD).
* Integration with tools such as Microsoft Intune and Action1 requires internet access.
* Domain-joined machines may require outbound connectivity.
* Future Entra Connect synchronization depends on external network communication.

An Internal or Private switch would not allow this level of connectivity.

---

### Creating the External Virtual Switch

* Name: BOCORP-SW01
* Connection type: External

📸 **Hyper-V virtual switch setup**
![Virtual Switch Configuration](/screenshots/01-01-virtualswitch.png)