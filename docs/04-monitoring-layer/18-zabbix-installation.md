# 18 – Zabbix Installation

---

## 🎯 Objective

Install and configure Zabbix on **MON-01** to establish the central monitoring platform for the lab infrastructure.

This section covers:

- Adding the official Zabbix repository
- Installing all required Zabbix components
- Deploying and configuring MariaDB as the backend database
- Importing the Zabbix database schema
- Completing the web-based setup wizard
- Validating the installation

---

## 🏗 Architecture Overview

The following components are deployed on MON-01:

```
MON-01 (Debian 13)
├── Zabbix Server     → processes monitoring data and triggers alerts
├── Zabbix Frontend   → web UI to manage hosts, dashboards, and alerts
├── MariaDB           → stores all metrics, configuration, and history
└── Zabbix Agent      → monitors MON-01 itself
```

**Stack:**

- Zabbix 7.0 (LTS)
- Apache (web server)
- MariaDB (database)

---

## 1. Add the Zabbix Repository

Zabbix is not available in Debian's default repositories. The official Zabbix repository was added manually.

```bash
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian13_all.deb
dpkg -i zabbix-release_latest_7.0+debian13_all.deb
apt update
```

![Commands](/screenshots/18/01.png)

---

## 2. Install Zabbix Components

All required components were installed in a single command:

```bash
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent2 -y
```

**What each package does:**

| Package | Purpose |
|---------|---------|
| `zabbix-server-mysql` | Core monitoring engine. Collects data from agents, evaluates triggers, and generates alerts |
| `zabbix-frontend-php` | Web-based UI to manage hosts, dashboards, alerts, and configuration |
| `zabbix-apache-conf` | Pre-configures Apache to serve the Zabbix frontend automatically |
| `zabbix-sql-scripts` | Database schema files required to initialize the Zabbix database |
| `zabbix-agent2` | Next-generation agent installed locally on MON-01 to allow the Zabbix server to monitor itself |

**Why Zabbix Agent 2?**
Agent 2 is the modern replacement for the original Zabbix agent. It offers improved performance, native support for more plugins, better concurrency handling, and is the recommended agent for new deployments.

![Commands](/screenshots/18/02.png)

---

## 3. Install and Configure MariaDB

### 3.1 Install MariaDB

```bash
apt install mariadb-server -y
systemctl start mariadb
systemctl enable mariadb
```

![Commands](/screenshots/18/03.png)
![Commands](/screenshots/18/04.png)

### 3.2 Create the Zabbix Database

Connected to MariaDB using sudo due to Debian's default unix_socket authentication:

```bash
sudo mysql -u root
```

Created the database and user:

```sql
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'Password123!';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
EXIT;
```

![Commands](/screenshots/18/05.png)

---

## 4. Import the Zabbix Database Schema

```bash
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql --default-character-set=utf8mb4 -u zabbix -p zabbix
```

This imports all required tables, default configuration, and initial data into the Zabbix database.

![Commands](/screenshots/18/06.png)

After the import completed, the temporary setting was disabled:

```bash
sudo mysql -u root
```

```sql
SET GLOBAL log_bin_trust_function_creators = 0;
EXIT;
```

![Commands](/screenshots/18/07.png)

---

## 5. Configure Zabbix Server

The Zabbix server configuration file was updated to include the database password:

```bash
sudo nano /etc/zabbix/zabbix_server.conf
```

The `DBPassword` line was uncommented and updated:

```
DBPassword=Password123!
```

![Commands](/screenshots/18/08.png)

---

## 6. Start and Enable Services

```bash
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2
```

![Commands](/screenshots/18/09.png)

Service status was verified:

```bash
systemctl status zabbix-server
systemctl status zabbix-agent
systemctl status apache2
```

All three services confirmed as **active (running)**.

![Commands](/screenshots/18/10.png)

---

## 7. Web Setup Wizard

Accessed the setup wizard from a browser:

```
http://10.10.10.20/zabbix
```

![Commands](/screenshots/18/11.png)

Configuration applied during the wizard:

| Step | Setting | Value |
|------|---------|-------|
| DB Connection | Database type | MySQL |
| DB Connection | Host | localhost |
| DB Connection | Database name | zabbix |
| DB Connection | User | zabbix |
| DB Connection | Password | (configured) |
| Server Details | Host | localhost |
| Server Details | Port | 10051 |
| Server Details | Name | Bocorp-MON-01 |
| Time Zone | Time Zone | America/Argentina/Buenos_Aires |

📸 **Check of pre-requisites**

![Check of pre-requisites](/screenshots/18/12.png)

📸 **Configure DB connection**

![Configure DB connection](/screenshots/18/13.png)

📸 **Settings**

![Settings](/screenshots/18/14.png)

📸 **Pre-installation summary**

![Pre-installation summary](/screenshots/18/15.png)

📸 **Successful installation**

![Successful installation](/screenshots/18/16.png)

---

## 8. First Login and Password Change

Default credentials were used for the initial login:

```
Username: Admin
Password: zabbix
```

The default password was immediately changed after login:

```
User settings → Profile → Change password
```

📸 **Zabbix Dashboard – Global View**

![Zabbix Dashboard](/screenshots/18/17.png)

---

## ✅ Outcome

After completing this section:

- Zabbix Server 7.0 is fully installed and operational on MON-01.
- MariaDB is configured and serving as the Zabbix backend database.
- The Zabbix web frontend is accessible via browser.
- MON-01 is being monitored by its local Zabbix agent.
- The default admin password has been changed.
- The environment is ready for agent deployment on Windows hosts.
