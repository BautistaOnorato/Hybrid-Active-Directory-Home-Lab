# 02 – Domain Controller Setup

---

## 🎯 Objective

Deploy and configure the first Domain Controller (DC01) that will host:

- Active Directory Domain Services (AD DS)
- DNS Server
- DHCP Server (later)
- The core identity infrastructure of the lab

This server will become the authentication and directory authority for all domain-joined machines.

---

## 🖥 Virtual Machine Configuration

### General Settings

- VM Name: DC01
- Startup Memory: 4096 MB
- Processor: 2 vCPU
- Virtual Disk: 80 GB (VHDX)
- Installation Media: Windows Server 2025 Standard Evaluation (Desktop Experience)

📸 **Installation setup screen with edition selection**

![Installation setup screen with edition selection](/screenshots/02/01.png)

📸 **First boot desktop after installation**

![First boot desktop after installation](/screenshots/02/02.png)

---

## 🛠 Initial Server Configuration

After the first login:

### 1. Rename the Server

Rename the server to DC01 and restart it to apply the change.

📸 **Screenshot showing changed computer name**

![Screenshot showing changed computer name](/screenshots/02/03.png)

---

### 2. Configure Static IP Address

Because this machine will host DNS and Active Directory, it must use a static IP address.

Example configuration used in the lab:

- IP Address: 10.10.10.10
- Subnet Mask: 255.255.255.0
- Default Gateway: 10.10.10.1
- Preferred DNS Server: 10.10.10.10

📸 **Network settings showing static IP and DNS config**

![Network settings showing static IP and DNS config](/screenshots/02/04.png)

---

## 📦 Install Active Directory Domain Services

Install the Active Directory Domain Services role along with the required management tools.

📸 **"Add Roles and Features Wizard" with AD DS selected**

!["Add Roles and Features Wizard" with AD DS selected](/screenshots/02/05.png)

---

## 🌳 Promote Server to Domain Controller

Promote the server by:

- Creating a new forest
- Defining the root domain name as: bocorp.local
- Setting the NetBIOS name as: BOCORP
- Defining the Directory Services Restore Mode (DSRM) password

The server will automatically reboot after the promotion process completes.

📸 **Domain configuration summary**

![Domain configuration summary](/screenshots/02/06.png)

---

## 🔎 Post-Installation Checks

After reboot:

- Logged in using BOCORP\Administrator
- Confirmed the domain bocorp.local exists
- Verified domain controller health using dcdiag in PowerShell
- Verified Active Directory Users and Computers is accessible
- Verified DNS Manager shows the proper forward lookup zone

📸 **Login screen showing BOCORP\Administrator**

![Log in screen showing BOCORP\Administrator](/screenshots/02/07.png)

📸 **DNS Manager showing forward lookup zone for ```bocorp.local```**

![DNS Manager showing forward lookup zone for bocorp.local](/screenshots/02/08.png)

---

## ✅ Outcome

By completing this phase:

- A Windows Server virtual machine was successfully deployed.
- The server was renamed and configured with a static IP address.
- Active Directory Domain Services was installed.
- DC01 is now the authoritative identity and DNS server for the lab environment.
