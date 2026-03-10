# 19 – Zabbix Agent Deployment

---

## 🎯 Objective

Deploy Zabbix Agent 2 on all monitored Windows hosts to enable centralized metric collection from MON-01.

This section covers:

- Creating a dedicated security group for monitored hosts
- Configuring a Group Policy Object to open the required firewall port
- Downloading and installing Zabbix Agent 2 on all Windows hosts
- Validating agent connectivity from MON-01

---

## 🏗 Architecture Overview

The following hosts will be monitored:

| Host | Role | IP |
|------|------|----|
| DC-01 | Domain Controller | 10.10.10.10 |
| WS-01 | Workstation | 10.10.10.100 |
| WS-02 | Workstation | 10.10.10.103 |

The Zabbix Agent 2 service runs on each host and listens on **TCP port 10050**.  
MON-01 connects to each agent on this port to collect metrics.

---

## 1. Create Security Group – GG-Zabbix-WS

A dedicated security group was created to control which machines receive the Zabbix firewall GPO.

This approach ensures that the firewall rule is only deployed to monitored hosts, regardless of their OU placement.

### Steps

On **DC-01**, open **Active Directory Users and Computers**.

Navigate to:

```
bocorp.local → _Groups → Global
```

Right-click → **New** → **Group**

Configure:

| Field | Value |
|-------|-------|
| Group name | GG-Zabbix-WS |
| Group scope | Global |
| Group type | Security |

Click **OK**.

### Add Computer Objects to the Group

Open the group **GG-Zabbix-WS** → tab **Members** → **Add**.

Add the following computer objects:

```
DC-01
WS-01
WS-02
```

📸 **GG-Zabbix-WS group membership**

![GG-Zabbix-WS group membership](/screenshots/19/03.png)

---

## 2. Create GPO – GPO-Zabbix-Firewall

A Group Policy Object was created to deploy an inbound firewall rule for TCP port 10050 on all monitored hosts.

### 2.1 Create the GPO

On **DC-01**, open **Group Policy Management Console**:

```
Start → Windows Administrative Tools → Group Policy Management
```

In the left panel:

1. Expand **bocorp.local**
2. Right-click **Group Policy Objects**
3. Select **New**
4. Name it: `GPO-Zabbix-Firewall`
5. Click **OK**

---

### 2.2 Configure the Inbound Firewall Rule

Right-click `GPO-Zabbix-Firewall` → **Edit**.

Navigate to:

```
Computer Configuration
→ Policies
→ Windows Settings
→ Security Settings
→ Windows Defender Firewall with Advanced Security
→ Windows Defender Firewall with Advanced Security
→ Inbound Rules
```

Right-click **Inbound Rules** → **New Rule**.

Follow the wizard with these settings:

| Setting | Value |
|------|-------|
| Rule Type | Port |
| Protocol | TCP |
| Specific local ports |10050 |
| Action | Allow the connection |
| Profile | Domain, Private, Public |
| Name | Zabbix Agent |

Click **Finish**.

📸 **Inbound rule configured in GPO**

![Inbound rule configured in GPO](/screenshots/19/05.png)

---

### 2.3 Configure Security Filtering

By default, GPOs apply to **Authenticated Users**. The security filtering was updated to restrict application to members of **GG-Zabbix-WS** only.

In GPMC, click on `GPO-Zabbix-Firewall` → tab **Scope**.

Under **Security Filtering**:

1. Select **Authenticated Users** → click **Remove** → confirm the warning
2. Click **Add** → search for `GG-Zabbix-WS` → click **OK**

Then navigate to the **Delegation** tab → **Advanced**.

Click **Add** → search for `GG-Zabbix-WS` → **OK**.

Confirm the following permissions are set:

| Permission | Allow |
|------------|-------|
| Read | ✔ |
| Apply Group Policy | ✔ |

Click **OK** to save.

---

### 2.4 Link GPO to Both OUs

Since DC-01 resides in the **Domain Controllers** OU and the workstations reside in the **Workstations** OU, the GPO was linked to both.

**Link to Workstations OU:**

Right-click:

```
bocorp.local → Workstations
```

Select **Link an Existing GPO** → choose `GPO-Zabbix-FirewallRule` → **OK**

**Link to Domain Controllers OU:**

Right-click:

```
bocorp.local → Domain Controllers
```

Select **Link an Existing GPO** → choose `GPO-Zabbix-FirewallRule` → **OK**

📸 **GG-Zabbix-WS Scope tab**

![Security Filtering + OU links](/screenshots/19/04.png)

---

### 2.5 Apply and Validate GPO

On each Windows host, run:

```powershell
gpupdate /force
```

Validate the firewall rule was applied:

```powershell
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Zabbix*"} | Select DisplayName, Enabled, Action
```

---

## 3. Download Zabbix Agent 2

Download the Zabbix Agent 2 MSI installer from the official site:

```
https://www.zabbix.com/download_agents
```

Select:

| Field | Value |
|-------|-------|
| Version | 7.0 LTS |
| OS | Windows |
| OS Version | **DC-01:** Server 2016 + / **WS-01/2:** 11, 10 |
| Hardware | amd64 |
| Encryption | OpenSSL |
| Package | MSI |

![Security Filtering + OU links](/screenshots/19/01.png)

---

## 4. Install Zabbix Agent 2 on Windows Hosts

Run the MSI installer as Administrator on each host.

During setup, configure the following:

| Field | DC-01 | WS-01 | WS-02 |
|-------|-------|-------|-------|
| Zabbix server IP | 10.10.10.20 | 10.10.10.20 | 10.10.10.20 |
| Hostname | DC-01 | WS-01 | WS-02 |
| Server port | 10051 | 10051 | 10051 |
| Listen port | 10050 | 10050 | 10050 |

Complete the installation on each host. The agent registers itself as a Windows service named **Zabbix Agent 2**.

📸 **Zabbix Agent 2 installation wizard**

![Zabbix Agent 2 installation wizard](/screenshots/19/02.png)

---

## 5. Verify Agent Service

On each host, verify the agent service is running:

```powershell
Get-Service -Name "ZabbixAgent2"
```

Expected output:

```
Status   Name          DisplayName
------   ----          -----------
Running  ZabbixAgent2  Zabbix Agent 2
```

📸 **Zabbix Agent 2 Running on DC-01**

![Zabbix Agent 2 Running on DC-01](/screenshots/19/06.png)

📸 **Zabbix Agent 2 Running on DC-01**

![Zabbix Agent 2 Running on WS-01](/screenshots/19/07.png)

📸 **Zabbix Agent 2 Running on DC-01**

![Zabbix Agent 2 Running on WS-02](/screenshots/19/08.png)

---

## 6. Validate Connectivity from MON-01

Install the Zabbix diagnostic tool on **MON-01**:

```bash
apt install zabbix-get -y
```

Test connectivity against each host:

```bash
zabbix_get -s 10.10.10.10 -p 10050 -k agent.ping
zabbix_get -s 10.10.10.101 -p 10050 -k agent.ping
zabbix_get -s 10.10.10.102 -p 10050 -k agent.ping
```

Each command should return:

```
1
```


📸 **Connectivity test from MON-01**

![Connectivity test from MON-01](/screenshots/19/09.png)
![Connectivity test from MON-01](/screenshots/19/10.png)
![Connectivity test from MON-01](/screenshots/19/11.png)

---

## ✅ Outcome

After completing this section:

- A dedicated security group **GG-Zabbix-WS** controls which hosts receive the monitoring firewall rule.
- A GPO deploys the inbound TCP 10050 firewall rule to all monitored hosts.
- Zabbix Agent 2 is installed and running on DC-01, WS-01, and WS-02.
- MON-01 has confirmed connectivity to all three agents.
- The environment is ready for host registration in the Zabbix web interface.
