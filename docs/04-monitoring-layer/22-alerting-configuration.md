# 22 – Alerting Configuration

---

## 🎯 Objective

Configure a fully operational alerting pipeline in Zabbix to ensure that infrastructure problems are detected and communicated in real time.

This section covers:

- Creating a dedicated shared mailbox for alert delivery
- Registering an Azure App Registration for OAuth 2.0 authentication
- Configuring a custom Webhook Media Type using Microsoft Graph API
- Configuring message templates for problem, recovery, and update events
- Assigning the alert media to the Zabbix administrator user
- Creating a Trigger Action to define the alerting logic
- Validating the full alerting pipeline with a failure simulation

---

## 🏗 Architecture Overview

```
Zabbix Trigger (problem detected)
        ↓
Trigger Action (Notify Admin on Problem)
        ↓
Media Type: Microsoft 365 OAuth (Webhook)
        ↓
Azure App Registration – Zabbix-MailSender
(OAuth 2.0 Client Credentials)
        ↓
Microsoft Graph API (/sendMail)
        ↓
zabbix-alerts@bocorp.online (Shared Mailbox)
```

### Why OAuth 2.0 Instead of SMTP?

Microsoft has disabled Basic Authentication for SMTP in modern Exchange Online tenants. OAuth 2.0 with application permissions via Microsoft Graph API is the recommended and supported approach for automated mail delivery in Microsoft 365 environments.

| Component | Value |
|-----------|-------|
| Shared Mailbox | `zabbix-alerts@bocorp.online` |
| App Registration | `Zabbix-MailSender` |
| API Permission | `Mail.Send` (Application) |
| Graph API Endpoint | `https://graph.microsoft.com/v1.0/users/{from}/sendMail` |
| Token Endpoint | `https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token` |

---

## 1️⃣ Create the Zabbix Alerts Shared Mailbox

A dedicated shared mailbox was created in Microsoft 365 to receive all Zabbix alert notifications. Using a shared mailbox ensures alert history is centralized, accessible to multiple administrators, and not dependent on any individual user account.

Navigate to:

```
Microsoft 365 Admin Center → Teams & Groups → Shared mailboxes → Add a shared mailbox
```

| Field | Value |
|-------|-------|
| Name | Zabbix Shared Mailbox |
| Email | `zabbix-alerts@bocorp.online` |

📸 **Zabbix shared mailbox created**

![Zabbix Shared Mailbox](/screenshots/22/00.png)

---

## 2️⃣ Register an Azure App Registration

Zabbix requires an application identity in Microsoft Entra ID to authenticate against Microsoft Graph API and send emails on behalf of the shared mailbox.

Navigate to:

```
portal.azure.com → Microsoft Entra ID → App registrations → New registration
```

| Field | Value |
|-------|-------|
| Name | `Zabbix-MailSender` |
| Supported account types | Accounts in this organizational directory only |
| Redirect URI | Leave blank |

Click **Register**. After creation, copy and save the following values from the **Overview** page:

```
Application (client) ID
Directory (tenant) ID
```

📸 **Zabbix-MailSender app registration overview**

![Zabbix-MailSender Overview](/screenshots/22/01.png)

---

### 2.1 Create a Client Secret

Navigate to:

```
Zabbix-MailSender → Certificates & secrets → Client secrets → New client secret
```

| Field | Value |
|-------|-------|
| Description | Zabbix |
| Expires | 24 months |

Click **Add** and copy the secret **Value** immediately. Azure does not display it again after navigating away from the page.

📸 **Client secret created**

![Zabbix-MailSender Certificates & secrets](/screenshots/22/02.png)

---

### 2.2 Assign API Permissions

Navigate to:

```
Zabbix-MailSender → API permissions → Add a permission → Microsoft Graph → Application permissions
```

Search for and select:

```
Mail.Send
```

Click **Add permissions**, then grant admin consent:

```
Grant admin consent for bocorp → Yes
```

> Admin consent is mandatory. Without it, the `Mail.Send` permission remains in a pending state and the Graph API will reject all requests with an authorization error.

📸 **API permissions showing Mail.Send granted with admin consent**

![API Permissions](/screenshots/22/03.png)

---

## 3️⃣ Configure the Webhook Media Type

Navigate to:

```
Alerts → Media types → Create media type
```

### Media Type Settings

| Field | Value |
|-------|-------|
| Name | `Microsoft 365 OAuth` |
| Type | Webhook |

### Parameters

| Name | Value |
|------|-------|
| `client_id` | (Application client ID) |
| `client_secret` | (Client secret value) |
| `tenant_id` | (Directory tenant ID) |
| `from_address` | `zabbix-alerts@bocorp.online` |
| `to` | `{ALERT.SENDTO}` |
| `subject` | `{ALERT.SUBJECT}` |
| `message` | `{ALERT.MESSAGE}` |

### Script: [`zabbix-mediatype.js`](/scripts/zabbix-mediatype.js)

```javascript
var params = JSON.parse(value);

var client_id = params.client_id;
var client_secret = params.client_secret;
var tenant_id = params.tenant_id;
var from_address = params.from_address;
var to = params.to;
var subject = params.subject;
var message = params.message;

if (!to || to === '{ALERT.SENDTO}') {
    throw 'Recipient address is empty or not resolved.';
}

var tokenRequest = new HttpRequest();
tokenRequest.addHeader('Content-Type: application/x-www-form-urlencoded');

var tokenBody = 'client_id=' + encodeURIComponent(client_id) +
    '&client_secret=' + encodeURIComponent(client_secret) +
    '&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default' +
    '&grant_type=client_credentials';

var tokenResponse = tokenRequest.post(
    'https://login.microsoftonline.com/' + tenant_id + '/oauth2/v2.0/token',
    tokenBody
);

var tokenData = JSON.parse(tokenResponse);
var token = tokenData.access_token;

if (!token) {
    throw 'Failed to obtain access token. Response: ' + tokenResponse;
}

var mailRequest = new HttpRequest();
mailRequest.addHeader('Content-Type: application/json');
mailRequest.addHeader('Authorization: Bearer ' + token);

var mailBody = JSON.stringify({
    message: {
        subject: subject,
        body: {
            contentType: 'Text',
            content: message
        },
        toRecipients: [{
            emailAddress: {
                address: to
            }
        }]
    }
});

var mailResponse = mailRequest.post(
    'https://graph.microsoft.com/v1.0/users/' + from_address + '/sendMail',
    mailBody
);

return mailResponse ? mailResponse : 'OK';
```

Click **Update**.

📸 **Media type parameters and settings**

![Media Type Parameters and Settings](/screenshots/22/04.png)

---

## 4️⃣ Configure Message Templates

Navigate to the **Message templates** tab on the Media Type page and configure the following three templates:

### Problem

| Field | Value |
|-------|-------|
| Message type | Problem |
| Subject | `Problem: {EVENT.NAME}` |
| Message | `Host: {HOST.NAME}\nSeverity: {EVENT.SEVERITY}\nProblem: {EVENT.NAME}\nTime: {EVENT.TIME} {EVENT.DATE}` |

### Problem Recovery

| Field | Value |
|-------|-------|
| Message type | Problem recovery |
| Subject | `Resolved: {EVENT.NAME}` |
| Message | `Host: {HOST.NAME}\nSeverity: {EVENT.SEVERITY}\nProblem resolved: {EVENT.NAME}\nResolution time: {EVENT.RECOVERY.TIME} {EVENT.RECOVERY.DATE}` |

### Problem Update

| Field | Value |
|-------|-------|
| Message type | Problem update |
| Subject | `Updated: {EVENT.NAME}` |
| Message | `Host: {HOST.NAME}\nSeverity: {EVENT.SEVERITY}\nProblem: {EVENT.NAME}\nUpdate: {USER.FULLNAME} {EVENT.UPDATE.MESSAGE}` |

Click **Update**.

📸 **Message templates configured**

![Message Templates](/screenshots/22/05.png)

---

## 5️⃣ Test the Media Type

At the bottom of the Media Type page, click **Test** and fill in the test form with a recipient address and sample subject and message.

📸 **Media type test parameters**

![Media type test parameters](/screenshots/22/06.png)

Click **Test**. A confirmation email should arrive at the shared mailbox within seconds.

📸 **Media type test successful**

![Media Type Test](/screenshots/22/07.png)

---

## 6️⃣ Assign Media to the Admin User

Configuring the media type makes the delivery channel available globally. Assigning it to a user defines who receives notifications through it.

Navigate to:

```
Users → Users → Admin → Media → Add
```

| Field | Value |
|-------|-------|
| Type | `Microsoft 365 OAuth` |
| Send to | `zabbix-alerts@bocorp.online` |
| When active | `1-7,00:00-24:00` |
| Use if severity | Warning, Average, High, Disaster |

Click **Add** → **Update**.

📸 **User media settings**

![User Media](/screenshots/22/08.png)

---

## 7️⃣ Create Trigger Action

Actions define the alerting logic: when a trigger fires at or above the configured severity, send a notification to the configured user via the configured media type.

Navigate to:

```
Alerts → Actions → Trigger actions → Create action
```

### Tab: Action

| Field | Value |
|-------|-------|
| Name | `Notify Admin on Problem` |
| Enabled | ✔ |

**Conditions:**

| Condition | Value |
|-----------|-------|
| Trigger severity | ≥ Warning |
| Host group | `Bocorp` |

### Tab: Operations

**Operations:**

| Field | Value |
|-------|-------|
| Send to users | `Admin` |
| Send only to | `Microsoft 365 OAuth` |

**Recovery operations:**

| Field | Value |
|-------|-------|
| Send to users | `Admin` |
| Send only to | `Microsoft 365 OAuth` |

Click **Update**.

📸 **Action configuration – Action tab**

![Action Tab](/screenshots/22/09.png)

📸 **Action configuration – Operations tab**

![Operations Tab](/screenshots/22/10.png)

---

## 🔎 Validation – Failure Simulation

The full alerting pipeline was validated by simulating an agent failure on DC-01.

### Trigger the Failure

On **DC-01**, open PowerShell and stop the Zabbix Agent 2 service:

```powershell
Stop-Service -Name "Zabbix Agent 2"
```

After 3–5 minutes, the problem appeared in:

```
Monitoring → Problems
```

A **Problem** notification email was delivered to the shared mailbox.

📸 **Problem alert email received**

![Alert Email](/screenshots/22/11.png)

---

### Restore the Agent

```powershell
Start-Service -Name "Zabbix Agent 2"
```

After the next polling cycle, the problem resolved in Zabbix and a **Recovery** notification email was delivered to the shared mailbox.

📸 **Recovery email received**

![Recovery Email](/screenshots/22/12.png)

---

### Verify the Action Log

Navigate to:

```
Reports → Action log
```

Confirm all entries for `Notify Admin on Problem` show:

```
Status: Sent
```

📸 **Action log showing Sent status for all entries**

![Action Log](/screenshots/22/13.png)

---

## ✅ Outcome

After completing this section:

- `zabbix-alerts@bocorp.online` centralizes all Zabbix alert notifications in a dedicated shared mailbox.
- `Zabbix-MailSender` provides secure OAuth 2.0 authentication against Microsoft Graph API.
- The `Microsoft 365 OAuth` Webhook Media Type delivers notifications via the Graph API `/sendMail` endpoint.
- Message templates are configured for problem, recovery, and update events.
- `Notify Admin on Problem` triggers on Warning severity and above across all hosts in the `Bocorp` group.
- Both problem and recovery notifications were validated end-to-end through a controlled agent failure simulation.
- The Action log confirms successful delivery of all alert messages.