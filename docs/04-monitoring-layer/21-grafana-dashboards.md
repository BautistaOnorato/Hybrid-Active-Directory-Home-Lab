# 21 – Grafana Dashboards

---

## 🎯 Objective

Deploy Grafana on MON-01 as a visualization layer on top of Zabbix to provide a modern dashboarding experience for the lab infrastructure.

This section covers:

- Installing Grafana OSS on MON-01
- Installing and enabling the Zabbix data source plugin
- Connecting Grafana to the Zabbix backend
- Importing a pre-built Windows monitoring dashboard
- Validating metric visualization for all registered hosts

---

## 🏗 Architecture Overview

Grafana is deployed alongside Zabbix on MON-01, adding a dedicated visualization layer on top of the existing monitoring stack:

```
Zabbix (data collection + alerting)
        ↓
alexanderzobnin-zabbix-app (Grafana plugin)
        ↓
Grafana OSS (visualization layer)
        ↓
Browser (dashboards)
```

This architecture is common in enterprise environments where Grafana serves as a unified frontend for one or more monitoring backends such as Zabbix, Prometheus, or InfluxDB.

### Dashboard

| Field | Value |
|-------|-------|
| Dashboard Name | Zabbix Windows |
| Dashboard ID | `24090` |
| Purpose | Windows host metrics — CPU, memory, disk, network, uptime |
| Data Source | Zabbix |

---

## 1️⃣ Install Grafana OSS

Grafana is not included in Debian's default repositories. The official Grafana APT repository was added manually.

### 1.1 Install Dependencies

```bash
sudo apt-get install -y apt-transport-https wget gnupg
```

![Install dependencies](/screenshots/21/01.png)

---

### 1.2 Add the Grafana GPG Key and Repository

```bash
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/grafana.asc https://apt.grafana.com/gpg-full.key
sudo chmod 644 /etc/apt/keyrings/grafana.asc
echo "deb [signed-by=/etc/apt/keyrings/grafana.asc] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
```

![Add Grafana GPG key](/screenshots/21/02.png)

![Add Grafana repository](/screenshots/21/03.png)

---

### 1.3 Install Grafana

```bash
sudo apt-get update
sudo apt-get install grafana -y
```

![Install Grafana](/screenshots/21/04.png)

---

### 1.4 Start and Enable the Service

```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
```

![Grafana service running](/screenshots/21/05.png)

---

## 2️⃣ Access the Grafana Web Interface

Access Grafana from a browser using the MON-01 IP address:

```
http://10.10.10.20:3000
```

Log in using the default credentials:

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin` |

Change the password immediately after the first login when prompted.

📸 **Grafana home dashboard after first login**

![Grafana home dashboard](/screenshots/21/06.png)

---

## 3️⃣ Install the Zabbix Data Source Plugin

Grafana does not include a Zabbix connector by default. The official community plugin `alexanderzobnin-zabbix-app` was installed using the Grafana CLI.

### 3.1 Install the Plugin

```bash
sudo grafana-cli plugins install alexanderzobnin-zabbix-app
sudo systemctl restart grafana-server
```

📸 **Zabbix plugin installation**

![Zabbix plugin installation](/screenshots/21/07.png)

---

### 3.2 Enable the Plugin

After restarting the service, enable the plugin through the Grafana web interface:

```
Administration → Plugins and data → Plugins → Search: Zabbix → Enable
```

📸 **Zabbix plugin enabled in Grafana**

![Zabbix plugin enabled](/screenshots/21/08.png)

---

## 4️⃣ Configure Zabbix as a Data Source

Navigate to:

```
Connections → Data sources → Add new data source → Zabbix
```

Configure the data source with the following settings:

| Field | Value |
|-------|-------|
| Name | `Zabbix` |
| URL | `http://localhost/zabbix/api_jsonrpc.php` |
| Username | `Admin` |
| Password | (Zabbix admin password) |

Click **Save & Test** and confirm the connection is successful.

📸 **Zabbix data source connection successful**

![Zabbix data source confirmation](/screenshots/21/09.png)

---

## 5️⃣ Import the Windows Monitoring Dashboard

A community dashboard was imported from [grafana.com/grafana/dashboards](https://grafana.com/grafana/dashboards) instead of building one from scratch. The Zabbix Windows dashboard (ID `24090`) provides out-of-the-box visibility into CPU, memory, disk, and network metrics for all registered Windows hosts.

Navigate to:

```
Dashboards → New → Import
```

Enter dashboard ID `24090` and click **Load**. Set the data source to **Zabbix** and click **Import**.

📸 **Dashboard import screen**

![Dashboard import](/screenshots/21/10.png)

---

## 🔎 Validation

After importing the dashboard, metric visualization was validated for all active Windows hosts.

The dashboard displayed real-time metrics for DC-01 and WS-01:

| Metric | Hosts Validated |
|--------|----------------|
| CPU utilization | DC-01, WS-01 |
| Memory usage | DC-01, WS-01 |
| Disk usage | DC-01, WS-01 |
| Network activity | DC-01, WS-01 |
| System uptime | DC-01, WS-01 |

> WS-02 was powered off at the time of validation due to host resource constraints. Once WS-02 is powered on, its metrics will appear in the dashboard automatically without any additional configuration.

📸 **Grafana – Zabbix Windows dashboard showing WS-01 metrics**

![Grafana Zabbix Windows dashboard](/screenshots/21/11.png)

---

## ✅ Outcome

After completing this section:

- Grafana OSS is installed and running on MON-01 at `http://10.10.10.20:3000`.
- The `alexanderzobnin-zabbix-app` plugin is installed and enabled.
- Grafana is connected to the Zabbix backend via the JSON-RPC API.
- The `Zabbix Windows` dashboard (ID `24090`) is imported and displaying real-time metrics.
- Infrastructure health is visualized through a modern dashboard interface alongside the native Zabbix frontend.