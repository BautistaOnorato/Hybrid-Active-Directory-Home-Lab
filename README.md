# Active Directory Home Lab

This project is a fully documented home lab built from scratch to develop hands-on experience with enterprise IT infrastructure. It was designed with a single goal: to bridge the gap between theoretical knowledge and real-world skills required for a first role in IT Support or Help Desk.

Every phase of this lab was planned, implemented, and documented as if it were a production environment — including design decisions, architecture justification, troubleshooting logs, and validation steps.

---

## 📑 Table of Contents

### Phase 1 – Core Infrastructure
- [00 – Overview](docs/01-core-infrastructure/00-phase-overview.md)
- [01 – Hyper-V Setup](docs/01-core-infrastructure/01-hyperv-setup.md)
- [02 – Domain Controller Setup](docs/01-core-infrastructure/02-domaincontroller-setup.md)
- [03 – Client Setup](docs/01-core-infrastructure/03-client-setup.md)

### Phase 2 – Identity, Network Services & Policy Implementation
- [00 – Overview](docs/02-identity-network_services-policy_implementation/00-phase-overview.md)
- [04 – OU and Identity Setup](docs/02-identity-network_services-policy_implementation/04-ou-and-identity-setup.md)
- [05 – DHCP Configuration](docs/02-identity-network_services-policy_implementation/05-dhcp-configuration.md)
- [06 – GPO Configuration](docs/02-identity-network_services-policy_implementation/06-gpo-configuration.md)
- [07 – File Shares and Drive Mapping](docs/02-identity-network_services-policy_implementation/07-file-shares.md)

### Phase 3 – Hybrid Identity and Cloud Integration
- [00 – Overview](docs/03-hybrid-identity-and-cloud-integration/00-phase-overview.md)
- [08 – Entra Domain Configuration](docs/03-hybrid-identity-and-cloud-integration/08-entra-domain-configuration.md)
- [09 – Entra Connect Configuration](docs/03-hybrid-identity-and-cloud-integration/09-entra-connect-configuration.md)
- [10 – Authentication and Conditional Access](docs/03-hybrid-identity-and-cloud-integration/10-authentication-and-conditional-access.md)
- [11 – Licensing and RBAC](docs/03-hybrid-identity-and-cloud-integration/11-licensing-and-rbac.md)
- [12 – Exchange Online Configuration](docs/03-hybrid-identity-and-cloud-integration/12-exchange-online-configuration.md)
- [13 – Intune and Device Management](docs/03-hybrid-identity-and-cloud-integration/13-intune-and-device-management.md)
- [14 – Intune App Deployment](docs/03-hybrid-identity-and-cloud-integration/14-intune-app-deployment.md)
- [15 – Microsoft 365 Retention and Recovery](docs/03-hybrid-identity-and-cloud-integration/15-microsoft-365-retention-and-recovery.md)
- [16 – Azure Backup](docs/03-hybrid-identity-and-cloud-integration/16-azure-backup.md)

### Phase 4 – Monitoring Layer
- [00 – Overview](docs/04-monitoring-layer/00-phase-overview.md)
- [17 – Monitoring Server Deployment](docs/04-monitoring-layer/17-monitoring-server-deployment.md)
- [18 – Zabbix Installation](docs/04-monitoring-layer/18-zabbix-installation.md)
- [19 – Zabbix Agent Deployment](docs/04-monitoring-layer/19-zabbix-agent-deployment.md)
- [20 – Host Monitoring Configuration](docs/04-monitoring-layer/20-host-monitoring-configuration.md)
- [21 – Grafana Dashboards](docs/04-monitoring-layer/21-grafana-dashboards.md)
- [22 – Alerting Configuration](docs/04-monitoring-layer/22-alerting-configuration.md)

### Extras
- [00 – Overview](docs/extras/00-extras-overview.md)
- [E01 – WireGuard VPN](docs/extras/E01-vpn-wireguard.md)
- [E02 – Action1 Patch Management](docs/extras/E02-action1-patch-management.md)

### Troubleshooting
- [Troubleshooting](docs/troubleshooting/troubleshooting.md)

---

## 🏗 Architecture

The lab simulates a hybrid enterprise environment running entirely on a single Windows 10 Home machine using Hyper-V virtualization.

```
Host Machine (Windows 10 Home)
│
├── Hyper-V
│   ├── BOCORP-SW01 (Internal Virtual Switch + NAT)
│   │   ├── DC-01     → Windows Server 2025  │ 10.10.10.10
│   │   ├── WS-01     → Windows 11 Pro       │ 10.10.10.100-200 (DHCP)
│   │   ├── WS-02     → Windows 11 Pro       │ 10.10.10.100-200 (DHCP)
│   │   ├── MON-01    → Debian 13            │ 10.10.10.20
│   │   └── VPN-01    → Debian 13            │ 10.10.10.30
│   │
│   └── BOCORP-EXTERNAL-SW01 (External Virtual Switch)
│       └── VPN-01 eth1                      │ 192.168.1.39
│
└── Cloud Services
    ├── Microsoft Entra ID  (bocorp.online)
    ├── Microsoft 365       (Exchange Online, SharePoint, OneDrive)
    ├── Microsoft Intune
    └── Azure Backup
```

![Architecture Diagram](/lab-architecture.png)

### Network Summary

| Host | Role | OS | IP Address |
|------|------|----|------------|
| DC-01 | Domain Controller / DNS / DHCP | Windows Server 2025 | 10.10.10.10 (Static) |
| WS-01 | Workstation | Windows 11 Pro | DHCP (10.10.10.100–200) |
| WS-02 | Workstation | Windows 11 Pro | DHCP (10.10.10.100–200) |
| MON-01 | Monitoring Server | Debian 13 | 10.10.10.20 (Static) |
| VPN-01 | VPN Gateway | Debian 13 | 10.10.10.30 (Internal) / 192.168.1.39 (External) |

---

## 📦 Scope

This lab covers the following areas:

**Phase 1 – Core Infrastructure**
Hyper-V virtualization setup on a Windows 10 Home host, including internal virtual switch and NAT configuration. Deployment of a Windows Server 2025 Domain Controller (DC-01) with Active Directory Domain Services and DNS. Deployment of two Windows 11 Pro workstations (WS-01 and WS-02), both domain-joined.

**Phase 2 – Identity, Network Services & Policy Implementation**
Structured Organizational Unit hierarchy and user provisioning automated via PowerShell. Security group design following the AGDLP model. DHCP server configuration on DC-01. Group Policy implementation covering security hardening, BitLocker, Windows Defender, firewall rules, update management, and USB control. Departmental file shares secured using NTFS and Share permissions with automated drive mapping via GPO.

**Phase 3 – Hybrid Identity and Cloud Integration**
Custom domain verification in Microsoft Entra ID and UPN alignment. Entra Connect deployment with Password Hash Synchronization and Seamless SSO. MFA enforcement and Conditional Access policies (Zero Trust baseline). Group-based Microsoft 365 E3 licensing. Exchange Online shared mailbox configuration. Hybrid Entra ID Join and Intune enrollment. Device compliance policies and Conditional Access enforcement. Microsoft 365 App deployment, Win32 app packaging, and application lifecycle management via Intune. Retention policy configuration and eDiscovery-based recovery validation. Azure Backup implementation for on-premises file shares and Domain Controller System State.

**Phase 4 – Monitoring Layer**
Dedicated Linux monitoring server deployment (MON-01 – Debian 13). Zabbix 7.0 installation and configuration. Zabbix Agent 2 deployment on all Windows hosts via GPO. Host registration and metric collection. Grafana integration with Zabbix data source. Custom alerting pipeline using Microsoft Graph API (OAuth 2.0) for email notifications.

**Extras**
WireGuard VPN gateway deployment for simulated remote access. Action1 cloud-based patch management integration.

---

## 🎯 Skills & Technologies Demonstrated

**Active Directory & Identity**
Active Directory Domain Services administration, OU design and management, Security Group management (AGDLP model), Group Policy Object (GPO) creation and troubleshooting, PowerShell automation for identity provisioning.

**Networking**
DHCP server configuration and scope management, DNS configuration and resolution, static and dynamic IP addressing, virtual networking with Hyper-V (Internal Switch + NAT), VPN configuration with WireGuard.

**Security & Hardening**
Password and account lockout policy enforcement, NTLMv2 authentication hardening, LDAP and SMB signing enforcement, BitLocker drive encryption via GPO, Windows Defender configuration, firewall rule management, USB device control, UAC configuration.

**Cloud & Hybrid Identity**
Microsoft Entra ID configuration, Entra Connect (PHS + Seamless SSO), Conditional Access policy design, MFA enforcement with Microsoft Authenticator, hybrid Entra ID Join, group-based licensing.

**Endpoint Management**
Microsoft Intune enrollment and compliance policies, Win32 app packaging with IntuneWinAppUtil, application supersedence and lifecycle management, Company Portal deployment, remote uninstall governance, Action1 patch management.

**Data Protection & Backup**
Microsoft 365 retention policy configuration, eDiscovery case creation and recovery, Azure Backup with MARS agent, Recovery Services Vault configuration, System State backup for Domain Controllers, backup alerting with Log Analytics and KQL.

**Monitoring & Observability**
Zabbix 7.0 server and agent deployment, host and metric configuration, Grafana dashboard integration, alerting pipeline with Microsoft Graph API and OAuth 2.0.

**Linux Administration**
Debian 13 installation and configuration, static network interface configuration, service management with systemctl, WireGuard VPN deployment, Zabbix and Grafana installation.

**Documentation**
End-to-end technical documentation of all phases, design decision justification, troubleshooting log with root cause analysis and lessons learned.

---

## 🛠 Tools & Technologies

| Category | Technology |
|----------|------------|
| Virtualization | Microsoft Hyper-V |
| Server OS | Windows Server 2025 |
| Client OS | Windows 11 Pro |
| Linux | Debian 13 (Trixie) |
| Directory Services | Active Directory Domain Services |
| Cloud Identity | Microsoft Entra ID |
| Synchronization | Microsoft Entra Connect |
| Endpoint Management | Microsoft Intune |
| Productivity Suite | Microsoft 365 (E3) |
| Email | Exchange Online |
| Backup | Azure Backup / MARS Agent |
| Monitoring | Zabbix 7.0 LTS |
| Visualization | Grafana OSS |
| VPN | WireGuard |
| Patch Management | Action1 |
| Scripting | PowerShell, JavaScript (Zabbix Webhook) |
| Query Language | KQL (Azure Log Analytics) |
| Database | MariaDB |
| Web Server | Apache |