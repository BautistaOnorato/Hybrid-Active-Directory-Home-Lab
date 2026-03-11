# 15 - Microsoft 365 Retention and Recovery

---

## 🎯 Objective

Implement and validate Microsoft 365 retention and recovery mechanisms to simulate real-world enterprise data protection and compliance workflows.

This section demonstrates:

- Retention policy enforcement in Exchange Online
- Protection against permanent deletion by users
- eDiscovery-based recovery for email and OneDrive files
- Legal/compliance-grade data restoration procedures

The goal is to validate that users cannot permanently destroy protected data and that administrators can recover it using compliance tools.

---

## 1️⃣ Retention Policy Configuration

Retention policies were configured using the Microsoft Purview compliance portal.

📍 Portal Used:  
**Microsoft Purview – Data Lifecycle Management**

---

### 1.1 Retention Policy Created

**Policy Name:**

```
RP-Exchange-5Years
```

### Scope

The policy was configured to apply to:

- Exchange mailboxes
- OneDrive accounts

### Retention Settings

- Retain items for: **5 years**
- Deletion after retention: Not configured (retain only)

---

### 🔎 Purpose

This policy ensures that:

- Emails cannot be permanently destroyed by end users
- Files deleted from OneDrive remain recoverable
- Compliance and legal investigations can retrieve historical data
- Insider threats or accidental deletion cannot remove protected content

📸 **Retention Policy**

![Retention Policy](/screenshots/15/01.png)

---

## 2️⃣ Exchange Online Retention Validation

---

### 2.1 Test Scenario – Deleted Email Recovery

A test email was sent to:

```
fernandaortega@bocorp.online
```

**Subject:** Test Retention Policy

---

### Deletion Process Simulated

The following deletion chain was executed:

1. Email deleted from Inbox  
2. Email removed from **Deleted Items**
3. Email removed from **Recover Deleted Items**

At this stage, the email was permanently deleted from the user’s perspective.

However, due to the active retention policy, the item was preserved in the hidden compliance storage.

---

## 3️⃣ eDiscovery Case Creation

To simulate enterprise legal recovery, the email was restored using eDiscovery.

📍 Portal Used:  
**Microsoft Purview → eDiscovery**

---

### 3.1 Case Created

**Case Name:**

```
Bocorp-Retention-Test
```


---

## 4️⃣ Search – Deleted Mail Recovery

---

### 4.1 Search Configuration

**Search Name:**

```
Search-Deleted-Mail
```

**Query Used:**

```
(SubjectTitle="Test Retention Policy")
```

**Data Source**

```
fernandaortega@bocorp.online
```

Scope included:

- Mailboxes
- SharePoint sites
- OneDrive accounts

---

### 4.2 Execution

- Query executed successfully
- Deleted email appeared in search results
- Retention policy confirmed functional

📸 **Search-Deleted-Mail statistics**

![Search-Deleted-Mail statistics](/screenshots/15/02.png)

---

### 4.3 Export & Restore

1. Results exported from eDiscovery
2. Export package downloaded
3. Mail restored into Outlook (Classic)

📸 **Export package**

![Export package](/screenshots/15/03.png)

📸 **Restored Email in Outlook**

![Restored Email in Outlook](/screenshots/15/04.png)

---

### ✅ Validation Result

Even after permanent deletion by the user, the email:

- Remained preserved
- Was searchable
- Was exportable
- Was restorable

This confirms retention enforcement at the compliance layer.

---

## 5️⃣ OneDrive Retention Validation

---

### 5.1 Test Scenario – Deleted File Recovery

Inside the OneDrive account of:

```
fernandaortega@bocorp.onlie
```

An Excel file was created:

```
ExcelFileTest.xlsx
```


---

### Deletion Process Simulated

1. File moved to Recycle Bin
2. File permanently deleted from Recycle Bin

From the user perspective, the file no longer existed.

However, due to the active retention policy, the file was preserved in the Preservation Hold Library.

---

## 6️⃣ Search – Deleted File Recovery

---

### 6.1 Search Configuration

**Search Name:**

```
Search-Deleted-File
```

**Query Used:**

```
((ExcelFileTest))
```

**Data Source**

```
fernandaortega@bocorp.online
```


Scope included:

- Mailboxes
- SharePoint sites
- OneDrive accounts

---

### 6.2 Execution

- Query executed successfully
- Deleted Excel file appeared in results
- File confirmed preserved despite permanent deletion

📸 **Search-Deleted-File statistics**

![Search-Deleted-File statistics](/screenshots/15/05.png)

---

### 6.3 Export & Restore

1. Results exported from eDiscovery
2. Export package downloaded
3. File restored into OneDrive

📸 **Export package**

![Export package](/screenshots/15/06.png)

📸 **Restored File in OneDrive**

![Restored File in OneDrive](/screenshots/15/07.png)

---

### ✅ Validation Result

The OneDrive file:

- Could not be permanently destroyed by the user
- Remained indexed and searchable
- Was exportable through compliance tools
- Was successfully restored

---

## 🔐 Architectural Behavior Observed

The retention policy overrides user deletion behavior by:

- Moving deleted items into a hidden preservation location
- Preventing physical destruction during retention window
- Allowing compliance search and export only

Users:
- Cannot access preserved copies
- Cannot bypass retention
- Cannot permanently destroy protected data

Administrators:
- Must use eDiscovery for recovery

---

## ✅ Outcome

By completing this section:

- A 5-year retention policy is enforced
- Email recovery via eDiscovery was validated
- OneDrive file recovery via eDiscovery was validated
- Permanent deletion attempts were successfully mitigated
- Compliance-grade export and restoration workflows were executed

The environment now includes enterprise-level data protection and retention controls.
