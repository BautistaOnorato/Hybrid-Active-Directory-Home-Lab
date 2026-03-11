# 20 – Host Monitoring Configuration

---

## 🎯 Objective

Register all Windows hosts in the Zabbix web interface and assign monitoring templates to enable centralized metric collection across the lab infrastructure.

This section covers:

- Creating a host group to organize lab machines
- Registering DC-01, WS-01, and WS-02 in Zabbix
- Assigning the Windows monitoring template to each host
- Using DNS names instead of static IPs for workstation interfaces
- Validating metric collection from monitored hosts

---

## 🧠 Design Decision – DNS Names for Workstation Interfaces

Since WS-01 and WS-02 obtain their IP addresses dynamically via DHCP, using static IPs in Zabbix would cause connectivity failures whenever the lease changes.

To avoid this, the Zabbix agent interface for workstations was configured using **DNS names** instead of IPs:

```
WS-01.bocorp.local
WS-02.bocorp.local
```

MON-01 uses DC-01 (10.10.10.10) as its DNS server, which means it can resolve all bocorp.local hostnames correctly.

This approach ensures:

- Zabbix always resolves the current IP at connection time
- No manual reconfiguration is needed if a DHCP lease changes
- The design remains clean without requiring static IPs or DHCP reservations on the workstations

DC-01 was registered using its static IP (10.10.10.10) since its address never changes.

---

## 1. Verify DNS Resolution from MON-01

Before registering the hosts, DNS resolution was confirmed from MON-01:

```bash
nslookup WS-01.bocorp.local
nslookup WS-02.bocorp.local
```

![nslookup](/screenshots/20/01.png)

---

## 2. Create Host Group

A dedicated host group was created to organize all lab machines under a single logical container.

Navigate to:

```
Data Collection → Host Groups
```

Click **Create host group**.

| Field | Value |
|-------|-------|
| Group name | Bocorp |

Click **Add**.

📸 **Host group created**

![Host group created](/screenshots/20/02.png)

---

## 3. Register Hosts in Zabbix

Each host was registered individually through the Zabbix web interface.

Navigate to:

```
Data Collection → Hosts → Create host
```

---

### 3.1 DC-01

#### Tab: Host

| Field | Value |
|-------|-------|
| Host name | DC-01 |
| Host groups | Bocorp Lab |
| Interfaces → Type | Agent |
| Interfaces → Connect to | IP |
| Interfaces → IP | 10.10.10.10 |
| Interfaces → Port | 10050 |

#### Tab: Templates

Click **Select** → search for:

```
Windows by Zabbix agent
```

Select the template → click **Select**.

Click **Add** to save the host.

📸 **DC-01 settings**

![DC-01 settings](/screenshots/20/03.png)

---

### 3.2 WS-01

#### Tab: Host

| Field | Value |
|-------|-------|
| Host name | WS-01 |
| Host groups | Bocorp Lab |
| Interfaces → Type | Agent |
| Interfaces → Connect to | DNS |
| Interfaces → DNS name | WS-01.bocorp.local |
| Interfaces → Port | 10050 |

#### Tab: Templates

```
Windows by Zabbix agent
```

Click **Add** to save.

📸 **WS-01 settings**

![WS-01 settings](/screenshots/20/04.png)

---

### 3.3 WS-02

#### Tab: Host

| Field | Value |
|-------|-------|
| Host name | WS-02 |
| Host groups | Bocorp Lab |
| Interfaces → Type | Agent |
| Interfaces → Connect to | DNS |
| Interfaces → DNS name | WS-02.bocorp.local |
| Interfaces → Port | 10050 |

#### Tab: Templates

```
Windows by Zabbix agent
```

Click **Add** to save.

📸 **WS-02 settings**

![WS-02 settings](/screenshots/20/05.png)

---

## 4. Verify Host Availability

After registering all hosts, Zabbix initiates communication with each agent. Allow a few minutes for the status to update.

Navigate to:

```
Data Collection → Hosts
```

Confirm each host shows:

| Host | Interface | Status | Availability |
|------|-----------|--------|-------------|
| DC-01 | dc-01.bocorp.local:10050 | Enabled | 🟢 ZBX |
| WS-01 | WS-01.bocorp.local:10050 | Enabled | 🟢 ZBX |
| WS-02 | WS-02.bocorp.local:10050 | Enabled | 🟢 ZBX |
| Zabbix server | 127.0.0.1:10050 | Enabled | 🟢 ZBX |

> ⚠️ Note: WS-02 appears with a red ZBX availability indicator. This is expected behavior. The virtual machine was powered off at the time of documentation due to host resource constraints (RAM), which prevent running more than two Windows VMs simultaneously alongside MON-01. Once WS-02 is powered on, the agent will reconnect automatically and the availability indicator will return to green within a few minutes, without requiring any additional configuration.

📸 **Hosts overview showing all agents connected**

![Hosts overview](/screenshots/20/06.png)

---

## 5. Validate Metric Collection

To confirm that data is being collected correctly, the **Latest Data** view was checked for each active host.

Navigate to:

```
Monitoring → Latest data
```

Filter by host (e.g., DC-01) and click **Apply**.

Metrics arriving in real time confirmed:

| Metric | Example Value |
|--------|--------------|
| CPU utilization | 6.85 % |
| Cache bytes | 52.51 MB |
| Free swap space | 834.91 MB |
| Disk read rate | 18.69 r/s |
| Context switches per second | 460.93 |

📸 **Latest data view for DC-01**

![Latest data DC-01](/screenshots/20/07.png)

---

## ✅ Outcome

After completing this section:

- A **Bocorp** host group organizes all monitored machines.
- DC-01, WS-01, and WS-02 are registered in Zabbix with the **Windows by Zabbix agent** template.
- Workstations use DNS names to handle dynamic IP assignment gracefully.
- All active hosts show green availability status.
- Metrics are being collected and updated in real time.
