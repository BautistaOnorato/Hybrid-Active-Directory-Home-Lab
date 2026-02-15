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

## 🌐 Virtual Network Configuration (Internal + NAT)

---

### Why Internal + NAT?

This approach provides:

* Full isolation from the physical home network.
* A controlled lab environment using a dedicated subnet (10.10.10.0/24).
* Internet access through Network Address Translation (NAT).
* Greater flexibility for future routing and segmentation scenarios.

Virtual machines are not directly connected to the physical LAN.  
All outbound traffic is translated by the host using NAT.

---

### Network Configuration Method

The virtual network was created entirely using PowerShell on the host.


#### Step 1 – Create Internal Virtual Switch

Command used:

```powershell
New-VMSwitch -SwitchName "BOCORP-SW01" -SwitchType Internal
```

This created:

- An Internal Virtual Switch named **BOCORP-SW01**
- A new host adapter: vEthernet (BOCORP-SW01)

#### Step 2 – Identify the Interface Index

To configure the IP address of the new virtual adapter, the following command was used:

```powershell
Get-NetAdapter
```

The InterfaceIndex corresponding to: vEthernet (BOCORP-SW01) was identified (in this case: 65).

#### Step 3 – Assign Gateway IP to the Internal Adapter

Command used:

```powershell
New-NetIPAddress -IPAddress 10.10.10.1 -PrefixLength 24 -InterfaceIndex 65
```

This configuration:

* Assigned 10.10.10.1 to the host's internal adapter
* Defined the subnet 10.10.10.0/24
* Established the host as the default gateway for all lab virtual machines

---

### Step 4 – Create NAT Object

Command used:

```powershell
New-NetNat -Name BOCORP-NAT -InternalIPInterfaceAddressPrefix 10.10.10.0/24
```

This enabled address translation from: 10.10.10.0/24 → Physical Network (192.168.1.0/24)

---

### Design Considerations

* DC01 uses a static IP inside 10.10.10.0/24.
* All clients use DC01 as their DNS server.
* DNS forwarders are configured on DC01 for external resolution.
* The host performs NAT only and is not domain-joined.

This configuration ensures isolation, internet access, and enterprise-like segmentation while maintaining full control of the lab environment.
