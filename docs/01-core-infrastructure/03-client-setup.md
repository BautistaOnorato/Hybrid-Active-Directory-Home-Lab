# 03 – Client Setup (WS-01 & WS-02)

---

## 🎯 Objective

Deploy and configure two Windows 11 Pro workstations that will serve as domain-joined endpoints in the lab environment.

This section covers:

- Creating and configuring the WS-01 virtual machine in Hyper-V
- Installing Windows 11 Pro on WS-01
- Creating a checkpoint to use as a base image for WS-02
- Deploying WS-02 from the WS-01 checkpoint
- Configuring hostnames and network settings on both machines
- Joining both workstations to the `bocorp.local` domain
- Validating the domain join from DC-01

---

## 🏗 Architecture Overview

Two workstations are deployed in this section:

| Machine | Deployment Method | IP Assignment |
|---------|------------------|---------------|
| WS-01 | Manual installation | DHCP (10.10.10.100–200) |
| WS-02 | Deployed from WS-01 checkpoint | DHCP (10.10.10.100–200) |

### Why Deploy WS-02 from a Checkpoint?

Creating WS-02 from a checkpoint of WS-01 avoids repeating the full Windows installation process. The checkpoint is taken before the domain join so that both machines start from a clean, identical baseline without SID conflicts or duplicate computer objects in Active Directory.

---

## 1️⃣ Install Windows 11 Pro on WS-01

### 1.1 Virtual Machine Configuration

A new virtual machine was created in Hyper-V with the following settings:

| Setting | Value |
|---------|-------|
| VM Name | WS-01 |
| Startup Memory | 4096 MB |
| Dynamic Memory | Disabled |
| Processor | 2 vCPU |
| Virtual Disk | 60 GB (VHDX) |
| Network Adapter | BOCORP-SW01 |
| Installation Media | Windows 11 Pro |

📸 **Hyper-V VM settings for WS-01**

![Hyper-V VM settings for WS-01](/screenshots/03/01.png)

---

### 1.2 Windows Installation

Boot the virtual machine using the Windows 11 Pro ISO and complete the installation wizard.

During setup, create a temporary local administrator account. This account will no longer be needed once the machine is joined to the domain.

📸 **First login screen**

![First login screen](/screenshots/03/02.png)

---

## 2️⃣ Create Checkpoint of WS-01

Before configuring the hostname or joining the domain, a checkpoint was created to serve as the base image for WS-02.

Shut down WS-01, then in Hyper-V Manager:

```
Right-click WS-01 → Checkpoint
```

Name the checkpoint:

```
Windows 11 Pro - Clean Install
```

📸 **Windows 11 Pro clean install checkpoint**

![Windows 11 Pro clean install checkpoint](/screenshots/03/03.png)

> Taking the checkpoint before domain join prevents SID conflicts and ensures both machines start from an identical, unconfigured baseline.

---

## 3️⃣ Deploy WS-02 from Checkpoint

WS-02 was provisioned by exporting WS-01 and importing it as a new virtual machine.

In Hyper-V Manager:

```
Right-click WS-01 → Export
```

Once the export completes:

```
Action → Import Virtual Machine → select the exported folder → Copy the virtual machine
```

Rename the imported VM to `WS-02`.

📸 **WS-02 created from WS-01 checkpoint**

![WS-02 Created from WS-01 checkpoint](/screenshots/03/04.png)

---

## 4️⃣ Configure Hostname and Network

Each workstation was configured with a unique hostname and network settings before joining the domain.

---

### 4.1 WS-01 Configuration

Rename the computer to `WS-01` via **System Properties** and restart.

Network configuration:

| Parameter | Value |
|-----------|-------|
| IP Assignment | DHCP |
| DNS Server | 10.10.10.10 (DC-01) |
| Default Gateway | 10.10.10.1 |

📸 **Network settings for WS-01**

![Network settings for WS-01](/screenshots/03/05.png)

📸 **System Properties showing WS-01 hostname**

![Screenshot showing WS-01 name](/screenshots/03/06.png)

---

### 4.2 WS-02 Configuration

Rename the computer to `WS-02` via **System Properties** and restart.

Network configuration:

| Parameter | Value |
|-----------|-------|
| IP Assignment | DHCP |
| DNS Server | 10.10.10.10 (DC-01) |
| Default Gateway | 10.10.10.1 |

📸 **Network settings for WS-02**

![Network settings for WS-02](/screenshots/03/07.png)

📸 **System Properties showing WS-02 hostname**

![Screenshot showing WS-02 name](/screenshots/03/08.png)

> DNS must point to DC-01 before the domain join. Without correct DNS configuration, the workstation cannot locate the domain controller and the join process will fail.

---

## 5️⃣ Join Both Machines to the Domain

On each workstation, open **System Properties** and join the domain:

```
System Properties → Computer Name → Change → Domain → bocorp.local
```

When prompted, provide domain administrator credentials:

```
BOCORP\Administrator
```

Restart the machine when prompted.

---

## 🔎 Post-Domain Join Validation

### Verify in Active Directory

On **DC-01**, open **Active Directory Users and Computers** and confirm that both WS-01 and WS-02 appear in the `Computers` container.

📸 **ADUC showing both workstations joined to the domain**

![Screenshot of ADUC after both WS joined the domain](/screenshots/03/09.png)

---

### Verify Domain Login

On each workstation, log in using a domain account to confirm authentication is working correctly:

```
BOCORP\Administrator
```

📸 **WS-01 logged in as BOCORP\Administrator**

![WS-01 logged in as BOCORP\Administrator](/screenshots/03/10.png)

📸 **WS-02 logged in as BOCORP\Administrator**

![WS-02 logged in as BOCORP\Administrator](/screenshots/03/11.png)

---

## ✅ Outcome

After completing this section:

- WS-01 was deployed via a full Windows 11 Pro installation.
- A clean checkpoint was created before domain join to serve as the base image for WS-02.
- WS-02 was provisioned from the WS-01 checkpoint, avoiding a duplicate installation.
- Both workstations are configured with unique hostnames and correct DNS settings.
- WS-01 and WS-02 are joined to the `bocorp.local` domain.
- Domain authentication was validated on both machines.

The lab environment now includes:

- ✔ One Domain Controller (DC-01)
- ✔ Two domain-joined workstations (WS-01 and WS-02)
- ✔ A functional Active Directory infrastructure