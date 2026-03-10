# 21 – Grafana Dashboards

---

## 🎯 Objective

Deploy Grafana as a visualization layer on top of Zabbix to provide a modern and flexible dashboarding experience for the lab infrastructure.

This section covers:

- Installing Grafana OSS on MON-01
- Installing and enabling the Zabbix data source plugin
- Connecting Grafana to the Zabbix backend
- Importing a pre-built Windows monitoring dashboard
- Validating metric visualization for all registered hosts

---

## 🧠 Architecture Overview

Grafana is deployed alongside Zabbix on MON-01, adding a dedicated visualization layer on top of the existing monitoring stack:

```
Zabbix (data collection + alerting)
        ↓
Grafana (visualization layer)
        ↓
Browser (dashboards)
```

This architecture is common in real enterprise environments where Grafana serves as a unified frontend for one or more monitoring backends such as Zabbix, Prometheus, or InfluxDB.

---

## 1. Install Grafana on MON-01

Grafana OSS was installed directly on MON-01 alongside Zabbix. The official Grafana APT repository was added manually since Grafana is not included in Debian's default repositories.

### 1.1 Install Dependencies

```bash
sudo apt-get install -y apt-transport-https wget gnupg
```

![Command](/screenshots/21/01.png)

### 1.2 Add Grafana GPG Key and Repository

```bash
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/grafana.asc https://apt.grafana.com/gpg-full.key
sudo chmod 644 /etc/apt/keyrings/grafana.asc
echo "deb [signed-by=/etc/apt/keyrings/grafana.asc] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
```

![Commands](/screenshots/21/02.png)
![Commands](/screenshots/21/03.png)

### 1.3 Install Grafana

```bash
sudo apt-get update
sudo apt-get install grafana
```

![Commands](/screenshots/21/04.png)

### 1.4 Start and Enable the Service

```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
```

![Commands](/screenshots/21/05.png)

---

## 2. Access Grafana Web Interface

Grafana was accessed from a browser using the MON-01 IP address:

```
http://10.10.10.20:3000
```

Default credentials used for the initial login:

| Field | Value |
|-------|-------|
| Username | admin |
| Password | admin |

The password was changed immediately after the first login.

📸 **Grafana home dashboard after first login**

![Grafana home dashboard](/screenshots/21/07.png)

---

## 3. Install the Zabbix Data Source Plugin

Grafana does not include a Zabbix connector by default. The official community plugin **alexanderzobnin-zabbix-app** was installed using the Grafana CLI.

### 3.1 Install the Plugin

```bash
sudo grafana-cli plugins install alexanderzobnin-zabbix-app
sudo systemctl restart grafana-server
```

📸 **Zabbix plugin installation**

![Zabbix plugin installation](/screenshots/21/08.png)

### 3.2 Enable the Plugin in the UI

After restarting the service, the plugin was enabled through the Grafana web interface:

1. Navigate to **Administration → Plugins and data → Plugins**
2. Search for **Zabbix**
3. Click on the plugin → click **Enable**

📸 **Zabbix plugin enabled in Grafana**

![Zabbix plugin enabled](/screenshots/21/09.png)

---

## 4. Configure Zabbix as a Data Source

The Zabbix backend was connected to Grafana by adding it as a data source.

Navigate to:

```
Connections → Data sources → Add new data source
```

Search for and select **Zabbix**, then configure:

| Field | Value |
|-------|-------|
| Name | Zabbix |
| URL | http://localhost/zabbix/api_jsonrpc.php |
| Username | Admin |
| Password | (Zabbix admin password) |

Click **Save & Test**.

📸 **Zabbix data source – Save & Test confirmation**

![Zabbix data source confirmation](/screenshots/21/11.png)

---

## 5. Import Windows Monitoring Dashboard

Rather than building a dashboard from scratch, a community dashboard was imported from [https://grafana.com/grafana/dashboards](https://grafana.com/grafana/dashboards/).

### Dashboard Selection

The Zabbix Windows dashboard was selected because it is specifically designed for Windows host monitoring, providing out-of-the-box visibility into CPU, memory, disk, and network metrics for all registered hosts.

The correct dashboard for this lab is:

| Field | Value |
|-------|-------|
| Dashboard Name | Zabbix Windows |
| Dashboard ID | 24090 |
| Purpose | Windows host metrics (CPU, memory, disk, network) |
| Data Source | Zabbix |

### Import Steps

1. Navigate to **Dashboards → New → Import**
2. Enter dashboard ID: `24090`
3. Click **Load**
4. Set the data source to **Zabbix**
5. Click **Import**

📸 **Dashboard import screen**

![Dashboard import](/screenshots/21/12.png)

---

## 6. Validation

After importing the dashboard, metric visualization was validated for all active Windows hosts.

The dashboard displayed real-time metrics including:

| Metric | Hosts Validated |
|--------|----------------|
| CPU utilization | DC-01, WS-01 |
| Memory usage | DC-01, WS-01 |
| Disk usage | DC-01, WS-01 |
| Network activity | DC-01, WS-01 |
| System uptime | DC-01, WS-01 |

> ⚠️ Note: WS-02 was powered off at the time of validation due to host resource constraints (RAM), which prevent running more than two Windows VMs simultaneously alongside MON-01. Once WS-02 is powered on, metrics will appear automatically without additional configuration.

📸 **Grafana – Zabbix Windows dashboard showing WS-01 metrics**

![Grafana Zabbix Windows dashboard](/screenshots/21/14.png)

---

## ✅ Outcome

After completing this section:

- Grafana OSS is installed and running on MON-01.
- The **alexanderzobnin-zabbix-app** plugin is installed and enabled.
- Grafana is connected to the Zabbix backend.
- The **Zabbix Windows** dashboard (ID 24090) is imported and displaying metrics.
- Infrastructure health is visualized in real time through a modern dashboard interface.
