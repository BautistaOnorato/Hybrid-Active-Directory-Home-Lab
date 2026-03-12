# 18 – Zabbix Installation

---

## 🎯 Objective

Install and configure Zabbix on MON-01 to establish the central monitoring platform for the lab infrastructure.

This section covers:

- Adding the official Zabbix 7.0 LTS repository to MON-01
- Installing all required Zabbix components
- Deploying and configuring MariaDB as the backend database
- Importing the Zabbix database schema
- Configuring the Zabbix Server with the database credentials
- Completing the web-based setup wizard
- Validating the installation and changing the default admin password

---

## 🏗 Architecture Overview

The following components are deployed on MON-01:

```
MON-01 (Debian 13)
├── Zabbix Server     → processes monitoring data and evaluates triggers
├── Zabbix Frontend   → web UI served by Apache for host and alert management
├── MariaDB           → stores all metrics, configuration, and event history
└── Zabbix Agent 2    → monitors MON-01 itself
```

### Component Summary

| Component | Package | Purpose |
|-----------|---------|---------|
| Zabbix Server | `zabbix-server-mysql` | Core monitoring engine — collects agent data and generates alerts |
| Zabbix Frontend | `zabbix-frontend-php` | Web UI for host management, dashboards, and alerting |
| Apache Config | `zabbix-apache-conf` | Pre-configures Apache to serve the Zabbix frontend |
| SQL Scripts | `zabbix-sql-scripts` | Database schema required to initialize the Zabbix database |
| Zabbix Agent 2 | `zabbix-agent2` | Next-generation agent installed on MON-01 for self-monitoring |

> Zabbix Agent 2 is the modern replacement for the original Zabbix agent. It offers improved performance, native plugin support, better concurrency handling, and is the recommended agent for all new deployments.

---

## 1️⃣ Add the Zabbix Repository

Zabbix is not available in Debian's default repositories. The official Zabbix 7.0 LTS repository was added manually:

```bash
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian13_all.deb
dpkg -i zabbix-release_latest_7.0+debian13_all.deb
apt update
```

![Add Zabbix repository](/screenshots/18/01.png)

---

## 2️⃣ Install Zabbix Components

Install all required components in a single command:

```bash
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent2 -y
```

![Install Zabbix components](/screenshots/18/02.png)

---

## 3️⃣ Install and Configure MariaDB

### 3.1 Install MariaDB

```bash
apt install mariadb-server -y
systemctl start mariadb
systemctl enable mariadb
```

![Install MariaDB](/screenshots/18/03.png)

![Enable MariaDB service](/screenshots/18/04.png)

---

### 3.2 Create the Zabbix Database

Connect to MariaDB using `sudo` to leverage Debian's default unix_socket authentication:

```bash
sudo mysql -u root
```

Create the database and user:

```sql
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'Password123!';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
EXIT;
```

![Create Zabbix database and user](/screenshots/18/05.png)

> `log_bin_trust_function_creators = 1` is required temporarily to allow the Zabbix schema import to create stored functions. It will be disabled after the import completes.

---

## 4️⃣ Import the Zabbix Database Schema

Import the Zabbix schema, tables, and initial configuration data into the database:

```bash
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql --default-character-set=utf8mb4 -u zabbix -p zabbix
```

![Import Zabbix schema](/screenshots/18/06.png)

After the import completes, disable the temporary setting:

```bash
sudo mysql -u root
```

```sql
SET GLOBAL log_bin_trust_function_creators = 0;
EXIT;
```

![Disable log_bin_trust_function_creators](/screenshots/18/07.png)

---

## 5️⃣ Configure the Zabbix Server

Edit the Zabbix Server configuration file to set the database password:

```bash
sudo nano /etc/zabbix/zabbix_server.conf
```

Locate the `DBPassword` line, uncomment it, and set the value:

```
DBPassword=Password123!
```

![Configure DBPassword in zabbix_server.conf](/screenshots/18/08.png)

---

## 6️⃣ Start and Enable Services

Start and enable all required services:

```bash
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2
```

![Start and enable Zabbix services](/screenshots/18/09.png)

Verify all three services are running:

```bash
systemctl status zabbix-server
systemctl status zabbix-agent
systemctl status apache2
```

![Verify service status](/screenshots/18/10.png)

---

## 7️⃣ Complete the Web Setup Wizard

Access the Zabbix setup wizard from a browser:

```
http://10.10.10.20/zabbix
```

![Zabbix web setup wizard](/screenshots/18/11.png)

Configure the following settings during the wizard:

| Step | Setting | Value |
|------|---------|-------|
| Check prerequisites | All checks | Must pass |
| DB connection | Database type | MySQL |
| DB connection | Host | localhost |
| DB connection | Database name | zabbix |
| DB connection | User | zabbix |
| DB connection | Password | (configured password) |
| Zabbix server details | Host | localhost |
| Zabbix server details | Port | 10051 |
| Zabbix server details | Name | Bocorp-MON-01 |
| Time zone | Time zone | America/Argentina/Buenos_Aires |

📸 **Prerequisites check**

![Check of pre-requisites](/screenshots/18/12.png)

📸 **Database connection configuration**

![Configure DB connection](/screenshots/18/13.png)

📸 **Zabbix server settings**

![Settings](/screenshots/18/14.png)

📸 **Pre-installation summary**

![Pre-installation summary](/screenshots/18/15.png)

📸 **Installation complete**

![Successful installation](/screenshots/18/16.png)

---

## 🔎 Validation

### First Login and Password Change

Log in to the Zabbix web interface using the default credentials:

| Field | Value |
|-------|-------|
| Username | `Admin` |
| Password | `zabbix` |

Immediately change the default password after the first login:

```
User settings (top-right menu) → Profile → Change password
```

📸 **Zabbix dashboard after first login**

![Zabbix Dashboard – Global View](/screenshots/18/17.png)

### Verify Service Health

Confirm the Zabbix Server is communicating with the local agent by navigating to:

```
Monitoring → Problems
```

No connectivity problems for the Zabbix server host should be present.

---

## ✅ Outcome

After completing this section:

- Zabbix Server 7.0 LTS is installed and operational on MON-01.
- MariaDB is configured and serving as the Zabbix backend database.
- The Zabbix web frontend is accessible at `http://10.10.10.20/zabbix`.
- MON-01 is being monitored by its local Zabbix Agent 2 instance.
- The default admin password has been changed.
- The environment is ready for agent deployment on Windows hosts.