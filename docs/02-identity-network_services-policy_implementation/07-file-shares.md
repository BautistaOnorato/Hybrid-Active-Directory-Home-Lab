# 07 - File Shares and Departmental Drive Mapping

---

## 🎯 Objective

Implement a structured and secure departmental file sharing model within the **bocorp.local** domain that:

- Provides department-based shared folders
- Applies permissions using the AGDLP model
- Separates NTFS and Share permissions correctly
- Prevents direct user-based permission assignments
- Automatically maps departmental drives using Group Policy
- Uses Item-Level Targeting for RBAC-based drive deployment

---

## 1. File Share Architecture Overview

For lab simplicity, the **Domain Controller (DC-01)** was temporarily used as the file server.

> ⚠ In production environments, file services should be hosted on a dedicated member server to maintain role separation.

The departmental share structure was implemented as follows:

```
C:\Shares\
├── Finance
├── HR
├── IT
├── Sales
```

---

## 2. Permission Model Design (AGDLP)

The file permission model strictly follows:

> Accounts → Global Groups → Domain Local Groups → Permissions

Example for Finance:

```
GG-Finance-Users      → Member of → DL-Share-Finance-RO
GG-Finance-Managers   → Member of → DL-Share-Finance-RW

DL-Share-Finance-RO   → NTFS Read & Execute
DL-Share-Finance-RW   → NTFS Modify
```

### Design Principles

- Permissions are never assigned directly to users.
- Global Groups represent logical department membership.
- Domain Local Groups are used exclusively for resource permission assignment.
- NTFS permissions enforce access control.
- Share permissions remain broad and defer restriction to NTFS.
- The effective permission is always the most restrictive combination between Share and NTFS.

---

## 3. NTFS Configuration (Security Properties)

Each departmental folder was configured individually.

### Steps Performed

1. Right-click folder → **Properties**
2. Navigate to **Security → Advanced**
3. Click **Disable inheritance**
4. Select **Convert inherited permissions**

### Cleanup

The following inherited entries were removed:

- Users
- CREATOR OWNER

The following entries were retained:

- SYSTEM → Full Control  
- Administrators → Full Control  

### Domain Local Groups Added

Example (Finance):

| Group | Permission |
|--------|------------|
| DL-Share-Finance-RW | Modify |
| DL-Share-Finance-RO | Read & Execute |

This ensures NTFS enforces granular access control while preserving administrative access.

📸 **NTFS Advanced Security Settings – Finance Folder**

![NTFS Security Settings](/screenshots/07/01.png)

---

## 4. Share Configuration (Sharing Properties)

Each folder was shared using **Advanced Sharing**.

### Steps Performed

1. Right-click folder → **Properties**
2. Navigate to **Sharing → Advanced Sharing**
3. Enable **Share this folder**
4. Define Share Name (e.g., `Finance`)

### Share Permissions Configuration

The default **Everyone** entry was removed.

The following groups were added:

| Group | Permission |
|--------|------------|
| DL-Share-Finance-RW | Full Control |
| DL-Share-Finance-RO | Read |

### Permission Strategy

In this design:

- Share permissions are kept broad.
- NTFS handles detailed access control.
- Effective access is determined by the most restrictive combination of Share and NTFS permissions.

📸 **Advanced Sharing Configuration – Finance**

![Share Permissions](/screenshots/07/02.png)

---

## 5. Access-Based Enumeration (ABE)

To enhance security and improve user experience, Access-Based Enumeration was enabled on each share.

### Purpose

- Users only see folders they have permission to access.
- Prevents exposure of other departmental structures.
- Reduces unnecessary visibility of restricted resources.

### Configuration Path

```
Server Manager
→ File and Storage Services
→ Shares
→ Properties
→ Settings
→ Enable Access-Based Enumeration
```

📸 **Access-Based Enumeration Enabled**

![Access Based Enumeration](/screenshots/07/03.png)

---

## 6. Centralized Drive Mapping via Group Policy

To eliminate manual UNC path navigation, departmental drives were automatically mapped using **Group Policy Preferences**.

---

## 6.1 GPO Creation

A centralized GPO was created:

```
GPO-Dept-DriveMappings
```

The GPO was linked to:

```
OU=Departments,DC=bocorp,DC=local
```

Using a single GPO ensures:

- Centralized management
- Reduced administrative overhead
- Easier scalability

---

## 6.2 Drive Mapping Configuration

Path inside the GPO:

```
User Configuration
   → Preferences
      → Windows Settings
         → Drive Maps
```

Four mapped drives were configured within the same GPO, one per department.

---

### Example: Finance Drive Mapping

| Setting | Value |
|----------|--------|
| Action | Replace |
| Location | \\DC-01\Finance |
| Drive Letter | F: |
| Label | Finance |
| Reconnect | Enabled |

### Why "Replace" Instead of "Create"?

Using **Replace** ensures:

- Consistent drive configuration
- Automatic correction of broken mappings
- Proper reassignment if a user changes departments

The **Reconnect** option ensures the drive is automatically restored after network interruptions or server restarts.

📸 **Drive Mapping Configuration – Finance**

![Drive Mapping Configuration](/screenshots/07/04.png)

---

## 7. Item-Level Targeting (RBAC Enforcement)

Each mapped drive uses **Item-Level Targeting** to ensure deployment is strictly based on group membership.

### Finance Targeting Example

Security Group condition:

```
GG-Finance-Users
OR
GG-Finance-Managers
```

This ensures:

- Only Finance users receive the Finance drive.
- No reliance solely on OU placement.
- Proper Role-Based Access Control (RBAC).
- Clean and scalable design.

📸 **Item-Level Targeting Configuration**

![Item Level Targeting](/screenshots/07/05.png)

---

## 8. Testing and Validation

Testing was performed from **WS-01** to validate functionality.

### Validation Scenarios

- Finance standard user → Read-only access confirmed.
- Finance manager → Modify permissions confirmed.
- HR user attempting access to Finance → Access Denied.
- `gpupdate /force` used to refresh policies.
- `gpresult /r` used to confirm GPO application.
- Effective Access tab used to verify NTFS resolution.

📸 **Mapped Drive Visible in File Explorer**

![Mapped Drive Finance](/screenshots/07/06.png)

📸 **Access Denied Test from Non-Finance User**

![Access Denied Test](/screenshots/07/07.png)

---

## ✅ Outcome

After implementation:

- Departmental shares are properly segmented.
- Permissions are entirely group-based.
- The AGDLP model is correctly applied.
- NTFS and Share permissions are properly separated.
- Drive mappings are automatically deployed via GPO.
- Access-Based Enumeration limits resource visibility.
- The environment follows enterprise-level RBAC best practices.