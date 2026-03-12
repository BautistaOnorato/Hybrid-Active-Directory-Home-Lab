# 19 – Zabbix Agent Deployment

---

## 🎯 Objective

Deploy Zabbix Agent 2 on all monitored Windows hosts to enable centralized metric collection from MON-01.

This section covers:

- Creating a dedicated security group to control which hosts receive the monitoring GPO
- Creating and configuring a GPO to open the Zabbix agent firewall port
- Downloading and installing Zabbix Agent 2 on DC-01, WS-01, and WS-02
- Validating agent connectivity from MON-01

---

## 🏗 Architecture Overview

Zabbix Agent 2 runs as a Windows service on each monitored host and listens on TCP port 10050. MON-01 connects to each agent on this port to collect metrics.

| Host | Role | IP |
|------|------|----|
| DC-01 | Domain Controller | 10.10.10.10 (static) |
| WS-01 | Workstation | DHCP |
| WS-02 | Workstation | DHCP |

### Deployment Strategy

A dedicated security group (`GG-Zabbix-WS`) controls which machines receive the Zabbix firewall GPO. This approach ensures the firewall rule is applied only to monitored hosts regardless of their OU placement, and makes it easy to add or remove hosts from monitoring scope by modifying group membership.

```
GG-Zabbix-WS (DC-01, WS-01, WS-02)
        ↓
GPO-Zabbix-Firewall (Security Filtering)
        ↓
Inbound rule: TCP 10050 allowed
        ↓
Zabbix Agent 2 (listening on TCP 10050)
        ↓
MON-01 (10.10.10.20) → zabbix_get / Zabbix Server
```

---

## 1️⃣ Create Security Group – GG-Zabbix-WS

On **DC-01**, open **Active Directory Users and Computers** and navigate to:

```
bocorp.local → _Groups → Global
```

Right-click → **New** → **Group** and configure:

| Field | Value |
|-------|-------|
| Group name | `GG-Zabbix-WS` |
| Group scope | Global |
| Group type | Security |

After creating the group, open it and add the following computer objects as members:

```
DC-01
WS-01
WS-02
```

📸 **GG-Zabbix-WS group membership**

![GG-Zabbix-WS group membership](/screenshots/19/01.png)

---

## 2️⃣ Create GPO – GPO-Zabbix-Firewall

### 2.1 Create the GPO

On **DC-01**, open the **Group Policy Management Console** and create a new GPO:

```
Group Policy Management → bocorp.local → Group Policy Objects → New
```

**GPO Name:** `GPO-Zabbix-Firewall`

---

### 2.2 Configure the Inbound Firewall Rule

Right-click `GPO-Zabbix-Firewall` → **Edit** and navigate to:

```
Computer Configuration → Policies → Windows Settings → Security Settings
→ Windows Defender Firewall with Advanced Security → Inbound Rules
```

Right-click **Inbound Rules** → **New Rule** and configure:

| Setting | Value |
|---------|-------|
| Rule type | Port |
| Protocol | TCP |
| Specific local ports | 10050 |
| Action | Allow the connection |
| Profile | Domain, Private, Public |
| Name | `Zabbix Agent` |

📸 **Inbound rule configured in GPO**

![Inbound rule configured in GPO](/screenshots/19/02.png)

---

### 2.3 Configure Security Filtering

By default, GPOs apply to all **Authenticated Users**. The security filtering was updated to restrict application to members of `GG-Zabbix-WS` only.

In GPMC, click `GPO-Zabbix-Firewall` → **Scope** tab → **Security Filtering**:

1. Select **Authenticated Users** → click **Remove** → confirm
2. Click **Add** → search for `GG-Zabbix-WS` → click **OK**

Navigate to the **Delegation** tab → **Advanced** → **Add** → search for `GG-Zabbix-WS` and confirm the following permissions:

| Permission | Allow |
|------------|-------|
| Read | ✔ |
| Apply Group Policy | ✔ |

---

### 2.4 Link the GPO

Since DC-01 resides in the **Domain Controllers** OU and workstations reside in the **Workstations** OU, the GPO was linked to both:

```
bocorp.local → Workstations → Link an Existing GPO → GPO-Zabbix-Firewall
bocorp.local → Domain Controllers → Link an Existing GPO → GPO-Zabbix-Firewall
```

📸 **GPO scope showing security filtering and OU links**

![Security Filtering + OU links](/screenshots/19/03.png)

---

### 2.5 Apply and Validate the GPO

On each Windows host, apply the GPO and verify the firewall rule was created:

```powershell
gpupdate /force

Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*Zabbix*" } | Select-Object DisplayName, Enabled, Action
```

---

## 3️⃣ Download Zabbix Agent 2

Download the Zabbix Agent 2 MSI installer from the official Zabbix website:

```
https://www.zabbix.com/download_agents
```

Select the following options:

| Field | Value |
|-------|-------|
| Version | 7.0 LTS |
| OS | Windows |
| OS Version | Server 2016+ (DC-01) / Windows 10/11 (WS-01, WS-02) |
| Hardware | amd64 |
| Encryption | OpenSSL |
| Package | MSI |

📸 **Zabbix pre-compiled agent download page**

![Zabbix pre-compiled agent binaries](/screenshots/19/04.png)

---

## 4️⃣ Install Zabbix Agent 2

Run the MSI installer as Administrator on each host and configure the following settings during setup:

| Field | DC-01 | WS-01 | WS-02 |
|-------|-------|-------|-------|
| Zabbix server IP | 10.10.10.20 | 10.10.10.20 | 10.10.10.20 |
| Hostname | DC-01 | WS-01 | WS-02 |
| Server port | 10051 | 10051 | 10051 |
| Listen port | 10050 | 10050 | 10050 |

The agent registers itself as a Windows service named **Zabbix Agent 2** upon completion.

📸 **Zabbix Agent 2 installation wizard**

![Zabbix Agent 2 installation wizard](/screenshots/19/05.png)

---

## 🔎 Validation

### Verify the Agent Service

On each host, confirm the Zabbix Agent 2 service is running:

```powershell
Get-Service -Name "ZabbixAgent2"
```

Expected output:

```
Status   Name          DisplayName
------   ----          -----------
Running  ZabbixAgent2  Zabbix Agent 2
```

📸 **Zabbix Agent 2 running on DC-01**

![Zabbix Agent 2 Running on DC-01](/screenshots/19/06.png)

📸 **Zabbix Agent 2 running on WS-01**

![Zabbix Agent 2 Running on WS-01](/screenshots/19/07.png)

📸 **Zabbix Agent 2 running on WS-02**

![Zabbix Agent 2 Running on WS-02](/screenshots/19/08.png)

---

### Verify Connectivity from MON-01

Install the Zabbix diagnostic tool on **MON-01**:

```bash
apt install zabbix-get -y
```

Test connectivity against each host using the `agent.ping` key:

```bash
zabbix_get -s 10.10.10.10 -p 10050 -k agent.ping
zabbix_get -s 10.10.10.101 -p 10050 -k agent.ping
zabbix_get -s 10.10.10.102 -p 10050 -k agent.ping
```

Each command should return `1`, confirming the agent is reachable and responding correctly.

📸 **Connectivity test from MON-01 – DC-01**

![Connectivity test from MON-01](/screenshots/19/09.png)

📸 **Connectivity test from MON-01 – WS-01**

![Connectivity test from MON-01](/screenshots/19/10.png)

📸 **Connectivity test from MON-01 – WS-02**

![Connectivity test from MON-01](/screenshots/19/11.png)

---

## ✅ Outcome

After completing this section:

- `GG-Zabbix-WS` controls which hosts receive the monitoring firewall rule via security filtering.
- `GPO-Zabbix-Firewall` deploys the inbound TCP 10050 rule to all members of `GG-Zabbix-WS`.
- Zabbix Agent 2 is installed and running on DC-01, WS-01, and WS-02.
- MON-01 has confirmed connectivity to all three agents via `zabbix_get`.
- The environment is ready for host registration in the Zabbix web interface.