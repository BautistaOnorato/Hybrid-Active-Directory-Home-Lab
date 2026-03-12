# Phase 4 – Monitoring Layer

---

## 🎯 Objective

Implement a centralized monitoring and observability layer for the entire lab infrastructure.

This phase focuses on deploying a dedicated monitoring server, collecting telemetry from Windows servers and clients, visualizing infrastructure health through dashboards, and configuring an alerting pipeline for operational visibility.

The goal is to transition the lab from a deployed infrastructure into an actively monitored environment where failures, performance degradation, and abnormal behavior are detected and communicated in real time.

---

## 📦 Scope

This phase includes:

- Deploying a dedicated Debian Linux monitoring server (MON-01)
- Installing and configuring the Zabbix monitoring platform
- Deploying Zabbix Agent 2 on all Windows hosts via GPO
- Registering DC-01, WS-01, and WS-02 in the Zabbix web interface
- Collecting system metrics, service status, and performance data from all monitored hosts
- Deploying Grafana and connecting it to the Zabbix backend
- Building infrastructure health dashboards in Grafana
- Configuring an alerting pipeline using a custom Webhook Media Type and Microsoft Graph API
- Validating alert delivery for both problem and recovery events

---

## 🏗 Infrastructure Components

### Monitoring Server

- **MON-01** – Debian 13 (Trixie), static IP `10.10.10.20`
- Zabbix Server 7.0 LTS
- Zabbix Frontend (Apache)
- MariaDB (Zabbix backend database)
- Zabbix Agent 2 (self-monitoring)
- Grafana OSS

### Monitored Hosts

| Host | Role | IP |
|------|------|----|
| DC-01 | Domain Controller | 10.10.10.10 (static) |
| WS-01 | Workstation | DHCP (resolved via DNS) |
| WS-02 | Workstation | DHCP (resolved via DNS) |

### Alerting Pipeline

- Azure App Registration (`Zabbix-MailSender`) for OAuth 2.0 authentication
- Microsoft Graph API (`/sendMail`) for email delivery
- Zabbix Webhook Media Type with custom JavaScript
- Shared mailbox (`zabbix-alerts@bocorp.online`) for centralized alert reception

---

## 🔐 Architectural Design Principles

This phase follows modern infrastructure observability principles:

- The monitoring stack runs on a dedicated Linux server independent of the Windows domain, ensuring monitoring remains operational even if the domain is degraded
- Zabbix Agent 2 is deployed via GPO to maintain consistency with the existing endpoint management model
- Workstations are registered in Zabbix using DNS names instead of static IPs to handle dynamic DHCP lease changes gracefully
- Grafana is deployed as a dedicated visualization layer on top of Zabbix, reflecting common enterprise monitoring architectures where multiple backends feed a single dashboard platform
- Alert delivery uses OAuth 2.0 with Microsoft Graph API instead of legacy SMTP authentication, which has been deprecated in modern Exchange Online tenants

---

## 📂 Files Included

- [`17-monitoring-server-deployment.md`](/docs/04-monitoring-layer/17-monitoring-server-deployment.md) – Debian 13 installation and MON-01 network configuration
- [`18-zabbix-installation.md`](/docs/04-monitoring-layer/18-zabbix-installation.md) – Zabbix Server, frontend, and MariaDB installation and configuration
- [`19-zabbix-agent-deployment.md`](/docs/04-monitoring-layer/19-zabbix-agent-deployment.md) – Zabbix Agent 2 deployment via GPO on all Windows hosts
- [`20-host-monitoring-configuration.md`](/docs/04-monitoring-layer/20-host-monitoring-configuration.md) – Host registration and monitoring template assignment in Zabbix
- [`21-grafana-dashboards.md`](/docs/04-monitoring-layer/21-grafana-dashboards.md) – Grafana installation, Zabbix plugin configuration, and dashboard import
- [`22-alerting-configuration.md`](/docs/04-monitoring-layer/22-alerting-configuration.md) – Webhook Media Type, Trigger Action, and end-to-end alert validation

---

## ✅ Outcome

By completing this phase:

- **Centralized Infrastructure Monitoring Implemented:**
  All Windows servers and workstations report metrics to a single Zabbix platform running on a dedicated Linux server.

- **Real-Time Visibility Achieved:**
  Grafana dashboards provide live visibility into CPU utilization, memory consumption, disk usage, network activity, and system uptime across all monitored hosts.

- **Operational Alerting Enabled:**
  Zabbix triggers detect failures and abnormal conditions and deliver problem and recovery notifications to a shared mailbox via Microsoft Graph API.

- **Historical Metrics Collected:**
  System performance data is stored in MariaDB and available for trend analysis and troubleshooting.

- **Enterprise Monitoring Architecture Simulated:**
  The lab environment now includes a dedicated observability stack with agent-based telemetry collection, a modern visualization layer, and a secure OAuth 2.0 alerting pipeline.