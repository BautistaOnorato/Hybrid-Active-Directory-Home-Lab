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
- Creating and configuring an Internal Virtual Switch with NAT
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
- Internal Virtual Switch with NAT for network connectivity

### Domain Controller

- Hostname: `DC-01`
- OS: Windows Server 2025 Standard Evaluation (Desktop Experience)
- Roles:
  - Active Directory Domain Services
  - DNS Server (installed with AD DS)

### Client Workstations

- `WS-01` – Windows 11 Pro (manual installation)
- `WS-02` – Windows 11 Pro (deployed from WS-01 checkpoint)

---

## 🌐 Network Design

| Component | Value |
|-----------|-------|
| Virtual Switch Type | Internal + NAT |
| Domain Controller IP | 10.10.10.10 (Static) |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | 10.10.10.1 |
| DNS Server | 10.10.10.10 (DC-01) |
| Client IP Assignment | DHCP (configured in Phase 2) |

This configuration ensures internal domain functionality while maintaining internet connectivity for future synchronization with Microsoft Entra ID.

---

## 🔐 Architectural Design Principles

This phase follows standard enterprise infrastructure deployment practices:

- The Domain Controller is the authoritative identity and DNS server for the environment
- Clients use DC-01 as their DNS server to enable proper name resolution and domain join
- Hyper-V is used as the virtualization platform to keep the lab self-contained on a single host
- A checkpoint of WS-01 is taken before domain join to serve as a clean base image for WS-02, avoiding SID conflicts and duplicate computer objects

---

## 📂 Files Included

- [`01-hyperv-setup.md`](/docs/01-core-infrastructure/01-hyperv-setup.md) – Hyper-V enablement and virtual switch configuration
- [`02-domaincontroller-setup.md`](/docs/01-core-infrastructure/02-domaincontroller-setup.md) – Windows Server installation and Domain Controller promotion
- [`03-client-setup.md`](/docs/01-core-infrastructure/03-client-setup.md) – Windows 11 Pro installation, checkpoint deployment, and domain join

---

## ✅ Outcome

By completing this phase:

- **Prepared a Virtualized Environment:**
  Established isolated virtual machines for both server and client systems, creating a controlled and scalable lab environment.

- **Ensured Network Communication:**
  Configured virtual networking to allow reliable communication between the domain controller and client machines.

- **Successfully Deployed a Domain Controller:**
  Installed and promoted Windows Server 2025 as DC-01, enabling Active Directory Domain Services and DNS functionality.

- **Integrated Domain-Joined Endpoints:**
  Connected two Windows 11 workstations to the domain, validating authentication and internal name resolution.