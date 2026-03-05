# 17 – Monitoring Server Installation (MON-01)

---

## 🎯 Objective

Deploy a dedicated Linux server that will later be used for infrastructure monitoring.

This server will host the monitoring stack implemented in the next sections and will provide visibility into the health and performance of the hybrid infrastructure.

The monitoring server is deployed using **Debian 13 (Trixie)** with a minimal installation to reduce attack surface and resource usage.

---

## 🖥️ Server Overview

| Server | Role              | OS            | IP          |
| ------ | ----------------- | ------------- | ----------- |
| MON-01 | Monitoring Server | Debian 13.3.0 | 10.10.10.20 |

📸 **MON-01 VM Settings**

![MON-01 VM Settings](/screenshots/17/01.png)

---

## 1. Download Debian ISO

Download the official **Debian 13.3.0 (Trixie)** installation ISO.

Official source:

https://www.debian.org

The ISO used in this lab:

```
Debian GNU/Linux 13.3.0 amd64 DVD
```

---

## 2. Install Debian

Boot the virtual machine using the Debian ISO and proceed with the installation wizard.

📸 **Graphical Install selected**

![Graphical Install selected](/screenshots/17/02.png)

📸 **Hostname**

![Hostname](/screenshots/17/05.png)

📸 **Set up users and passwords**

![Set up users and passwords](/screenshots/17/06.png)
![Set up users and passwords](/screenshots/17/07.png)

### Disk Partitioning

Guided partitioning was used to separate critical filesystem paths.

This improves maintainability and prevents services such as logging or monitoring data from filling the entire disk.

The following partitions were created:

| Mount Point | Purpose                  |
| ----------- | ------------------------ |
| `/`         | Root filesystem          |
| `/var`      | Logs and monitoring data |
| `/tmp`      | Temporary files          |
| `/home`     | User home directories    |
| `swap`      | System swap memory       |

Separating `/var` is particularly important for monitoring servers, since logs and time-series data can grow quickly.

📸 **Configured partitions overview**

![Configured partitions overview](/screenshots/17/08.png)

### Selected Components

During the **Software Selection** step, only the following components were installed:

* SSH Server
* Standard System Utilities

No graphical interface was installed in order to keep the system lightweight and optimized for server workloads.

📸 **Software selection screen**

![Software selection screen](/screenshots/17/09.png)

📸 **First login**

![First login](/screenshots/17/10.png)

---

## 4. Configure APT Repositories

After installation, the default repository configuration was updated.

Edit:

```
/etc/apt/sources.list
```

Replace the content with:

```
#deb cdrom:[Debian GNU/Linux 13.3.0 _Trixie_ - Official amd64 DVD Binary-1 with firmware 20260110-11:00]/ trixie contrib main non-free-firmware
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
```

---

## 5. Update the System

Update the package lists and upgrade installed packages:

```
apt update
apt upgrade -y
```

Install **sudo** to allow privilege escalation for administrative tasks:

```
apt install sudo
```

---

## 6. Configure Network

The monitoring server was configured with a **static IP address**.

Edit the file:

```
/etc/network/interfaces
```

Configuration:

```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
    address 10.10.10.20
    netmask 255.255.255.0
    gateway 10.10.10.1
    dns-nameservers 10.10.10.10
```

Network parameters:

| Parameter   | Value         |
| ----------- | ------------- |
| IP Address  | 10.10.10.20   |
| Subnet Mask | 255.255.255.0 |
| Gateway     | 10.10.10.1    |
| DNS Server  | 10.10.10.10   |

The DNS server corresponds to the **domain controller** of the lab environment.

---

## ✅ Outcome

At the end of this phase:

* Debian 13 is installed
* The system is updated
* SSH access is enabled
* A static network configuration is applied
* Administrative privileges are available via `sudo`

The server **MON-01** is now ready for the deployment of the monitoring stack in the next section.
