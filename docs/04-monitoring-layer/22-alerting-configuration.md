# 22 – Alerting Configuration

---

## 🎯 Objective

Configure a fully operational alerting pipeline in Zabbix to ensure that infrastructure problems are detected and communicated in real time.

This section covers:

- Creating a dedicated shared mailbox for alert delivery
- Registering an Azure App Registration for OAuth 2.0 authentication
- Configuring a custom Webhook Media Type using Microsoft Graph API
- Assigning alert media to the Zabbix administrator
- Creating a Trigger Action to define alerting logic
- Configuring message templates for problem and recovery notifications
- Validating the full alerting chain with a failure simulation

---

## 🏗 Architecture Overview

The alerting pipeline implemented in this lab:

```
Zabbix Trigger (problem detected)
        ↓
Trigger Action (Notify Admin on Problem)
        ↓
Media Type: Microsoft 365 OAuth (Webhook)
        ↓
Azure App Registration (OAuth 2.0 – Client Credentials)
        ↓
Microsoft Graph API (/sendMail)
        ↓
zabbix-alerts@bocorp.online (Shared Mailbox)
```

This architecture avoids legacy SMTP authentication, which Microsoft has disabled in modern Exchange Online tenants, and instead uses OAuth 2.0 with application permissions — the recommended and secure approach for automated mail delivery in Microsoft 365 environments.

---

## 1. Create Zabbix Alerts Shared Mailbox

A dedicated shared mailbox was created in Microsoft 365 to receive all Zabbix alert notifications.

Using a shared mailbox instead of a personal account ensures:

- Alert history is centralized and accessible to multiple administrators
- No dependency on individual user accounts
- Consistent with enterprise operational practices

### Configuration

Navigate to:

```
Microsoft 365 Admin Center → Teams & Groups → Shared mailboxes → Add a shared mailbox
```

| Field | Value |
|-------|-------|
| Name | Zabbix Shared Mailbox |
| Email | zabbix-alerts@bocorp.online |

📸 **Zabbix Shared Mailbox created**

![Zabbix Shared Mailbox](/screenshots/22/00.png)

---

## 2. Register an Azure App Registration

Zabbix requires an application identity in Microsoft Entra ID to authenticate against Microsoft Graph API and send emails on behalf of the shared mailbox.

Navigate to:

```
portal.azure.com → Microsoft Entra ID → App registrations → New registration
```

| Field | Value |
|-------|-------|
| Name | Zabbix-MailSender |
| Supported account types | Accounts in this organizational directory only |
| Redirect URI | Leave blank |

Click **Register**.

After creation, copy and save the following values from the **Overview** page:

```
Application (client) ID
Directory (tenant) ID
```

📸 **Zabbix-MailSender Overview**

![Zabbix-MailSender Overview](/screenshots/22/01.png)

---

## 2.1 Create a Client Secret

Navigate to:

```
Certificates & secrets → Client secrets → New client secret
```

| Field | Value |
|-------|-------|
| Description | Zabbix |
| Expires | 24 months |

Click **Add**.

Copy the secret **Value** immediately — Azure does not display it again after leaving the page.

📸 **Zabbix-MailSender Certificates & secrets**

![Zabbix-MailSender Certificates & secrets](/screenshots/22/02.png)

---

## 2.2 Assign API Permissions

Navigate to:

```
API permissions → Add a permission → Microsoft Graph → Application permissions
```

Search for and select:

```
Mail.Send
```

Click **Add permissions**.

Then grant admin consent:

```
Grant admin consent for bocorp → Yes
```

This step is mandatory. Without it, the permission remains in a pending state and the Graph API will reject all requests.

📸 **API permissions showing Mail.Send granted**

![API Permissions](/screenshots/22/03.png)

---

## 3. Configure Media Type in Zabbix

Zabbix was configured with a custom Webhook Media Type that authenticates via OAuth 2.0 and delivers notifications through Microsoft Graph API.

Navigate to:

```
Alerts → Media types → Create media type
```

### Tab: Media type

| Field | Value |
|-------|-------|
| Name | Microsoft 365 OAuth |
| Type | Webhook |

### Parameters

| Name | Value |
|------|-------|
| client_id | (Application ID) |
| client_secret | (Client Secret) |
| tenant_id | (Directory/Tenant ID) |
| from_address | zabbix-alerts@bocorp.online |
| to | {ALERT.SENDTO} |
| subject | {ALERT.SUBJECT} |
| message | {ALERT.MESSAGE} |

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

📸 **Media Type Parameters and Settings**

![Media Type Parameters and Settings](/screenshots/22/04.png)

---

## 3.1 Configure Message Templates

Navigate to the **Message templates** tab and add the following three templates:

### Problem

| Field | Value |
|-------|-------|
| Message type | Problem |
| Subject | Problem: {EVENT.NAME} |
| Message | Host: {HOST.NAME}\nSeverity: {EVENT.SEVERITY}\nProblem: {EVENT.NAME}\nTime: {EVENT.TIME} {EVENT.DATE} |

### Problem recovery

| Field | Value |
|-------|-------|
| Message type | Problem recovery |
| Subject | Resolved: {EVENT.NAME} |
| Message | Host: {HOST.NAME}\nSeverity: {EVENT.SEVERITY}\nProblem resolved: {EVENT.NAME}\nResolution time: {EVENT.RECOVERY.TIME} {EVENT.RECOVERY.DATE} |

### Problem update

| Field | Value |
|-------|-------|
| Message type | Problem update |
| Subject | Updated: {EVENT.NAME} |
| Message | Host: {HOST.NAME}\nSeverity: {EVENT.SEVERITY}\nProblem: {EVENT.NAME}\nUpdate: {USER.FULLNAME} {EVENT.UPDATE.MESSAGE} |

Click **Update**.

📸 **Message templates configured**

![Message Templates](/screenshots/22/05.png)

---

## 3.2 Test the Media Type

At the bottom of the Media Type page, click **Test**.

Complete the test form.

📸 **Media type test parameters**

![Media type test parameter](/screenshots/22/06.png)


Click **Test**. A confirmation email should arrive at the shared mailbox within seconds.

📸 **Media type test successful**

![Media Type Test](/screenshots/22/07.png)

---

## 4. Assign Media to the Admin User

Configuring the media type makes the delivery channel available — the user media assignment defines who receives the notifications through it.

Navigate to:

```
Users → Users → Admin → Tab: Media → Add
```

| Field | Value |
|-------|-------|
| Type | Microsoft 365 OAuth |
| Send to | zabbix-alerts@bocorp.online |
| When active | 1-7,00:00-24:00 |
| Use if severity | ✔ Warning, Average, High, Disaster |

Click **Add** → **Update**.

📸 **User media Settings**

![User Media](/screenshots/22/08.png)

---

## 5. Create Trigger Action

Actions define the alerting logic: when a trigger fires, send a notification to the configured user.

Navigate to:

```
Alerts → Actions → Trigger actions → Create action
```

### Tab: Action

| Field | Value |
|-------|-------|
| Name | Notify Admin on Problem |
| Enabled | ✔ |

**Conditions:**

| Condition | Value |
|-----------|-------|
| Trigger severity | ≥ Warning |
| Host group | Bocorp |

---

### Tab: Operations

**Operations — Add:**

| Field | Value |
|-------|-------|
| Send to users | Admin |
| Send only to | Microsoft 365 OAuth |

**Recovery operations — Add:**

| Field | Value |
|-------|-------|
| Send to users | Admin |
| Send only to | Microsoft 365 OAuth |

Click **Update**.

📸 **Action configuration – Action tab**

![Action Tab](/screenshots/22/09.png)

📸 **Action configuration – Operations tab**

![Operations Tab](/screenshots/22/10.png)

---

## 6. Validation – Failure Simulation

The full alerting chain was validated by simulating an agent failure on DC-01.

### Trigger the failure

On **DC-01**, open PowerShell:

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

### Restore the agent

```powershell
Start-Service -Name "Zabbix Agent 2"
```

After the next polling cycle, the problem resolved in Zabbix and a **Recovery** notification email was delivered to the shared mailbox.

📸 **Recovery email received**

![Recovery Email](/screenshots/22/12.png)

---

### Action log validation

Navigate to:

```
Reports → Action log
```

Confirmed all entries for **Notify Admin on Problem** show:

```
Status: Sent
```

📸 **Action log showing Sent status**

![Action Log](/screenshots/22/13.png)

---

## ✅ Outcome

After completing this section:

- A dedicated shared mailbox centralizes all Zabbix alert notifications.
- An Azure App Registration provides secure OAuth 2.0 authentication.
- A custom Webhook Media Type delivers notifications via Microsoft Graph API.
- Message templates are configured for problem, recovery, and update events.
- The Trigger Action fires on Warning severity and above across all Bocorp lab hosts.
- Both problem and recovery notifications were validated end-to-end.
- The Action log confirms successful delivery of all alert messages.