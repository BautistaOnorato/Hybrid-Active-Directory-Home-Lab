# 20 – Host Monitoring Configuration

---

## 🎯 Objective

Register all Windows hosts in the Zabbix web interface and assign monitoring templates to enable centralized metric collection across the lab infrastructure.

This section covers:

- Verifying DNS resolution of workstation hostnames from MON-01
- Creating a host group to organize all lab machines
- Registering DC-01, WS-01, and WS-02 in Zabbix
- Assigning the Windows monitoring template to each host
- Validating agent connectivity and metric collection

---

## 🏗 Architecture Overview

### Interface Configuration Strategy

DC-01 is registered using its static IP address since it never changes. WS-01 and WS-02 are registered using DNS names instead of static IPs because they obtain addresses dynamically via DHCP.

| Host | Interface Type | Value |
|------|---------------|-------|
| DC-01 | IP | `10.10.10.10` |
| WS-01 | DNS | `WS-01.bocorp.local` |
| WS-02 | DNS | `WS-02.bocorp.local` |

Using DNS names for workstations ensures Zabbix always resolves the current IP at connection time. If a DHCP lease changes, no reconfiguration is needed in Zabbix — the DNS record in DC-01 updates automatically and Zabbix continues collecting metrics without interruption.

MON-01 uses DC-01 (`10.10.10.10`) as its DNS server, which means it can resolve all `bocorp.local` hostnames correctly.

---

## 1️⃣ Verify DNS Resolution from MON-01

Before registering the hosts, confirm that MON-01 can resolve the workstation hostnames:

```bash
nslookup WS-01.bocorp.local
nslookup WS-02.bocorp.local
```

Both queries should return the current DHCP-assigned IP address for each workstation.

![DNS resolution from MON-01](/screenshots/20/01.png)

---

## 2️⃣ Create Host Group

A dedicated host group was created to organize all lab machines under a single logical container, making it easier to apply templates, actions, and maintenance windows across the environment.

Navigate to:

```
Data Collection → Host Groups → Create host group
```

| Field | Value |
|-------|-------|
| Group name | `Bocorp` |

Click **Add**.

📸 **Bocorp host group created**

![Host group created](/screenshots/20/02.png)

---

## 3️⃣ Register Hosts in Zabbix

Each host was registered individually through the Zabbix web interface.

Navigate to:

```
Data Collection → Hosts → Create host
```

---

### 3.1 DC-01

**Tab: Host**

| Field | Value |
|-------|-------|
| Host name | `DC-01` |
| Host groups | `Bocorp` |
| Interface type | Agent |
| Connect to | IP |
| IP address | `10.10.10.10` |
| Port | `10050` |

**Tab: Templates**

Search for and select:

```
Windows by Zabbix agent
```

Click **Add** to save the host.

📸 **DC-01 host configuration**

![DC-01 settings](/screenshots/20/03.png)

---

### 3.2 WS-01

**Tab: Host**

| Field | Value |
|-------|-------|
| Host name | `WS-01` |
| Host groups | `Bocorp` |
| Interface type | Agent |
| Connect to | DNS |
| DNS name | `WS-01.bocorp.local` |
| Port | `10050` |

**Tab: Templates**

Search for and select:

```
Windows by Zabbix agent
```

Click **Add** to save the host.

📸 **WS-01 host configuration**

![WS-01 settings](/screenshots/20/04.png)

---

### 3.3 WS-02

**Tab: Host**

| Field | Value |
|-------|-------|
| Host name | `WS-02` |
| Host groups | `Bocorp` |
| Interface type | Agent |
| Connect to | DNS |
| DNS name | `WS-02.bocorp.local` |
| Port | `10050` |

**Tab: Templates**

Search for and select:

```
Windows by Zabbix agent
```

Click **Add** to save the host.

📸 **WS-02 host configuration**

![WS-02 settings](/screenshots/20/05.png)

---

## 🔎 Validation

### Verify Host Availability

After registering all hosts, allow a few minutes for Zabbix to initiate communication with each agent. Navigate to:

```
Data Collection → Hosts
```

Confirm each host shows a green **ZBX** availability indicator:

| Host | Interface | Status | Availability |
|------|-----------|--------|-------------|
| Zabbix server | 127.0.0.1:10050 | Enabled | 🟢 ZBX |
| DC-01 | 10.10.10.10:10050 | Enabled | 🟢 ZBX |
| WS-01 | WS-01.bocorp.local:10050 | Enabled | 🟢 ZBX |
| WS-02 | WS-02.bocorp.local:10050 | Enabled | 🟢 ZBX |

> WS-02 may show a red ZBX indicator if the virtual machine is powered off. Due to host resource constraints, running more than two Windows VMs simultaneously alongside MON-01 is not always possible. Once WS-02 is powered on, the agent reconnects automatically and the availability indicator returns to green within a few minutes without any additional configuration.

📸 **Hosts overview showing all agents connected**

![Hosts overview](/screenshots/20/06.png)

---

### Verify Metric Collection

Navigate to:

```
Monitoring → Latest data
```

Filter by host (e.g., DC-01) and click **Apply**. Confirm that metrics are arriving in real time.

| Metric | Example Value |
|--------|--------------|
| CPU utilization | 6.85% |
| Cache bytes | 52.51 MB |
| Free swap space | 834.91 MB |
| Disk read rate | 18.69 r/s |
| Context switches per second | 460.93 |

📸 **Latest data view for DC-01**

![Latest data DC-01](/screenshots/20/07.png)

---

## ✅ Outcome

After completing this section:

- The `Bocorp` host group organizes all monitored machines in Zabbix.
- DC-01, WS-01, and WS-02 are registered with the `Windows by Zabbix agent` template.
- DC-01 uses a static IP interface and workstations use DNS name interfaces to handle dynamic IP assignment gracefully.
- All active hosts show a green ZBX availability indicator.
- Metrics are being collected and updated in real time across the environment.
- The environment is ready for Grafana dashboard configuration.