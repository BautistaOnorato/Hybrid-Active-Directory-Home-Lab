# Phase 2 – Identity, Network Services & Policy Implementation

---

## 🎯 Objective

Build and structure the logical components of the Active Directory environment to simulate real-world enterprise administration.

This phase focuses on implementing organizational structure, network services, policy enforcement, and access control while introducing automation through PowerShell scripting.

The goal is to transition from a functional infrastructure baseline into an operational IT environment that reflects day-to-day system administration tasks.

---

## 📦 Scope

This phase includes:

- Designing and creating the Organizational Unit (OU) hierarchy
- Creating domain users and security groups following the AGDLP model
- Automating identity provisioning using PowerShell
- Installing and configuring the DHCP Server role on DC-01
- Creating and linking Group Policy Objects (GPOs)
- Configuring departmental file shares with NTFS and Share permissions
- Mapping departmental drives automatically via Group Policy Preferences

---

## 🏗 Infrastructure Components

### Active Directory Structure

- Organizational Units (department-based hierarchy)
- User accounts (standardized naming convention)
- Security Groups (AGDLP model — Global and Domain Local)

### Network Services

- DHCP Server installed on DC-01
- Scope configured for the `10.10.10.0/24` network
- Dynamic IP assignment for domain-joined clients

### Group Policy Management

- Domain-wide security baseline GPOs
- Workstation hardening policies
- Department-specific configuration policies
- GPO backup automation

### File Services

- Departmental shared folders hosted on DC-01
- Access controlled via Domain Local security groups
- NTFS and Share permissions aligned to the AGDLP model
- Access-Based Enumeration enabled on all shares
- Automated drive mapping via Group Policy Preferences with Item-Level Targeting

---

## 🔐 Architectural Design Principles

This phase follows standard enterprise identity and access management practices:

- Active Directory structure is designed for scalability and administrative delegation
- Security groups follow the AGDLP model — permissions are never assigned directly to users
- Global Groups represent logical department membership; Domain Local Groups control resource access
- Group Policy is used to enforce consistent security configuration across all endpoints
- File share permissions are layered: Share permissions remain broad while NTFS enforces granular access control
- Drive mappings use Item-Level Targeting to ensure each user only receives the drives they are authorized to access

---

## 📂 Files Included

- [`04-ou-and-identity-setup.md`](/docs/02-identity-network_services-policy_implementation/04-ou-and-identity-setup.md) – OU structure, security groups, and automated user provisioning
- [`05-dhcp-configuration.md`](/docs/02-identity-network_services-policy_implementation/05-dhcp-configuration.md) – DHCP role installation and scope configuration
- [`06-gpo-configuration.md`](/docs/02-identity-network_services-policy_implementation/06-gpo-configuration.md) – Group Policy creation, configuration, and backup strategy
- [`07-file-shares.md`](/docs/02-identity-network_services-policy_implementation/07-file-shares.md) – Departmental shares, NTFS permissions, and drive mapping

---

## ✅ Outcome

By completing this phase:

- **Structured the Active Directory Environment:**
  Implemented a logical OU hierarchy aligned with enterprise design principles, with clear separation between administrative, departmental, and resource objects.

- **Centralized Identity Management:**
  Created and organized users and security groups using PowerShell automation, following the AGDLP model for role-based access control.

- **Implemented Network Automation:**
  Configured DHCP on DC-01 to dynamically manage IP address assignment for all domain-joined clients.

- **Enforced Policy-Based Management:**
  Applied Group Policy Objects to control security settings, harden workstations, and enforce consistent configuration across the environment.

- **Established Controlled Resource Access:**
  Configured departmental file shares secured through role-based security groups, with automated drive mapping deployed via Group Policy Preferences.