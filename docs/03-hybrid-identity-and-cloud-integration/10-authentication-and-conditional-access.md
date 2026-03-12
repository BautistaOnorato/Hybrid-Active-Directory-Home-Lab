# 10 – Authentication and Conditional Access

---

## 🎯 Objective

Modernize authentication and implement Conditional Access policies in Microsoft Entra ID to enforce a Zero Trust security baseline across all cloud applications.

This section covers:

- Enabling Microsoft Authenticator as the MFA method for all users
- Configuring a Registration Campaign to prompt users to enroll
- Creating a Conditional Access policy to enforce MFA on all cloud apps
- Creating a Conditional Access policy to block legacy authentication protocols
- Validating MFA enforcement and legacy authentication blocking

---

## 🏗 Architecture Overview

```
User Sign-In Attempt
        ↓
Conditional Access Engine
        ↓
CA-Require-MFA-All-Users        CA-Block-Legacy-Authentication
(All cloud apps → Require MFA)  (Legacy clients → Block access)
        ↓                               ↓
Microsoft Authenticator          Access Denied
Push / OTP
        ↓
Access Granted
```

### Why Block Legacy Authentication?

Legacy authentication protocols such as IMAP, POP3, SMTP Basic Auth, and older Office clients do not support MFA. Any account accessible via a legacy protocol is effectively MFA-bypassed, regardless of any Conditional Access policies targeting modern authentication flows. Blocking legacy authentication is a prerequisite for a complete Zero Trust authentication baseline.

---

## 1️⃣ Configure Microsoft Authenticator

### 1.1 Enable Microsoft Authenticator

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Security → Authentication methods → Microsoft Authenticator
```

Configure the following settings:

| Setting | Value |
|---------|-------|
| Enable | Yes |
| Target | All users |
| Authentication mode | Push notifications + One-time passcode (OTP) |

Click **Save**.

📸 **Microsoft Authenticator policy configured**

![Microsoft Authenticator Policy](/screenshots/10/01.png)

---

### 1.2 Enable Registration Campaign

A Registration Campaign prompts users to enroll in Microsoft Authenticator at their next sign-in, without requiring administrator intervention per user.

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Security → Authentication methods → Registration campaign
```

Configure the following settings:

| Setting | Value |
|---------|-------|
| State | Enabled |
| Target | All users |
| Authentication method | Microsoft Authenticator |
| Snooze duration | 1 day |

Click **Save**.

📸 **Registration Campaign configured**

![Registration Campaign](/screenshots/10/02.png)

---

## 2️⃣ Create Conditional Access Policy – Enforce MFA

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Security → Conditional Access → New policy
```

**Policy Name:** `CA-Require-MFA-All-Users`

Configure the policy with the following settings:

| Section | Setting | Value |
|---------|---------|-------|
| Users | Include | All users |
| Users | Exclude | `BautistaOnorato@BautistaOnorato.onmicrosoft.com` (emergency access account) |
| Target resources | Include | All cloud apps |
| Grant | Access control | Grant access – Require multi-factor authentication |
| Enable policy | State | On |

> The emergency access account is excluded to prevent a complete lockout if MFA becomes unavailable or misconfigured. This account should be stored securely and used only in break-glass scenarios.

---

## 3️⃣ Create Conditional Access Policy – Block Legacy Authentication

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Security → Conditional Access → New policy
```

**Policy Name:** `CA-Block-Legacy-Authentication`

Configure the policy with the following settings:

| Section | Setting | Value |
|---------|---------|-------|
| Users | Include | All users |
| Users | Exclude | `BautistaOnorato@BautistaOnorato.onmicrosoft.com` (emergency access account) |
| Target resources | Include | All cloud apps |
| Conditions | Client apps | Legacy authentication clients |
| Grant | Access control | Block access |
| Enable policy | State | On |

📸 **Conditional Access policies overview**

![CA Policies](/screenshots/10/03.png)

---

## 🔎 Validation

### Validate MFA Enforcement

From a browser, sign in to Microsoft 365:

```
https://m365.cloud.microsoft
```

Enter valid user credentials and confirm that the sign-in flow prompts for MFA approval via Microsoft Authenticator. Access should only be granted after the push notification is approved or the OTP is entered.

---

### Validate Legacy Authentication Blocking

Attempt to authenticate using a legacy protocol client. Confirm that access is denied.

Verify the block in the Entra ID sign-in logs:

```
portal.azure.com → Microsoft Entra ID → Security → Conditional Access → Sign-in logs
```

Filter by the test account and confirm the sign-in was blocked by `CA-Block-Legacy-Authentication`.

---

## ✅ Outcome

After completing this section:

- Microsoft Authenticator is enabled as the MFA method for all users.
- A Registration Campaign prompts unenrolled users to set up MFA at their next sign-in.
- `CA-Require-MFA-All-Users` enforces MFA across all cloud applications.
- `CA-Block-Legacy-Authentication` blocks all legacy authentication protocol sign-in attempts.
- A Zero Trust authentication baseline is established for the `bocorp.online` tenant.