# 11 - Licensing and RBAC

---

## 🎯 Objective

Implement a structured cloud governance model in Microsoft Entra ID by:

- Assigning Microsoft 365 licenses using group-based licensing  
- Implementing Role-Based Access Control (RBAC)  
- Enforcing the Principle of Least Privilege  
- Separating identity management from administrative control  
- Aligning hybrid identity with enterprise-grade cloud governance practices  

This configuration ensures scalability, security, and operational efficiency in the hybrid environment.

---

## 🧱 Architectural Design Decision

### 🔹 Licensing Model

Licenses are assigned using **synchronized on-premises Global Security Groups**.

This maintains consistency with the established identity model:

> Accounts → Global Groups → Cloud Services

On-premises Active Directory remains the authoritative source for identity grouping.

---

### 🔹 RBAC Model

Administrative roles are assigned to **cloud-only security groups** created directly in Microsoft Entra ID.

This separation ensures:

- Clear boundary between identity and administration  
- Cloud governance independent from on-prem group structure  
- Secure role delegation  

---

## 1️⃣ Group-Based Licensing

---

### 📌 Design Overview

Licenses are assigned to synchronized Global Security Groups from Active Directory.

Example:

```
GG-Finance-Users
```

When users are added to this group on-prem:

1. They synchronize to Entra ID.  
2. They automatically inherit the assigned license.  
3. No manual per-user licensing is required.  

---

### 🛠 Configuration Steps

#### Step 1 – Assign License to Group

Navigate to:

```
https://admin.cloud.microsoft.com → Teams & Groups → Active teams & groups → Security groups
```

1. Open the synchronized group (e.g., `GG-Finance-Users`)  
2. Select:
   ```
   Licenses and apps
   ```
3. Choose:
   ```
   Microsoft 365 E3
   ```
4. Configure desired apps  
5. Click **Save changes**

---

#### Step 3 – Validate Automatic Assignment

Navigate to:

```
https://admin.cloud.microsoft.com → Users → Active users
```

Confirm the licenses column shows:

```
Microsoft 365 E3
```

📸 **User licenses showing Microsoft 365 E3**

![User License](/screenshots/11/01.png)

---

### ✅ Operational Impact

- Automated license provisioning  
- Reduced administrative overhead  
- Eliminates manual license errors  
- Scalable onboarding process  

---

## 2️⃣ Role-Based Access Control (RBAC)

---

### 📌 Design Overview

To implement secure cloud governance, administrative roles are assigned to dedicated **cloud-only role groups**.

These groups were created with:

```
Type: Security
Azure AD roles can be assigned to the group: Enabled
```

This allows Entra roles to be delegated through group membership.

---

### 🔐 Cloud Role Groups Created

```
GRP-Cloud-License-Admins
GRP-Cloud-Helpdesk-Admins
GRP-Cloud-Security-Admins
GRP-Cloud-Security-Operators
```

---

## 2.1 License Administrator

### Assigned Group

```
GRP-Cloud-License-Admins
```

### Role Assigned

```
License Administrator
```

### Capabilities

- Assign and remove licenses  
- Manage license-based services  
- View license consumption  

📸 **License Administrator role assignment**

![License Administrator role assignment](/screenshots/11/02.png)

---

## 2.2 Helpdesk Administrator

### Assigned Group

```
GRP-Cloud-Helpdesk-Admins
```

### Role Assigned

```
Helpdesk Administrator
```

### Capabilities

- Reset passwords for non-privileged users  
- Unlock accounts  
- Manage basic user properties  

📸 **Helpdesk Administrator role assignment**

![Helpdesk Administrator role assignment](/screenshots/11/03.png)

---

## 2.3 Security Administrator

### Assigned Group

```
GRP-Cloud-Security-Admins
```

### Role Assigned

```
Security Administrator
```

### Capabilities

- Manage Conditional Access policies  
- Configure security settings  
- Monitor security posture  

📸 **Security Administrator role assignment**

![Security Administrator role assignment](/screenshots/11/04.png)

---

## 2.4 Security Operator

### Assigned Group

```
GRP-Cloud-Security-Operators
```

### Role Assigned

```
Security Operator
```

### Capabilities

- Investigate security alerts  
- Review security incidents  
- Respond to detected threats  
- Monitor security dashboards  

📸 **Security Operator role assignment**

![Security Operator role assignment](/screenshots/11/05.png)

---

## 🔐 Security Model Achieved

This implementation enforces:

- Principle of Least Privilege  
- Role separation  
- Administrative boundary control  

---

## ✅ Outcome

After completing this section:

- Licenses are assigned automatically via synchronized groups  
- Administrative roles are delegated through cloud-based role groups  
- Privilege escalation risk is minimized  
- Hybrid identity governance is properly structured 