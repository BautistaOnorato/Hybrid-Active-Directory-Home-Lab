# 05 – DHCP Configuration

---

## 🎯 Objective

Deploy and configure the DHCP Server role on DC-01 to provide automated IP address assignment for all domain-joined clients.

This section covers:

- Installing the DHCP Server role on DC-01
- Authorizing the DHCP server in Active Directory
- Creating and configuring the IP address scope
- Validating dynamic IP assignment on WS-01 and WS-02

---

## 🏗 Architecture Overview

The DHCP server is hosted on DC-01 and serves the `10.10.10.0/24` subnet used by all lab virtual machines.

| Parameter | Value |
|-----------|-------|
| DHCP Server | DC-01 (10.10.10.10) |
| Scope Name | Bocorp WS Scope |
| IP Range | 10.10.10.100 – 10.10.10.200 |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | 10.10.10.1 |
| DNS Server | 10.10.10.10 (DC-01) |
| DNS Domain Name | bocorp.local |
| Lease Duration | 1 day |

> In a production environment, DHCP should be hosted on a dedicated member server to maintain role separation. For this lab, hosting it on DC-01 is acceptable given the limited scope of the environment.

---

## 1️⃣ Install the DHCP Server Role

Open **Server Manager** on DC-01 and add the DHCP Server role:

```
Server Manager → Add Roles and Features → DHCP Server
```

Complete the wizard and install the role.

📸 **DHCP role installation summary**

![DHCP Role Installation Summary](/screenshots/05/01.png)

---

## 2️⃣ Authorize the DHCP Server in Active Directory

In a domain environment, DHCP servers must be authorized in Active Directory before they can issue leases. This prevents rogue DHCP servers from distributing IP configuration to domain clients.

Open the **DHCP Management Console** and authorize the server:

```
DHCP Management Console → Right-click the server → Authorize
```

Refresh the console and confirm the server status changes to **Authorized**.

---

## 3️⃣ Create and Configure the Scope

Open the **DHCP Management Console** and create a new IPv4 scope:

```
DHCP Management Console → IPv4 → Right-click → New Scope
```

Configure the scope with the following settings:

### Scope Settings

| Setting | Value |
|---------|-------|
| Scope Name | Bocorp WS Scope |
| Start IP | 10.10.10.100 |
| End IP | 10.10.10.200 |
| Subnet Mask | 255.255.255.0 |
| Lease Duration | 1 day |

### Scope Options

| Option | Value |
|--------|-------|
| 003 – Router | 10.10.10.1 |
| 006 – DNS Servers | 10.10.10.10 |
| 015 – DNS Domain Name | bocorp.local |

> A 1-day lease duration was configured to keep the lab flexible. Short leases allow IP addresses to be reclaimed quickly when machines are powered off, which is common in a lab environment.

📸 **DHCP scope and lease configuration**

![DHCP Scope and Lease configuration](/screenshots/05/02.png)

---

## 🔎 Validation

On each workstation, release and renew the IP address to confirm the DHCP server is issuing leases correctly:

```powershell
ipconfig /release
ipconfig /renew
ipconfig /all
```

Confirm the following in the output:

- IP address is within the `10.10.10.100–200` range
- Default Gateway is `10.10.10.1`
- DNS Server is `10.10.10.10`
- DHCP Server shows `10.10.10.10`

📸 **WS-01 IP configuration after DHCP renewal**

![WS-01 Validation](/screenshots/05/03.png)

![WS-01 Validation](/screenshots/05/04.png)

📸 **WS-02 IP configuration after DHCP renewal**

![WS-02 Validation](/screenshots/05/05.png)

![WS-02 Validation](/screenshots/05/06.png)

📸 **DHCP address leases showing both clients**

![DHCP Address Leases Showing Both Clients](/screenshots/05/07.png)

---

## ✅ Outcome

After completing this section:

- The DHCP Server role is installed and authorized on DC-01.
- The `Bocorp WS Scope` issues addresses in the `10.10.10.100–200` range.
- Scope options distribute the correct gateway, DNS server, and domain name to all clients.
- WS-01 and WS-02 are receiving valid IP configuration dynamically.
- The network layer is fully automated for all domain-joined endpoints.
