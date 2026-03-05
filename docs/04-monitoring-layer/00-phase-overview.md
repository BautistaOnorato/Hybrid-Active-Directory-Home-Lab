# Phase 4 – Monitoring Layer

---

## 🎯 Objective

Implement a centralized monitoring and observability layer for the entire lab infrastructure.

This phase focuses on deploying a dedicated monitoring server, collecting telemetry from Windows servers and clients, visualizing system health, and configuring alerting mechanisms for operational visibility.

The goal is to simulate a real-world enterprise monitoring stack where infrastructure health, performance metrics, and security-related events can be observed and acted upon in real time.

By introducing monitoring capabilities, the lab transitions from a deployed infrastructure into an **actively monitored production-like environment**, enabling proactive detection of failures, performance issues, and abnormal system behavior.

---

## 📦 Scope

This phase includes:

- Deploying a dedicated Linux monitoring server (MON-01)
- Installing and configuring the Zabbix monitoring platform
- Deploying Zabbix agents on Windows servers and workstations
- Integrating Windows hosts with the monitoring server
- Collecting system metrics, service status, and performance data
- Visualizing infrastructure health using Grafana dashboards
- Configuring alerting mechanisms for system failures and anomalies
- Validating monitoring coverage across the environment

---

## 🏗 Infrastructure Components

### Monitoring Server

- **MON-01 (Linux)**
- Zabbix Server
- Zabbix Web Interface
- Zabbix Database
- Zabbix Agent

The monitoring server acts as the **central telemetry collector**, aggregating metrics and events from all monitored systems.

---

### Monitoring Platform

**Zabbix**

Responsible for:

- Infrastructure monitoring
- Agent-based metric collection
- Service availability checks
- Alert generation
- Historical metric storage
- Trigger-based anomaly detection

Zabbix will monitor:

- Domain Controller (DC-01)
- Windows workstations (WS-01, WS-02)
- Critical services and system resources

---

### Visualization Layer

**Grafana**

Grafana provides a modern visualization layer for monitoring data by:

- Connecting to the Zabbix data source
- Creating dashboards for system performance
- Displaying infrastructure health indicators
- Enabling easier operational visibility

Dashboards will include metrics such as:

- CPU utilization
- Memory consumption
- Disk usage
- Network activity
- Service availability

---

### Alerting & Operational Visibility

Alerting mechanisms will be configured to detect and notify about:

- Host availability failures
- High CPU or memory usage
- Disk capacity thresholds
- Critical service failures
- Agent communication issues

This allows the lab to simulate **real-world operations monitoring**, where administrators are notified about infrastructure problems before they impact users.

---

## 🔐 Architectural Design Principles

The monitoring implementation follows modern infrastructure observability principles:

- **Centralized Monitoring**  
  All systems report metrics to a single monitoring platform.

- **Agent-Based Telemetry Collection**  
  Hosts provide detailed performance and service data through installed agents.

- **Separation of Monitoring Infrastructure**  
  Monitoring services run on a dedicated Linux server independent of the Windows domain.

- **Visualization-Driven Operations**  
  Dashboards provide quick operational insight into infrastructure health.

- **Proactive Alerting**  
  Threshold-based triggers detect issues before they escalate into outages.

---

## 📂 Files Included

- `17-monitoring-server-deployment.md` – Linux server deployment for monitoring
- `18-zabbix-installation.md` – Zabbix server installation and initial configuration
- `19-zabbix-agent-deployment.md` – Zabbix agent installation on Windows hosts
- `20-host-monitoring-configuration.md` – Monitoring configuration for domain systems
- `21-grafana-dashboards.md` – Grafana integration and dashboard creation
- `22-alerting-configuration.md` – Monitoring triggers and alerting setup

---

## ✅ Outcome

By completing this phase:

- **Centralized Infrastructure Monitoring Implemented:**  
  All servers and workstations are monitored from a single platform.

- **Real-Time Visibility Achieved:**  
  Administrators gain immediate insight into system health and performance.

- **Operational Alerting Enabled:**  
  Monitoring triggers generate alerts for failures and abnormal conditions.

- **Historical Metrics Collected:**  
  System performance data is stored for analysis and troubleshooting.

- **Enterprise Monitoring Architecture Simulated:**  
  The lab environment now includes a dedicated observability stack comparable to real production environments.
  