# 04 - OU and Identity Setup

---

## 🎯 Objective

Design and deploy a structured Active Directory identity model that will:

- Implement a scalable Organizational Unit hierarchy
- Establish a structured Security Group model following AGDLP
- Separate administrative, departmental, and resource objects
- Automate user and group creation using PowerShell
- Prepare the environment for GPO deployment and file server permissions

---

## 1. Organizational Unit (OU) Structure

The Active Directory structure was designed following enterprise best practices, focusing on scalability, security, administrative delegation, and security boundaries.

The implemented hierarchy in **bocorp.local** is:

```
bocorp.local
├── _Admin
│   ├── Admin-Users
│   ├── Service-Accounts
├── _Disabled-Objects
├── _Groups
│   ├── Global
│   ├── DomainLocal
├── Builtin
├── Computers
├── Departments
│   ├── Finance
│   ├── Human Resources
│   ├── IT
│   │   ├── ITSecurity
│   │   ├── ITSupport
│   ├── Sales
├── Domain Controllers
├── ForeignSecurityPrincipals
├── ManagedServiceAccounts
├── Servers
├── Users
├── Workstations
```

📸 **Active Directory Users and Computers (ADUC) Showing OU structure**

![Active Directory Users and Computers (ADUC) Showing OU structure](/screenshots/04/01.png)

### Design Principles

The structure was created based on the following principles:

- Clear separation between administrative accounts and standard user accounts.
- Isolation of privileged objects under `_Admin`.
- Centralized management of security groups under `_Groups`.
- Logical segregation of disabled objects inside `_Disabled-Objects`.
- Department-based organization under `Departments`.
- Sub-division of the IT department into:
  - `ITSecurity`
  - `ITSupport`

This structure ensures:

- Granular GPO application
- Easier delegation of administrative rights
- Better visibility and control
- Enterprise-aligned design standards
- Future scalability

---

## 2. Security Group Design

The group architecture follows the **AGDLP model**:

> Accounts → Global Groups → Domain Local Groups → Permissions

All groups are organized under:

```
_Groups
├── Global
├── DomainLocal
```

This separation enforces clarity between logical grouping (Global) and permission assignment (Domain Local).

---

## 2.1 Global Security Groups (GG)

**Location:**

```
OU=Global,OU=_Groups,DC=bocorp,DC=local
```

**Defined Global Groups:**

```
GG-Finance-Users
GG-HR-Users
GG-IT-Users
GG-Sales-Users

GG-Finance-Managers
GG-HR-Managers
GG-IT-Managers
GG-Sales-Managers

GG-Helpdesk-PasswordReset
GG-Workstation-Admins
```

### Purpose

Global Groups are used to:

- Group users by department.
- Separate Managers from standard Users.
- Apply role-based access control (RBAC).
- Delegate specific administrative privileges.
- Serve as the logical grouping layer in AGDLP.

Examples:

- `GG-IT-Users` → Standard IT personnel
- `GG-IT-Managers` → IT leadership accounts
- `GG-Helpdesk-PasswordReset` → Delegated password reset capability
- `GG-Workstation-Admins` → Local workstation administrative rights

📸 **Global Groups**

![Global Groups](/screenshots/04/05.png)

---

## 2.2 Domain Local Security Groups (DL)

**Location:**

```
OU=DomainLocal,OU=_Groups,DC=bocorp,DC=local
```

**Defined Domain Local Groups:**

```
DL-Share-Finance-RW
DL-Share-HR-RW
DL-Share-IT-RW
DL-Share-Sales-RW

DL-Share-Finance-RO
DL-Share-HR-RO
DL-Share-IT-RO
DL-Share-Sales-RO
```

### Purpose

Domain Local Groups are used to:

- Assign direct NTFS and Share permissions.
- Separate Read-Write (RW) and Read-Only (RO) access levels.
- Receive membership from Global Groups.

Example implementation:

```
GG-Finance-Users      → Member of → DL-Share-Finance-RO
GG-Finance-Managers   → Member of → DL-Share-Finance-RW
```

This ensures:

- Permissions are never assigned directly to users.
- Changes in access are handled by modifying group membership.
- The environment remains clean, scalable, and manageable.

📸 **Domain Local Security Groups**

![Domain Local Security Groups](/screenshots/04/02.png)

---

## 3. Automation Script

A PowerShell automation script was developed to deploy the full identity structure.

### ⚙ The script performs the following tasks:

1. Creates the complete OU hierarchy.
2. Creates all Global Security Groups.
3. Creates all Domain Local Security Groups.
4. Imports users from a CSV file.
5. Creates:
   - 1 Manager per department
   - 3 Users per department
6. Places each user in the correct Department OU.
7. Distributes IT users between:
   - `OU=ITSecurity`
   - `OU=ITSupport`
8. Assigns users to the appropriate Global Security Group.
9. Provides console feedback for success or failure.

### 📂 Files Included

- **Script**: [`identity-deployment.ps1`](/scripts/identity-deployment.ps1)  
- **CSV File**: [`bocorp-users.csv`](/scripts/bocorp-users.csv)

📸 **Script Output**

![Script Output](/screenshots/04/03.png)
![Script Output](/screenshots/04/04.png)

---

## ✅ Outcome

After execution:

- The complete OU structure is deployed.
- All Global and Domain Local groups are created.
- All users are placed inside their corresponding Department OU.
- IT users are correctly distributed between ITSecurity and ITSupport.
- Users are members of their appropriate Global Security Group.
- Global Groups are ready to be nested into Domain Local Groups.
