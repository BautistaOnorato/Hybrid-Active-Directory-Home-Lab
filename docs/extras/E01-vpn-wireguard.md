# E01 – WireGuard VPN

---

## 🎯 Objective

Deploy a WireGuard VPN gateway to enable secure remote access to the lab network from an external client, simulating a real-world enterprise remote access scenario.

This implementation provides:

- An encrypted tunnel between an external client and the lab network
- Access to internal resources (DC-01, file shares, DNS) from outside the lab
- A dedicated VPN gateway server with dual network interfaces
- A realistic simulation of remote access without relying on cloud services

---

## 🏗 Architecture Overview

The lab network (`10.10.10.0/24`) is isolated behind a NAT configured on the host machine. Virtual machines on the internal switch (`BOCORP-SW01`) can reach the internet through the host, but external devices have no direct path into the lab network.

To simulate remote access, a dedicated VPN gateway (**VPN-01**) was deployed with two network interfaces:

- **eth0** → connected to the internal lab network (`BOCORP-SW01`)
- **eth1** → connected to the external network (`External Switch`)

This dual-homed architecture allows VPN-01 to receive incoming VPN connections from the external network and route them into the lab, exactly as a VPN gateway would behave in a production environment.

### Why WireGuard?

Several VPN protocols were evaluated before selecting WireGuard:

| Protocol | Reason Discarded |
|----------|-----------------|
| PPTP | Obsolete — known cryptographic vulnerabilities |
| L2TP/IPSec | Ports 500 and 4500 occupied by Windows host system service |
| SSTP | Requires PKI infrastructure and certificate management |
| WireGuard | ✔ Modern, secure, simple, fully configurable UDP port |

### Why a Dedicated Server?

WireGuard was deployed on a dedicated **VPN-01** server rather than on the existing **MON-01** monitoring server to maintain role separation — a core enterprise design principle. Given the lab's physical resource constraints, VPN-01 and MON-01 are not intended to run simultaneously. Each server is brought up on demand depending on the scenario being tested.

### Architecture Diagram

```
WS-01 (192.168.1.100) – External Network
        |
        |  WireGuard Tunnel (UDP 51820)
        ▼
VPN-01 eth1 (192.168.1.39) – External Interface
VPN-01 eth0 (10.10.10.30)  – Internal Interface
        |
        |  IP Forwarding + NAT (iptables)
        ▼
Lab Network (10.10.10.0/24)
        |
        ▼
DC-01, File Shares, DNS
```

### Network Summary

| Component | Value |
|-----------|-------|
| Lab network | `10.10.10.0/24` |
| VPN tunnel network | `10.10.20.0/24` |
| VPN-01 internal IP | `10.10.10.30` |
| VPN-01 external IP | `192.168.1.39` (static) |
| VPN-01 tunnel IP | `10.10.20.1` |
| Client tunnel IP | `10.10.20.2` |
| WireGuard port | UDP `51820` |

---

## 1️⃣ VPN-01 Server Deployment

### 1.1 Virtual Machine Configuration

A new virtual machine was created in Hyper-V with the following settings:

| Setting | Value |
|---------|-------|
| VM Name | VPN-01 |
| Generation | Generation 2 |
| Startup Memory | 3072 MB |
| Dynamic Memory | Disabled |
| Virtual Disk | 20 GB (VHDX) |
| Network Adapter | BOCORP-SW01 |
| Installation Media | Debian 13.3.0 (Trixie) |

📸 **VPN-01 VM settings**

![VPN-01 VM Settings](/screenshots/E01/01.png)

---

### 1.2 Debian Installation

Debian 13 was installed with a minimal configuration:

| Setting | Value |
|---------|-------|
| Hostname | `VPN-01` |
| Domain | `bocorp.local` |
| Partitioning | Guided – use entire disk |
| Software selection | SSH Server, Standard System Utilities |

No graphical interface was installed to keep the server lightweight.

📸 **Debian installation – software selection**

![Debian Installation – Software Selection](/screenshots/E01/02.png)

---

### 1.3 Network Configuration

#### Static IP for eth0 (Internal Interface)

Edit `/etc/network/interfaces`:

```
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.10.10.30
    netmask 255.255.255.0
    gateway 10.10.10.1
    dns-nameservers 10.10.10.10
```

Apply the configuration:

```bash
systemctl restart networking
```

#### Add a Second Network Interface (External)

A second network adapter was added to VPN-01 in Hyper-V Manager:

```
VPN-01 → Settings → Add Hardware → Network Adapter → BOCORP-EXTERNAL-SW01 → Apply
```

📸 **Second network adapter added**

![Second Network Adapter Added](/screenshots/E01/03.png)

#### Static IP for eth1 (External Interface)

Add the following block to `/etc/network/interfaces`:

```
auto eth1
iface eth1 inet static
    address 192.168.1.39
    netmask 255.255.255.0
```

Apply the configuration:

```bash
systemctl restart networking
```

📸 **Network interfaces showing both eth0 and eth1**

![Network Interfaces](/screenshots/E01/04.png)

---

### 1.4 System Update

```bash
apt update && apt upgrade -y
```

---

## 2️⃣ WireGuard Installation

### 2.1 Install WireGuard

```bash
apt install wireguard -y
```

### 2.2 Install iptables

Required for the NAT rules used by WireGuard's `PostUp`/`PostDown` hooks:

```bash
apt install iptables -y
```

---

## 3️⃣ Key Generation

WireGuard uses asymmetric cryptography. Each peer (server and client) has its own private/public key pair. The public key is shared with the other peer — the private key never leaves the local machine.

### 3.1 Generate Server Keys

```bash
cd /etc/wireguard
wg genkey > server_private.key
wg pubkey < server_private.key > server_public.key
cat server_private.key
cat server_public.key
```

### 3.2 Generate Client Keys

```bash
wg genkey > client_private.key
wg pubkey < client_private.key > client_public.key
cat client_private.key
cat client_public.key
```

> The client keys are generated on VPN-01 for convenience and then transferred to the client during configuration. The client private key must be kept secret and must never be shared.

---

## 4️⃣ Enable IP Forwarding

IP forwarding allows VPN-01 to route traffic between the WireGuard tunnel interface (`wg0`) and the internal lab network interface (`eth0`).

Add the following line to `/etc/sysctl.conf`:

```
net.ipv4.ip_forward=1
```

Apply immediately:

```bash
sysctl -p
```

---

## 5️⃣ Server Configuration

Create `/etc/wireguard/wg0.conf`:

```ini
[Interface]
PrivateKey = <server_private_key>
Address = 10.10.20.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <client_public_key>
AllowedIPs = 10.10.20.2/32
```

### Configuration Explained

| Setting | Purpose |
|---------|---------|
| `Address` | IP assigned to the WireGuard tunnel interface on VPN-01 |
| `ListenPort` | UDP port WireGuard listens on |
| `PostUp` | Enables IP forwarding and NAT when the tunnel comes up |
| `PostDown` | Removes the iptables rules when the tunnel goes down |
| `[Peer] AllowedIPs` | Defines which tunnel IP the client is allowed to use |

---

## 6️⃣ Start the WireGuard Service

```bash
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
systemctl status wg-quick@wg0
```

📸 **WireGuard service active**

![WireGuard Service Active](/screenshots/E01/05.png)

Verify the interface and listening port:

```bash
wg show
```

📸 **wg show output**

![wg show output](/screenshots/E01/06.png)

---

## 7️⃣ Client Configuration (WS-01)

WS-01 was connected to the external network switch (`External Switch`) to simulate being outside the corporate network. With this configuration, WS-01 has no direct access to the lab network (`10.10.10.0/24`).

### 7.1 Install WireGuard on WS-01

Download and install WireGuard from the official site:

```
https://www.wireguard.com/install/
```

### 7.2 Configure the Tunnel

Open the WireGuard application and create a new tunnel:

```
Add Tunnel → Add empty tunnel
```

Configuration used:

```ini
[Interface]
PrivateKey = <client_private_key>
Address = 10.10.20.2/24
DNS = 10.10.10.10

[Peer]
PublicKey = <server_public_key>
AllowedIPs = 10.10.10.0/24, 10.10.20.0/24
Endpoint = 192.168.1.39:51820
PersistentKeepalive = 25
```

### Configuration Explained

| Setting | Purpose |
|---------|---------|
| `Address` | IP assigned to the WireGuard tunnel interface on WS-01 |
| `DNS` | Uses DC-01 as the DNS server through the tunnel |
| `[Peer] PublicKey` | VPN-01's public key |
| `AllowedIPs` | Traffic destined for these networks is routed through the tunnel |
| `Endpoint` | VPN-01's external IP and WireGuard port |
| `PersistentKeepalive` | Keeps the tunnel alive through NAT |

📸 **WireGuard client configuration on WS-01**

![WireGuard Client Configuration](/screenshots/E01/07.png)

---

## 8️⃣ Static Route on DC-01

DC-01 needs a route to reach the WireGuard tunnel network (`10.10.20.0/24`) in order to send responses back to VPN clients. Without this route, DC-01 would not know how to respond to requests originating from `10.10.20.2`.

On **DC-01**, run the following command in PowerShell:

```powershell
New-NetRoute -DestinationPrefix "10.10.20.0/24" -NextHop "10.10.10.30" -InterfaceAlias "Ethernet"
```

This tells DC-01 that traffic destined for the VPN tunnel network should be forwarded to VPN-01 (`10.10.10.30`).

---

## 🔎 Validation

### Tunnel Establishment

Activate the tunnel on WS-01 and verify the handshake on VPN-01:

```bash
wg show
```

Confirm the output shows a peer with a recent handshake and bytes transferred in both directions.

📸 **wg show – handshake established**

![wg show Handshake](/screenshots/E01/08.png)

---

### Connectivity Tests

From **WS-01** with the tunnel active:

```cmd
ping 10.10.20.1
ping 10.10.10.10
ping 10.10.10.30
nslookup bocorp.local
```

| Test | Result |
|------|--------|
| Ping VPN-01 tunnel IP (`10.10.20.1`) | ✔ Reply received |
| Ping DC-01 (`10.10.10.10`) | ✔ Reply received |
| Ping VPN-01 internal IP (`10.10.10.30`) | ✔ Reply received |
| DNS resolution (`bocorp.local`) | ✔ Resolved via DC-01 |

---

### File Share Access

Accessed the IT departmental share from WS-01 through the VPN tunnel:

```
\\DC-01\IT
```

Access was granted using domain credentials, confirming end-to-end functionality across the tunnel.

📸 **File share access attempt before tunnel handshake**

![File Share Access Before](/screenshots/E01/09.png)

📸 **File share access through VPN tunnel**

![File Share Access Through VPN](/screenshots/E01/10.png)

---

## ✅ Outcome

After completing this implementation:

- VPN-01 is deployed as a dedicated WireGuard gateway with dual network interfaces.
- WS-01 can establish an encrypted tunnel from an external network.
- All lab resources are accessible through the VPN tunnel.
- DNS resolution works correctly through DC-01 over the tunnel.
- Domain file shares are accessible using domain credentials.
- The implementation simulates a realistic enterprise remote access scenario.