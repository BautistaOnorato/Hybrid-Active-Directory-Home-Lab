# 11 – Licensing and RBAC

---

## 🎯 Objective

Implement a structured cloud governance model in Microsoft Entra ID by configuring group-based licensing and Role-Based Access Control (RBAC).

This section covers:

- Assigning Microsoft 365 E3 licenses to synchronized on-premises security groups
- Creating cloud-only role groups with assignable Entra ID roles
- Delegating administrative roles following the Principle of Least Privilege
- Validating automatic license assignment for department users

---

## 🏗 Architecture Overview

### Licensing Model

Licenses are assigned to synchronized Global Security Groups from on-premises Active Directory. When a user is added to a group on-premises, they synchronize to Entra ID and automatically inherit the assigned license — no manual per-user licensing is required.

```
On-Prem AD
GG-Finance-Users / GG-HR-Users / GG-IT-Users / GG-Sales-Users
        ↓
Synchronized to Microsoft Entra ID
        ↓
Group-Based License Assignment (Microsoft 365 E3)
        ↓
Users receive license automatically
```

### RBAC Model

Administrative roles are assigned to dedicated cloud-only security groups created directly in Microsoft Entra ID. This maintains a clear boundary between identity management (on-premises) and cloud administrative control.

```
Cloud-Only Role Groups (Microsoft Entra ID)
        ↓
Entra ID Administrative Roles assigned to groups
        ↓
Users added to role groups receive delegated permissions
```

| Role Group | Entra ID Role | Capabilities |
|------------|--------------|--------------|
| `GRP-Cloud-License-Admins` | License Administrator | Assign and remove licenses, manage license-based services |
| `GRP-Cloud-Helpdesk-Admins` | Helpdesk Administrator | Reset passwords, unlock accounts, manage basic user properties |
| `GRP-Cloud-Security-Admins` | Security Administrator | Manage Conditional Access policies, configure security settings |
| `GRP-Cloud-Security-Operators` | Security Operator | Investigate alerts, review incidents, monitor security dashboards |

---

## 1️⃣ Configure Group-Based Licensing

### 1.1 Assign License to Global Security Groups

Navigate to the Microsoft 365 Admin Center and open each synchronized Global Security Group:

```
https://admin.cloud.microsoft → Teams & Groups → Active teams & groups → Security groups
```

For each of the following groups, assign the **Microsoft 365 E3** license:

```
GG-Finance-Users
GG-HR-Users
GG-IT-Users
GG-Sales-Users
```

Open the group → **Licenses and apps** → select **Microsoft 365 E3** → configure the desired apps → **Save changes**.

---

### 1.2 Validate Automatic License Assignment

Navigate to the Active Users list and confirm that department users show the license assigned:

```
https://admin.cloud.microsoft → Users → Active users
```

Confirm the **Licenses** column shows `Microsoft 365 E3` for users in the licensed groups.

📸 **User licenses showing Microsoft 365 E3**

![User License](/screenshots/11/01.png)

---

## 2️⃣ Configure Role-Based Access Control

All role groups were created directly in Microsoft Entra ID as cloud-only security groups with the **Azure AD roles can be assigned to the group** option enabled. This setting must be configured at group creation time and cannot be changed afterward.

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Groups → New group
```

For each group, set:

| Setting | Value |
|---------|-------|
| Group type | Security |
| Azure AD roles can be assigned to the group | Yes |

---

### 2.1 License Administrator

**Group:** `GRP-Cloud-License-Admins`

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Roles and administrators → License Administrator → Add assignments
```

Assign the role to `GRP-Cloud-License-Admins`.

📸 **License Administrator role assigned to GRP-Cloud-License-Admins**

![License Administrator role assignment](/screenshots/11/02.png)

---

### 2.2 Helpdesk Administrator

**Group:** `GRP-Cloud-Helpdesk-Admins`

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Roles and administrators → Helpdesk Administrator → Add assignments
```

Assign the role to `GRP-Cloud-Helpdesk-Admins`.

📸 **Helpdesk Administrator role assigned to GRP-Cloud-Helpdesk-Admins**

![Helpdesk Administrator role assignment](/screenshots/11/03.png)

---

### 2.3 Security Administrator

**Group:** `GRP-Cloud-Security-Admins`

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Roles and administrators → Security Administrator → Add assignments
```

Assign the role to `GRP-Cloud-Security-Admins`.

📸 **Security Administrator role assigned to GRP-Cloud-Security-Admins**

![Security Administrator role assignment](/screenshots/11/04.png)

---

### 2.4 Security Operator

**Group:** `GRP-Cloud-Security-Operators`

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Roles and administrators → Security Operator → Add assignments
```

Assign the role to `GRP-Cloud-Security-Operators`.

📸 **Security Operator role assigned to GRP-Cloud-Security-Operators**

![Security Operator role assignment](/screenshots/11/05.png)

---

## ✅ Outcome

After completing this section:

- Microsoft 365 E3 licenses are assigned automatically to department users through synchronized Global Security Groups.
- Four cloud-only role groups are created with assignable Entra ID roles.
- Administrative permissions are delegated following the Principle of Least Privilege.
- No licenses or administrative roles are assigned directly to individual user accounts.
- The cloud governance model is decoupled from the on-premises group structure, maintaining a clear administrative boundary.