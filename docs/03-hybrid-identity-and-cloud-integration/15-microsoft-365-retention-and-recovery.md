# 15 – Microsoft 365 Retention and Recovery

---

## 🎯 Objective

Implement and validate Microsoft 365 retention and recovery mechanisms to simulate real-world enterprise data protection and compliance workflows.

This section covers:

- Configuring a retention policy in Microsoft Purview for Exchange mailboxes and OneDrive accounts
- Simulating permanent deletion of an email by a user
- Recovering the deleted email using eDiscovery
- Simulating permanent deletion of a OneDrive file by a user
- Recovering the deleted file using eDiscovery
- Validating that users cannot permanently destroy retention-protected content

---

## 🏗 Architecture Overview

```
User deletes item (email or file)
        ↓
Deleted from mailbox / OneDrive Recycle Bin
        ↓
Permanently deleted by user
        ↓
Item preserved in hidden compliance storage
(Retention Policy: RP-Exchange-5Years)
        ↓
Administrator creates eDiscovery case
        ↓
Search → Export → Restore
```

### Retention Policy Scope

| Setting | Value |
|---------|-------|
| Policy Name | `RP-Exchange-5Years` |
| Applies to | Exchange mailboxes, OneDrive accounts |
| Retain items for | 5 years |
| Action after retention period | Retain only (no automatic deletion) |

The retention policy overrides user deletion behavior by moving deleted items into a hidden preservation location. Users cannot access, bypass, or permanently destroy protected content during the retention window. Recovery requires administrator access through eDiscovery.

---

## 1️⃣ Configure Retention Policy

Navigate to the Microsoft Purview compliance portal:

```
Microsoft Purview → Data Lifecycle Management → Retention policies → New retention policy
```

Configure the policy with the following settings:

| Setting | Value |
|---------|-------|
| Name | `RP-Exchange-5Years` |
| Locations | Exchange mailboxes, OneDrive accounts |
| Retain items for | 5 years |
| Action after retention period | Do nothing (retain only) |

📸 **Retention policy configured in Microsoft Purview**

![Retention Policy](/screenshots/15/01.png)

---

## 2️⃣ Exchange Online – Deleted Email Recovery

### 2.1 Simulate Permanent Deletion

The following deletion chain was executed on the `fernandaortega@bocorp.online` mailbox to simulate a user permanently destroying an email:

1. A test email with subject **Test Retention Policy** was sent to `fernandaortega@bocorp.online`
2. Email deleted from **Inbox**
3. Email removed from **Deleted Items**
4. Email removed from **Recover Deleted Items**

At this point the email is permanently deleted from the user's perspective. The item remains preserved in the hidden compliance storage due to the active retention policy.

---

### 2.2 Create eDiscovery Case

Navigate to:

```
Microsoft Purview → eDiscovery → Cases → Create a case
```

| Setting | Value |
|---------|-------|
| Case name | `Bocorp-Retention-Test` |

---

### 2.3 Search for the Deleted Email

Inside the case, create a new search:

```
Bocorp-Retention-Test → Searches → New search
```

| Setting | Value |
|---------|-------|
| Search name | `Search-Deleted-Mail` |
| Data source | `fernandaortega@bocorp.online` |
| Scope | Mailboxes, SharePoint sites, OneDrive accounts |
| Query | `(SubjectTitle:"Test Retention Policy")` |

Run the search and confirm the deleted email appears in the results.

📸 **Search-Deleted-Mail results and statistics**

![Search-Deleted-Mail statistics](/screenshots/15/02.png)

---

### 2.4 Export and Restore

Export the search results from the eDiscovery case:

```
Search-Deleted-Mail → Actions → Export results
```

Download the export package and import the `.pst` file into Outlook (Classic) to restore the email.

📸 **Export package downloaded**

![Export package](/screenshots/15/03.png)

📸 **Deleted email restored in Outlook**

![Restored Email in Outlook](/screenshots/15/04.png)

---

## 3️⃣ OneDrive – Deleted File Recovery

### 3.1 Simulate Permanent Deletion

The following deletion chain was executed on the `fernandaortega@bocorp.online` OneDrive account:

1. A test file named **ExcelFileTest.xlsx** was created in OneDrive
2. File moved to the **Recycle Bin**
3. File permanently deleted from the **Recycle Bin**

At this point the file is permanently deleted from the user's perspective. The item remains preserved in the Preservation Hold Library due to the active retention policy.

---

### 3.2 Search for the Deleted File

Inside the existing eDiscovery case `Bocorp-Retention-Test`, create a new search:

```
Bocorp-Retention-Test → Searches → New search
```

| Setting | Value |
|---------|-------|
| Search name | `Search-Deleted-File` |
| Data source | `fernandaortega@bocorp.online` |
| Scope | Mailboxes, SharePoint sites, OneDrive accounts |
| Query | `(ExcelFileTest)` |

Run the search and confirm the deleted file appears in the results.

📸 **Search-Deleted-File results and statistics**

![Search-Deleted-File statistics](/screenshots/15/05.png)

---

### 3.3 Export and Restore

Export the search results from the eDiscovery case:

```
Search-Deleted-File → Actions → Export results
```

Download the export package and restore the file back to OneDrive.

📸 **Export package downloaded**

![Export package](/screenshots/15/06.png)

📸 **Deleted file restored in OneDrive**

![Restored File in OneDrive](/screenshots/15/07.png)

---

## ✅ Outcome

After completing this section:

- `RP-Exchange-5Years` enforces a 5-year retention policy across Exchange mailboxes and OneDrive accounts.
- Permanently deleted emails remain preserved and are recoverable through eDiscovery.
- Permanently deleted OneDrive files remain preserved in the Preservation Hold Library and are recoverable through eDiscovery.
- Users cannot bypass or permanently destroy retention-protected content during the retention window.
- Compliance-grade export and restoration workflows were validated end-to-end for both email and file recovery.