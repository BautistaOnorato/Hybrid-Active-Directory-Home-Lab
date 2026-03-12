# 17 – Monitoring Server Deployment (MON-01)

---

## 🎯 Objective

Deploy and configure the dedicated Linux server that will host the monitoring stack for the lab infrastructure.

This section covers:

- Creating and configuring the MON-01 virtual machine in Hyper-V
- Installing Debian 13 (Trixie) with a minimal server configuration
- Partitioning the disk with separated mount points for monitoring workloads
- Configuring APT repositories and updating the system
- Assigning a static IP address and configuring DNS

---

## 🏗 Architecture Overview

MON-01 is deployed as a lightweight, dedicated monitoring server isolated from the Windows domain. Running the monitoring stack on a separate Linux server ensures that monitoring remains operational independently of the domain infrastructure it observes.

| Setting | Value |
|---------|-------|
| Hostname | MON-01 |
| OS | Debian 13.3.0 (Trixie) |
| IP Address | 10.10.10.20 (static) |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | 10.10.10.1 |
| DNS Server | 10.10.10.10 (DC-01) |

### Disk Partitioning

The disk was partitioned with separated mount points to prevent monitoring data from filling the root filesystem and to improve maintainability:

| Mount Point | Purpose |
|-------------|---------|
| `/` | Root filesystem |
| `/var` | Logs and monitoring data |
| `/tmp` | Temporary files |
| `/home` | User home directories |
| `swap` | System swap memory |

> Separating `/var` is particularly important for monitoring servers. Zabbix stores metric history and logs under `/var`, which can grow significantly over time. A dedicated partition prevents a full `/var` from impacting the rest of the system.

---

## 1️⃣ Virtual Machine Configuration

A new virtual machine was created in Hyper-V with the following settings:

| Setting | Value |
|---------|-------|
| VM Name | MON-01 |
| Generation | Generation 2 |
| Startup Memory | 3072 MB |
| Dynamic Memory | Disabled |
| Virtual Disk | 20 GB (VHDX) |
| Network Adapter | BOCORP-SW01 |
| Installation Media | Debian 13.3.0 (Trixie) |

📸 **MON-01 VM settings**

![MON-01 VM Settings](/screenshots/17/01.png)

---

## 2️⃣ Install Debian 13

Boot the virtual machine using the Debian 13 ISO and proceed with the graphical installation wizard.

📸 **Graphical Install selected**

![Graphical Install selected](/screenshots/17/02.png)

---

### 2.1 Configure Hostname and Domain

| Setting | Value |
|---------|-------|
| Hostname | `MON-01` |
| Domain | `bocorp.local` |

📸 **Hostname configuration**

![Hostname](/screenshots/17/03.png)

---

### 2.2 Configure Users

Create the root password and a standard user account during setup.

📸 **Root password and user account configuration**

![Set up users and passwords](/screenshots/17/04.png)

![Set up users and passwords](/screenshots/17/05.png)

---

### 2.3 Disk Partitioning

Select **Guided partitioning** and configure separate partitions for the mount points listed in the Architecture Overview.

📸 **Configured partitions overview**

![Configured partitions overview](/screenshots/17/06.png)

---

### 2.4 Software Selection

During the **Software Selection** step, install only the minimum required components:

| Component | Selected |
|-----------|---------|
| SSH Server | ✔ Yes |
| Standard System Utilities | ✔ Yes |
| Desktop environment | ✘ No |

No graphical interface was installed to keep the server lightweight and optimized for server workloads.

📸 **Software selection**

![Software selection screen](/screenshots/17/07.png)

📸 **First login after installation**

![First login](/screenshots/17/08.png)

---

## 3️⃣ Configure APT Repositories

After installation, the default repository configuration was updated to remove the CD-ROM source and add the full Debian package repositories.

Edit `/etc/apt/sources.list` and replace the content with:

```
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
```

---

## 4️⃣ Update the System

Update the package lists, upgrade all installed packages, and install `sudo`:

```bash
apt update
apt upgrade -y
apt install sudo -y
```

Adding `sudo` allows privilege escalation for administrative tasks without requiring direct root login.

---

## 5️⃣ Configure Static IP Address

Edit `/etc/network/interfaces` and configure a static IP address for the primary network interface:

```
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.10.10.20
    netmask 255.255.255.0
    gateway 10.10.10.1
    dns-nameservers 10.10.10.10
```

Apply the configuration:

```bash
systemctl restart networking
```

> The DNS server is set to DC-01 (`10.10.10.10`). This allows MON-01 to resolve `bocorp.local` hostnames, which is required for Zabbix to connect to monitored hosts using DNS names instead of static IPs.

---

## 🔎 Validation

Verify the static IP address was applied correctly:

```bash
ip addr show eth0
```

Verify connectivity to the domain controller and internet:

```bash
ping -c 4 10.10.10.10
ping -c 4 8.8.8.8
```

Verify DNS resolution of domain hostnames:

```bash
nslookup DC-01.bocorp.local
```

---

## ✅ Outcome

After completing this section:

- MON-01 is deployed as a Debian 13 virtual machine on the `BOCORP-SW01` internal switch.
- The disk is partitioned with a dedicated `/var` mount point to isolate monitoring data growth.
- SSH access is enabled for remote administration.
- The system is fully updated and `sudo` is available for privilege escalation.
- MON-01 is configured with a static IP address of `10.10.10.20` and uses DC-01 as its DNS server.
- The server is ready for Zabbix installation.