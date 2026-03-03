# Phase 3 – Hybrid Identity and Cloud Integration

---

## 🎯 Objective

Extend the on-premises Active Directory environment into a hybrid identity architecture integrated with :contentReference[oaicite:0]{index=0} Entra ID and Microsoft 365.

This phase focuses on synchronizing identities to the cloud, enforcing modern authentication and security controls, enabling cloud-based collaboration services, and integrating endpoint management and backup solutions.

The goal is to simulate a modern enterprise hybrid environment where on-prem Active Directory remains authoritative while cloud identity, security, device management, and data protection capabilities are fully leveraged.

---

## 📦 Scope

This phase includes:

- Assigning and validating a custom domain in Microsoft Entra ID  
- Configuring alternate UPN suffix in on-prem Active Directory  
- Installing and configuring Microsoft Entra Connect  
- Implementing Password Hash Synchronization (PHS)  
- Enabling Seamless Single Sign-On (SSO)  
- Validating directory synchronization  
- Configuring Microsoft Authenticator MFA  
- Implementing Conditional Access policies  
- Assigning Microsoft 365 licenses using group-based licensing  
- Creating Microsoft 365 Groups and shared mailboxes  
- Configuring Hybrid Azure AD Join  
- Enabling Intune automatic enrollment  
- Implementing device compliance policies  
- Deploying Microsoft 365 applications through Intune  
- Configuring Microsoft 365 retention and recovery features  
- Implementing Azure Backup for on-prem file shares  

---

## 🏗 Infrastructure Components

### Hybrid Identity

- On-prem Active Directory (bocorp.local)
- Microsoft Entra ID tenant
- Custom verified domain
- Microsoft Entra Connect server
- Password Hash Synchronization
- Seamless Single Sign-On

### Authentication & Security

- Microsoft Authenticator MFA
- Conditional Access policies
- Identity protection controls
- Group-based licensing
- Role-based access control (RBAC)

### Cloud Collaboration

- Microsoft 365 Groups
- Exchange Online shared mailboxes
- Group-based license assignment (E3)

### Device & Endpoint Management

- Hybrid Azure AD Join
- Microsoft Intune enrollment
- Compliance policies
- Configuration profiles
- Microsoft 365 Apps deployment (Excel, Outlook, Teams, etc.)

### Data Protection & Backup

- Microsoft 365 retention policies
- Exchange Online recovery validation
- OneDrive / SharePoint recycle validation
- Azure Backup for on-prem file shares
- Backup policy configuration and scheduling

---

## 🔐 Architectural Design Principles

This phase follows modern hybrid identity best practices:

- On-prem Active Directory remains the authoritative identity source  
- Cloud authentication is secured using MFA and Conditional Access  
- Access control is enforced through security group membership  
- Licensing is assigned dynamically through synchronized groups  
- Devices are centrally managed through Intune  
- Backup and retention strategies are implemented for resilience  
- Administrative privileges are minimized and controlled  

---

## 📂 Files Included

- `08-entra-domain-configuration.md` – Custom domain configuration and UPN alignment  
- `09-entra-connect-configuration.md` – Entra Connect installation and synchronization  
- `10-authentication-and-conditional-access.md` – MFA and Conditional Access implementation  
- `11-licensing-and-rbac.md` – Group-based licensing and administrative roles  
- `12-exchange-online-configuration.md` – Shared mailbox and Microsoft 365 group setup  
- `13-intune-and-device-management.md` – Hybrid Join and compliance configuration  
- `14-intune-app-deployment.md` – Microsoft 365 Apps deployment to WS-01 (Excel, Outlook, Teams, etc.)
- `15-microsoft-365-retention-and-recovery.md` – Exchange Online and OneDrive/SharePoint recovery validation  
- `16-azure-backup.md` – Azure Backup configuration for on-prem file shares  

---

## ✅ Outcome

By completing this phase:

- **Extended Identity to the Cloud:**  
  On-prem Active Directory identities are synchronized securely to Microsoft Entra ID.

- **Modernized Authentication:**  
  MFA and Conditional Access policies protect user authentication and reduce credential-based attacks.

- **Enabled Cloud Collaboration:**  
  Microsoft 365 services are integrated with on-prem security groups and licensing controls.

- **Implemented Centralized Device Management:**  
  Hybrid-joined devices are enrolled into Intune and governed by compliance policies.

- **Automated Application Deployment:**  
  Microsoft 365 Apps are deployed centrally to domain-joined endpoints using Intune.

- **Strengthened Data Protection:**  
  Retention policies and Azure Backup provide business continuity and recovery capabilities.

- **Simulated Enterprise Hybrid Architecture:**  
  The lab now reflects a real-world hybrid identity deployment with cloud security, device management, and data protection layers.