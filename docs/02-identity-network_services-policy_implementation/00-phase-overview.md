# Phase 2 – Identity, Network Services & Policy Implementation

---

## 🎯 Objective

Build and structure the logical components of the Active Directory environment to simulate real-world enterprise administration.

This phase focuses on implementing organizational structure, network services, policy enforcement, and access control while introducing automation and ticket-based workflows.

The goal is to transition from a functional infrastructure baseline to an operational IT environment that reflects day-to-day system administration tasks.

---

## 📦 Scope

This phase includes:

- Designing and creating Organizational Units (OUs)
- Creating domain users and security groups
- Automating identity provisioning using PowerShell
- Installing and configuring the DHCP Server role
- Creating and linking Group Policy Objects (GPOs)
- Configuring departmental file shares
- Applying NTFS and Share permissions based on security groups
- Simulating service desk requests using JIRA

---

## 🏗 Infrastructure Components

### Active Directory Structure
- Organizational Units (Department-based hierarchy)
- User accounts (standardized naming convention)
- Security Groups (Role-Based Access Control model)

### Network Services
- DHCP Server (installed on DC-01)
- Configured scope for 10.10.10.0/24 network
- Dynamic IP assignment for domain clients

### Group Policy Management
- Department-based GPO application
- Security hardening policies
- Workstation configuration policies

### File Services
- Departmental shared folders
- Access controlled via Security Groups
- NTFS + Share permission alignment

### Operational Simulation
- JIRA ticket scenarios for:
  - New user creation
  - Access requests
  - Department transfers
  - Policy troubleshooting

---

## 📂 Files Included

- `04-ou-and-identity-setup.md` – OU structure, users and security groups  
- `05-dhcp-configuration.md` – DHCP role installation and scope configuration  
- `06-gpo-implementation.md` – Group Policy creation and validation  
- `07-file-shares.md` – Departmental shares and permissions configuration  
- `08-operational-scenarios.md` – JIRA ticket simulations and automation tasks  

---

## ✅ Outcome

By completing this phase:

- **Structured the Active Directory Environment:**  
  Implemented a logical OU hierarchy aligned with enterprise design principles.

- **Centralized Identity Management:**  
  Created and organized users and security groups using automation where applicable.

- **Implemented Network Automation:**  
  Configured DHCP to dynamically manage IP address assignment.

- **Enforced Policy-Based Management:**  
  Applied Group Policy Objects to control security settings and workstation behavior.

- **Established Controlled Resource Access:**  
  Configured file shares secured through role-based security groups.

- **Simulated Real IT Operations:**  
  Executed administrative tasks through ticket-based workflows to mirror real-world helpdesk and sysadmin processes.
