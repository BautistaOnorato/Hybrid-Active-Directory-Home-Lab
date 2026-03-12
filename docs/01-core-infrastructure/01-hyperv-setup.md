# 01 – Hyper-V Setup

---

## 🎯 Objective

Enable and configure Hyper-V on a Windows 10 Home host and prepare the virtualization layer required for the lab environment.

This section covers:

- Enabling Hyper-V on Windows 10 Home using a DISM script
- Creating an Internal Virtual Switch for lab network isolation
- Configuring NAT to provide internet access to virtual machines

---

## 🏗 Architecture Overview

The virtual network implemented in this lab:

```
Virtual Machines (10.10.10.0/24)
        ↓
Internal Virtual Switch (BOCORP-SW01)
        ↓
Host vEthernet Adapter (10.10.10.1) – Default Gateway
        ↓
NAT (BOCORP-NAT)
        ↓
Physical Network / Internet
```

### Why Internal + NAT?

Several virtual switch configurations were evaluated before selecting Internal + NAT:

| Option | Reason |
|--------|--------|
| External Switch (bridged) | Exposes VMs directly to the physical home network — reduces isolation |
| Private Switch | No internet access — prevents future cloud integration with Microsoft Entra ID |
| Internal + NAT | ✔ Full network isolation with controlled internet access through the host |

This approach provides:

- A dedicated subnet (`10.10.10.0/24`) isolated from the physical home network
- Internet access through Network Address Translation on the host
- Greater flexibility for future routing and segmentation scenarios

Virtual machines are not directly connected to the physical LAN. All outbound traffic is translated by the host using NAT.

---

## 1️⃣ Enable Hyper-V on Windows 10 Home

Hyper-V is not exposed by default on Windows 10 Home. A batch script was used to manually install the required packages via DISM.

### Script: [`enable-hyperv.bat`](/scripts/enable-hyperv.bat)

```bat
pushd "%~dp0"
dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyperv.txt
for /f %%i in ('findstr /i . hyperv.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"
del hyperv.txt
Dism /online /enable-feature /featurename:Microsoft-Hyper-V -All /LimitAccess /ALL
pause
```

Run the script as Administrator and restart the machine when prompted.

---

## 2️⃣ Create Internal Virtual Switch

The virtual switch was created using PowerShell on the host.

### 2.1 Create the Switch

```powershell
New-VMSwitch -SwitchName "BOCORP-SW01" -SwitchType Internal
```

This creates:

- An Internal Virtual Switch named **BOCORP-SW01**
- A new host adapter: `vEthernet (BOCORP-SW01)`

---

### 2.2 Identify the Interface Index

To configure the IP address on the new virtual adapter, its interface index must be retrieved:

```powershell
Get-NetAdapter
```

Identify the `InterfaceIndex` corresponding to `vEthernet (BOCORP-SW01)`.

---

### 2.3 Assign Gateway IP to the Host Adapter

```powershell
New-NetIPAddress -IPAddress 10.10.10.1 -PrefixLength 24 -InterfaceIndex <index>
```

This configuration:

- Assigns `10.10.10.1` to the host's internal adapter
- Defines the subnet `10.10.10.0/24`
- Establishes the host as the default gateway for all lab virtual machines

---

## 3️⃣ Configure NAT

```powershell
New-NetNat -Name "BOCORP-NAT" -InternalIPInterfaceAddressPrefix 10.10.10.0/24
```

This enables address translation from `10.10.10.0/24` to the physical network, allowing virtual machines to reach the internet through the host.

---

## 🔎 Validation

Verify the virtual switch was created:

```powershell
Get-VMSwitch -Name "BOCORP-SW01"
```

Verify the NAT object was created:

```powershell
Get-NetNat -Name "BOCORP-NAT"
```

Verify the host adapter has the correct IP:

```powershell
Get-NetIPAddress -InterfaceAlias "vEthernet (BOCORP-SW01)"
```

---

## ✅ Outcome

After completing this section:

- Hyper-V is enabled and operational on the Windows 10 Home host.
- An Internal Virtual Switch (**BOCORP-SW01**) provides an isolated lab network.
- The host adapter is configured as the default gateway (`10.10.10.1`) for the `10.10.10.0/24` subnet.
- NAT is configured to allow virtual machines to access the internet through the host.
- The virtualization layer is ready for Domain Controller and workstation deployment.
