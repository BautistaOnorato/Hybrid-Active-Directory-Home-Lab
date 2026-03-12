# 07 – File Shares and Drive Mapping

---

## 🎯 Objective

Implement a structured and secure departmental file sharing model within the `bocorp.local` domain.

This section covers:

- Creating departmental shared folders on DC-01
- Configuring NTFS permissions following the AGDLP model
- Configuring Share permissions on each departmental folder
- Enabling Access-Based Enumeration on all shares
- Automating drive mapping via Group Policy Preferences
- Applying Item-Level Targeting to enforce role-based drive deployment
- Validating access control and drive mapping from WS-01

---

## 🏗 Architecture Overview

### Folder Structure

All departmental shares are hosted on DC-01 under `C:\Shares\`:

```
C:\Shares\
├── Finance     → \\DC-01\Finance
├── HR          → \\DC-01\HR
├── IT          → \\DC-01\IT
└── Sales       → \\DC-01\Sales
```

> In a production environment, file services should be hosted on a dedicated member server to maintain role separation. For this lab, hosting on DC-01 is acceptable given the limited scope of the environment.

### Permission Model

Permissions follow the **AGDLP model**. Permissions are never assigned directly to users or Global Groups — only Domain Local Groups are assigned to resources.

```
GG-Finance-Users      → Member of → DL-Share-Finance-RO  → NTFS: Read & Execute
GG-Finance-Managers   → Member of → DL-Share-Finance-RW  → NTFS: Modify
```

This pattern is replicated for all four departments.

### Drive Mapping

| Department | Drive Letter | UNC Path |
|------------|-------------|----------|
| Finance | F: | `\\DC-01\Finance` |
| HR | H: | `\\DC-01\HR` |
| IT | I: | `\\DC-01\IT` |
| Sales | S: | `\\DC-01\Sales` |

---

## 1️⃣ Create Departmental Folders

On **DC-01**, create the shared folder structure:

```powershell
New-Item -Path "C:\Shares\Finance" -ItemType Directory
New-Item -Path "C:\Shares\HR" -ItemType Directory
New-Item -Path "C:\Shares\IT" -ItemType Directory
New-Item -Path "C:\Shares\Sales" -ItemType Directory
```

---

## 2️⃣ Configure NTFS Permissions

NTFS permissions enforce granular access control at the file system level. Each folder was configured individually.

For each departmental folder:

1. Right-click the folder → **Properties** → **Security** → **Advanced**
2. Click **Disable inheritance** → **Convert inherited permissions into explicit permissions**
3. Remove the following inherited entries:
   - `Users`
   - `CREATOR OWNER`
4. Retain the following entries:
   - `SYSTEM` → Full Control
   - `Administrators` → Full Control
5. Add the corresponding Domain Local Groups with the permissions below

### NTFS Permission Assignments

| Folder | Group | Permission |
|--------|-------|------------|
| Finance | `DL-Share-Finance-RW` | Modify |
| Finance | `DL-Share-Finance-RO` | Read & Execute |
| HR | `DL-Share-HR-RW` | Modify |
| HR | `DL-Share-HR-RO` | Read & Execute |
| IT | `DL-Share-IT-RW` | Modify |
| IT | `DL-Share-IT-RO` | Read & Execute |
| Sales | `DL-Share-Sales-RW` | Modify |
| Sales | `DL-Share-Sales-RO` | Read & Execute |

📸 **NTFS Advanced Security Settings – Finance folder**

![NTFS Security Settings](/screenshots/07/01.png)

---

## 3️⃣ Configure Share Permissions

Each folder was shared using **Advanced Sharing**. Share permissions are kept broad and defer granular access control entirely to NTFS.

For each departmental folder:

1. Right-click the folder → **Properties** → **Sharing** → **Advanced Sharing**
2. Enable **Share this folder** and set the share name (e.g., `Finance`)
3. Click **Permissions** → remove the default `Everyone` entry
4. Add the corresponding Domain Local Groups with the permissions below

### Share Permission Assignments

| Share | Group | Permission |
|-------|-------|------------|
| Finance | `DL-Share-Finance-RW` | Full Control |
| Finance | `DL-Share-Finance-RO` | Read |
| HR | `DL-Share-HR-RW` | Full Control |
| HR | `DL-Share-HR-RO` | Read |
| IT | `DL-Share-IT-RW` | Full Control |
| IT | `DL-Share-IT-RO` | Read |
| Sales | `DL-Share-Sales-RW` | Full Control |
| Sales | `DL-Share-Sales-RO` | Read |

> The effective permission a user receives is always the most restrictive combination of Share and NTFS permissions. Since Share permissions are broad here, NTFS is the sole enforcer of granular access.

📸 **Advanced Sharing configuration – Finance**

![Share Permissions](/screenshots/07/02.png)

---

## 4️⃣ Enable Access-Based Enumeration

Access-Based Enumeration (ABE) ensures that users only see the folders they have permission to access. This prevents users from discovering the existence of shares they cannot open.

Enable ABE on each share via **Server Manager**:

```
Server Manager → File and Storage Services → Shares → Right-click share → Properties → Settings → Enable Access-Based Enumeration
```

📸 **Access-Based Enumeration enabled**

![Access Based Enumeration](/screenshots/07/03.png)

---

## 5️⃣ Configure Drive Mapping via Group Policy

Departmental drives are mapped automatically using **Group Policy Preferences** to eliminate manual UNC path navigation.

A single GPO was created to manage all drive mappings:

**GPO Name:** `GPO-Dept-DriveMappings`
**Linked to:** `OU=Departments,DC=bocorp,DC=local`

Navigate to the drive mapping settings inside the GPO:

```
User Configuration → Preferences → Windows Settings → Drive Maps
```

### Drive Mapping Configuration

Four drive mappings were configured within the same GPO, one per department. The following settings apply to all mappings:

| Setting | Value | Purpose |
|---------|-------|---------|
| Action | Replace | Ensures consistent configuration and corrects broken mappings automatically |
| Reconnect | Enabled | Restores the drive automatically after network interruptions or restarts |

| Department | Drive Letter | UNC Path | Label |
|------------|-------------|----------|-------|
| Finance | F: | `\\DC-01\Finance` | Finance |
| HR | H: | `\\DC-01\HR` | HR |
| IT | I: | `\\DC-01\IT` | IT |
| Sales | S: | `\\DC-01\Sales` | Sales |

> The **Replace** action was chosen over **Create** to ensure the drive is always in the correct state, even if a user previously had a conflicting mapping or the drive letter was reassigned.

📸 **Drive mapping configuration – Finance**

![Drive Mapping Configuration](/screenshots/07/04.png)

---

## 6️⃣ Configure Item-Level Targeting

Each drive mapping uses **Item-Level Targeting** to ensure users only receive the drives they are authorized to access, based on their Global Group membership rather than solely on OU placement.

For each drive mapping, open the **Common** tab → **Item-Level Targeting** → **Targeting** and configure a Security Group condition:

| Drive | Targeting Condition |
|-------|-------------------|
| F: (Finance) | Member of `GG-Finance-Users` **OR** `GG-Finance-Managers` |
| H: (HR) | Member of `GG-HR-Users` **OR** `GG-HR-Managers` |
| I: (IT) | Member of `GG-IT-Users` **OR** `GG-IT-Managers` |
| S: (Sales) | Member of `GG-Sales-Users` **OR** `GG-Sales-Managers` |

📸 **Item-Level Targeting configuration**

![Item Level Targeting](/screenshots/07/05.png)

---

## 🔎 Validation

Validation was performed from **WS-01** after running `gpupdate /force`.

### Drive Mapping

Confirm that the mapped drive appears in File Explorer for the logged-in user and corresponds to the correct department.

```powershell
gpupdate /force
gpresult /r
```

📸 **Mapped drive visible in File Explorer**

![Mapped Drive Finance](/screenshots/07/06.png)

### Access Control

Test cross-department access to confirm that NTFS permissions are correctly enforced:

- Finance standard user → Read-only access confirmed
- Finance manager → Modify permissions confirmed
- HR user attempting to access Finance share → Access Denied

📸 **Access Denied when a non-Finance user attempts to access the Finance share**

![Access Denied Test](/screenshots/07/07.png)

---

## ✅ Outcome

After completing this section:

- Departmental shared folders are created and properly segmented on DC-01.
- NTFS permissions enforce granular access control using Domain Local Groups.
- Share permissions are configured with Domain Local Groups and defer restriction to NTFS.
- Access-Based Enumeration prevents users from seeing shares they cannot access.
- Drive mappings are deployed automatically via Group Policy Preferences.
- Item-Level Targeting ensures each user only receives the drives they are authorized to access.
- Access control was validated end-to-end from WS-01.