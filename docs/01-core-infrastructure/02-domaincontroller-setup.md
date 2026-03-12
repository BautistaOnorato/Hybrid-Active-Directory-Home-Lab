# 02 – Domain Controller Setup

---

## 🎯 Objective

Deploy and configure the Domain Controller (DC-01) that will serve as the core identity and network services authority for the lab environment.

This section covers:

- Creating and configuring the DC-01 virtual machine in Hyper-V
- Installing Windows Server 2025
- Performing initial server configuration (hostname and static IP)
- Installing Active Directory Domain Services (AD DS)
- Promoting the server to Domain Controller
- Validating the deployment

---

## 🏗 Architecture Overview

DC-01 is the foundational server of the lab. All other components depend on it for authentication, name resolution, and directory services.

| Role | Details |
|------|---------|
| Active Directory Domain Services | Authoritative identity source for `bocorp.local` |
| DNS Server | Resolves internal hostnames and forwards external queries |
| Domain | `bocorp.local` |
| NetBIOS Name | `BOCORP` |

---

## 1️⃣ Virtual Machine Configuration

A new virtual machine was created in Hyper-V with the following settings:

| Setting | Value |
|---------|-------|
| VM Name | DC-01 |
| Startup Memory | 4096 MB |
| Dynamic Memory | Disabled |
| Processor | 2 vCPU |
| Virtual Disk | 80 GB (VHDX) |
| Network Adapter | BOCORP-SW01 |
| Installation Media | Windows Server 2025 Standard Evaluation (Desktop Experience) |

---

## 2️⃣ Windows Server Installation

Boot the virtual machine using the Windows Server 2025 ISO and proceed with the installation wizard.

When prompted for the edition, select:

```
Windows Server 2025 Standard Evaluation (Desktop Experience)
```

📸 **Installation setup screen with edition selection**

![Installation setup screen with edition selection](/screenshots/02/01.png)

📸 **First boot desktop after installation**

![First boot desktop after installation](/screenshots/02/02.png)

---

## 3️⃣ Initial Server Configuration

### 3.1 Rename the Server

Open **System Properties** and rename the server to:

```
DC-01
```

Restart the machine to apply the change.

📸 **System Properties showing the new computer name**

![Screenshot showing changed computer name](/screenshots/02/03.png)

---

### 3.2 Configure Static IP Address

Because this machine hosts DNS and Active Directory, it must use a static IP address. A dynamic address would break domain operations if it changed.

Open **Network Adapter Settings** and configure the following:

| Parameter | Value |
|-----------|-------|
| IP Address | 10.10.10.10 |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | 10.10.10.1 |
| Preferred DNS Server | 10.10.10.10 |

> The DNS server is set to the machine's own IP. After AD DS is installed, DC-01 will host the DNS zone for `bocorp.local` and must resolve its own name correctly.

📸 **Network settings showing static IP and DNS configuration**

![Network settings showing static IP and DNS config](/screenshots/02/04.png)

---

## 4️⃣ Install Active Directory Domain Services

Open **Server Manager** and add the AD DS role:

```
Server Manager → Add Roles and Features → Active Directory Domain Services
```

Include the required management tools when prompted.

📸 **Add Roles and Features Wizard with AD DS selected**

![Add Roles and Features Wizard with AD DS selected](/screenshots/02/05.png)

---

## 5️⃣ Promote Server to Domain Controller

After the role is installed, promote the server to Domain Controller using the post-installation wizard in Server Manager.

Configure the following:

| Setting | Value |
|---------|-------|
| Deployment operation | Add a new forest |
| Root domain name | `bocorp.local` |
| NetBIOS name | `BOCORP` |
| DSRM password | (set a strong password) |

Leave all other settings at their defaults and complete the wizard. The server will automatically reboot after the promotion process completes.

📸 **Domain configuration summary**

![Domain configuration summary](/screenshots/02/06.png)

---

## 🔎 Post-Installation Validation

After the reboot, log in using:

```
BOCORP\Administrator
```

📸 **Login screen showing BOCORP\Administrator**

![Login screen showing BOCORP\Administrator](/screenshots/02/07.png)

Run the following command in PowerShell to verify domain controller health:

```powershell
dcdiag
```

Confirm the following in Server Manager and administrative tools:

- Active Directory Users and Computers is accessible
- DNS Manager shows the forward lookup zone for `bocorp.local`

📸 **DNS Manager showing forward lookup zone for bocorp.local**

![DNS Manager showing forward lookup zone for bocorp.local](/screenshots/02/08.png)

---

## ✅ Outcome

After completing this section:

- DC-01 is deployed as a Windows Server 2025 virtual machine.
- The server is configured with a static IP address and self-referencing DNS.
- Active Directory Domain Services is installed and operational.
- DC-01 is the authoritative identity and DNS server for `bocorp.local`.
- The environment is ready for client deployment and domain join.