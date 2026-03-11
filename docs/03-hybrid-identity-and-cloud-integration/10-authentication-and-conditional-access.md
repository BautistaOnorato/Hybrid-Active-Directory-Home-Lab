# 10 - Authentication and Conditional Access  

---

## 🎯 Objective

Modernize authentication and implement security controls in Microsoft Entra ID to:

- Enforce Multi-Factor Authentication (MFA) using Microsoft Authenticator
- Block legacy authentication protocols
- Apply Conditional Access policies across the organization

This phase establishes a Zero Trust–aligned authentication baseline for cloud access.

---

## 🔐 1. Multi-Factor Authentication (MFA) Configuration

---

### 1.1 Enable Microsoft Authenticator

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Security → Authentication methods
```

Select:

```
Microsoft Authenticator
```

Configuration:

- Enable → Yes  
- Target → All users  
- Authentication mode:
  - ✔ Push notifications
  - ✔ One-time passcode (OTP)

Save configuration.

📸 **Microsoft Authenticator Policy**

![Microsoft Authenticator Policy](/screenshots/10/01.png)

---

### 1.2 Enable Registration Campaign

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Security → Authentication methods → Registration campaign
```

Configuration:

- State → Enabled  
- Target → All users  
- Authentication method → Microsoft Authenticator  
- Snooze duration → 1 day  

This ensures users are prompted to register MFA upon next sign-in.

📸 **Registration Campaign**

![Registration Campaign](/screenshots/10/02.png)

---

## 🛡 2. Conditional Access – Global MFA Policy

---

### 2.1 Create MFA Enforcement Policy

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Security → Conditional Access → New policy
```

Policy Name:

```
CA-Require-MFA-All-Users
```

---

#### Assignments

**Users**

- Include → All users  
- Exclude → BautistaOnorato@BautistaOnorato.onmicrosoft.com (emergency access account)

**Target resources**

- All cloud apps  

**Conditions**

- No additional conditions configured  

**Grant**

- Grant access  
- ✔ Require multi-factor authentication  

**Enable**

- Initially configured as Report-only  
- After validation, switched to On  

---

## 🚫 3. Conditional Access – Block Legacy Authentication

Legacy authentication protocols (IMAP, POP, SMTP basic auth, etc.) do not support MFA and represent a major security risk.

---

### 3.1 Create Legacy Authentication Blocking Policy

Navigate to:

```
portal.azure.com → Microsoft Entra ID → Security → Conditional Access → New policy
```

Policy Name:

```
CA-Block-Legacy-Authentication
```

---

#### Assignments

**Users**

- Include → All users  
- Exclude → BautistaOnorato@BautistaOnorato.onmicrosoft.com (emergency access account)

**Target resources**

- All cloud apps  

**Conditions**

- Client apps → Legacy authentication clients  

**Grant**

- Block access  

**Enable**

- On  

📸 **Conditional Access Policies**

![CA Policies](/screenshots/10/03.png)

---

## 🔎 4. Validation and Testing

---

### 4.1 MFA Validation

Test performed:

1. Sign in to:
   ```
   https://m365.cloud.microsoft/
   ```
2. Enter credentials  
3. Approve push notification in Microsoft Authenticator  

Result:

- Access granted only after MFA verification  

---

### 4.2 Legacy Authentication Test

Attempted login using a legacy protocol.

Result:

- Access blocked  

Verified via:

```
portal.azure.com → Microsoft Entra ID → Security → Conditional Access → Sign-in logs
```

---

## ✅ Outcome

After this implementation:

- MFA enforced across all cloud applications  
- Legacy authentication fully blocked  
- Centralized policy enforcement via Conditional Access  
- Zero Trust authentication baseline established  
