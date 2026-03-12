# 04 – OU and Identity Setup

---

## 🎯 Objective

Design and deploy a structured Active Directory identity model for the `bocorp.local` domain.

This section covers:

- Designing and creating the Organizational Unit (OU) hierarchy
- Creating Global and Domain Local security groups following the AGDLP model
- Importing users from a CSV file and placing them in their corresponding OUs
- Automating the full identity deployment using a PowerShell script

---

## 🏗 Architecture Overview

The identity model is built around two core principles: **organizational clarity** through a structured OU hierarchy, and **role-based access control** through the AGDLP security group model.

```
bocorp.local
├── _Admin
│   ├── Admin-Users
│   └── Service-Accounts
├── _Disabled-Objects
├── _Groups
│   ├── Global
│   └── DomainLocal
├── Departments
│   ├── Finance
│   ├── Human Resources
│   ├── IT
│   │   ├── ITSecurity
│   │   └── ITSupport
│   └── Sales
├── Servers
└── Workstations
```

### AGDLP Model

The group architecture follows the **AGDLP model**:

```
Accounts → Global Groups → Domain Local Groups → Permissions
```

- **Global Groups** represent logical department membership and are the only groups that contain user accounts
- **Domain Local Groups** are used exclusively for resource permission assignment
- Permissions are never assigned directly to users or Global Groups

---

## 1️⃣ Organizational Unit Structure

The OU hierarchy was designed following enterprise best practices, focusing on scalability, security boundaries, and administrative delegation.

### Design Principles

- Clear separation between administrative accounts (`_Admin`) and standard user accounts (`Departments`)
- Privileged objects isolated under `_Admin` to enable targeted GPO application and delegation
- Security groups centralized under `_Groups` with explicit separation between Global and Domain Local
- Disabled objects isolated in `_Disabled-Objects` to keep the directory clean without permanent deletion
- The IT department is subdivided into `ITSecurity` and `ITSupport` to support granular policy and access control

📸 **Active Directory Users and Computers showing the full OU structure**

![Active Directory Users and Computers showing OU structure](/screenshots/04/01.png)

---

## 2️⃣ Security Group Design

All groups are organized under:

```
_Groups
├── Global        → OU=Global,OU=_Groups,DC=bocorp,DC=local
└── DomainLocal   → OU=DomainLocal,OU=_Groups,DC=bocorp,DC=local
```

---

### 2.1 Global Security Groups

Global Groups are used to group users by department and role. They serve as the logical grouping layer in AGDLP and are nested into Domain Local Groups to grant resource access.

| Group | Purpose |
|-------|---------|
| `GG-Finance-Users` | Standard Finance department users |
| `GG-HR-Users` | Standard HR department users |
| `GG-IT-Users` | Standard IT department users |
| `GG-Sales-Users` | Standard Sales department users |
| `GG-Finance-Managers` | Finance department managers |
| `GG-HR-Managers` | HR department managers |
| `GG-IT-Managers` | IT department managers |
| `GG-Sales-Managers` | Sales department managers |
| `GG-Helpdesk-PasswordReset` | Delegated password reset capability |
| `GG-Workstation-Admins` | Local administrator rights on workstations |

📸 **Global Groups in Active Directory**

![Global Groups](/screenshots/04/05.png)

---

### 2.2 Domain Local Security Groups

Domain Local Groups are used exclusively to assign NTFS and Share permissions on resources. They receive Global Groups as members — never individual user accounts.

| Group | Access Level |
|-------|-------------|
| `DL-Share-Finance-RW` | Read/Write on Finance share |
| `DL-Share-Finance-RO` | Read-Only on Finance share |
| `DL-Share-HR-RW` | Read/Write on HR share |
| `DL-Share-HR-RO` | Read-Only on HR share |
| `DL-Share-IT-RW` | Read/Write on IT share |
| `DL-Share-IT-RO` | Read-Only on IT share |
| `DL-Share-Sales-RW` | Read/Write on Sales share |
| `DL-Share-Sales-RO` | Read-Only on Sales share |

**Example membership chain for Finance:**

```
GG-Finance-Users    → Member of → DL-Share-Finance-RO
GG-Finance-Managers → Member of → DL-Share-Finance-RW
```

📸 **Domain Local Security Groups in Active Directory**

![Domain Local Security Groups](/screenshots/04/02.png)

---

## 3️⃣ Automation Script

A PowerShell script was developed to automate the full identity deployment from a single execution.

### Script: [`identity-deployment.ps1`](/scripts/identity-deployment.ps1)

**Input file:** [`bocorp-users.csv`](/scripts/bocorp-users.csv)

The script performs the following tasks:

1. Creates the complete OU hierarchy
2. Creates all Global Security Groups under `OU=Global,OU=_Groups`
3. Creates all Domain Local Security Groups under `OU=DomainLocal,OU=_Groups`
4. Imports users from the CSV file
5. Creates 1 Manager and 3 standard Users per department
6. Places each user in the correct Department OU
7. Distributes IT users between `ITSecurity` and `ITSupport`
8. Assigns each user to their appropriate Global Security Group
9. Outputs success or failure feedback to the console for each operation

📸 **Script execution output**

![Script Output](/screenshots/04/03.png)
![Script Output](/screenshots/04/04.png)

---

## ✅ Outcome

After completing this section:

- The complete OU structure is deployed across `bocorp.local`.
- All Global and Domain Local security groups are created and organized.
- All department users are placed in their corresponding OU.
- IT users are distributed between `ITSecurity` and `ITSupport`.
- Each user is a member of their appropriate Global Security Group.
- Global Groups are ready to be nested into Domain Local Groups for resource access control.