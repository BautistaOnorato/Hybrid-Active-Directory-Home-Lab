# 05 - DHCP Configuration

---

## 🎯 Objective

Deploy and configure a DHCP Server on DC-01 to:

- Automatically assign IP addresses to domain workstations
- Provide correct DNS and gateway configuration
- Integrate with Active Directory
- Enable dynamic DNS registration
- Prepare the network layer for domain-joined clients

This phase establishes automated network configuration for the Bocorp lab environment.

---

## 1. DHCP Role Installation

The DHCP Server role was installed on **DC-01** using Server Manager.

### Installation Steps

1. Open **Server Manager**
2. Select **Add Roles and Features**
3. Choose **Role-based or feature-based installation**
4. Select **DHCP Server**
5. Complete the wizard and install

After installation, the DHCP service was configured and authorized in Active Directory.

📸 **DHCP Role Installation Summary**

![DHCP Role Installation Summary](/screenshots/05/01.png)

---

## 2. DHCP Authorization in Active Directory

In a domain environment, DHCP servers must be authorized in Active Directory.

This prevents rogue DHCP servers from distributing IP addresses inside the domain.

### Authorization Process

- Open **DHCP Management Console**
- Right-click the server
- Select **Authorize**
- Refresh to confirm status is **Authorized**

This ensures only trusted servers can provide IP configuration within the domain.

---

## 3. Scope Configuration

A new IPv4 scope was created with the following configuration:

### Scope Name
```
Bocorp WS Scope
```

### IP Address Range
```
Start IP: 10.10.10.100
End IP:   10.10.10.200
```

### Subnet Mask
```
255.255.255.0
```

### Option 003 – Router (Default Gateway)
```
10.10.10.1
```

### Option 006 – DNS Servers
```
10.10.10.10 (DC-01)
```

### Option 015 – DNS Domain Name
```
bocorp.local
```
---

## 4. Lease Duration

Lease duration was configured to:

```
1 day
```

Using a shorter lease duration in a lab environment allows:

- Easier testing
- Faster renewal validation
- Quick scope adjustments if needed

📸 **DHCP Scope and Lease configuration**

![DHCP Scope and Lease configuration](/screenshots/05/02.png)

---

## 6. Validation

After configuration, both workstations were checked to validate that the DHCP server was functioning correctly:

1. Both workstations were set to obtain IP addresses automatically.
2. Ran ```ipconfig /release``` followed by ```ipconfig /renew```.
3. Verified that each client received an IP address from the DHCP scope.

📸 **WS-01 Validation**

![WS-01 Validation](/screenshots/05/03.png)
![WS-01 Validation](/screenshots/05/04.png)

📸 **WS-02 Validation**

![WS-02 Validation](/screenshots/05/05.png)
![WS-02 Validation](/screenshots/05/06.png)

📸 **DHCP Address Leases Showing Both Clients**

![DHCP Address Leases Showing Both Clients](/screenshots/05/07.png)

---

## ✅ Outcome

After completing this configuration:

- DC-01 provides centralized IP management.
- Workstations automatically receive valid network configuration.
- DNS and Active Directory integration is fully operational.