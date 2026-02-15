# Phase 1 – Core Infrastructure Deployment

---

## 🎯 Objective

Deploy the foundational infrastructure required to support a Windows Active Directory domain environment.

This phase focuses on building a fully functional on-premises domain using Hyper-V virtualization, a Windows Server Domain Controller, and domain-joined Windows 11 clients.

The goal is to establish a stable and validated infrastructure baseline before implementing logical configuration, policies, automation, or cloud integration in later phases.

---

## 📦 Scope

This phase includes:

- Enabling and configuring Hyper-V on a Windows 10 Home host
- Creating and configuring an External Virtual Switch
- Deploying a Windows Server 2025 virtual machine (DC-01)
- Installing Active Directory Domain Services (AD DS)
- Promoting the server to Domain Controller
- Deploying two Windows 11 Pro client machines (WS-01 and WS-02)
- Joining both clients to the domain
- Performing infrastructure validation tests

---

## 🏗 Infrastructure Components

### Virtualization Layer
- Hyper-V
- External Virtual Switch for network connectivity

### Domain Controller
- Hostname: `DC-01`
- OS: Windows Server 2025
- Roles:
  - Active Directory Domain Services
  - DNS Server (installed with AD DS)

### Client Workstations
- `WS-01` – Windows 11 Pro (manual installation)
- `WS-02` – Windows 11 Pro (deployed from snapshot/checkpoint)

---

## 🌐 Network Design (Initial Baseline)

- Virtual Switch Type: Internal + NAT
- Domain Controller IP: 10.10.10.10 (Static)
- Clients: DHCP (to be configured in later phase)
- DNS: Domain Controller

This configuration ensures internal domain functionality while maintaining internet connectivity for future synchronization with Microsoft Entra.

---

## 📂 Files Included

- `01-hyperv-setup.md` – Hyper-V enablement and virtual switch configuration  
- `02-domaincontroller-setup.md` – Windows Server installation and Domain Controller promotion  
- `03-client-setup.md` – Windows 11 Pro installation and configuration

---

## ✅ Outcome

By completing this phase:

- **Prepared a Virtualized Environment:**  
  Established isolated virtual machines for both server and client systems, creating a controlled and scalable lab environment.

- **Ensured Network Communication:**  
  Configured virtual networking to allow reliable communication between domain controller and client machines.

- **Successfully Deployed a Domain Controller:**  
  Installed and promoted Windows Server 2025 as DC-01, enabling Active Directory Domain Services and DNS functionality.

- **Integrated Domain-Joined Endpoints:**  
  Connected two Windows 11 workstations to the domain, validating authentication and internal name resolution.
