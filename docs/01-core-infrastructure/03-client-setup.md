# 03 – Client Setup (WS-01 & WS-02)

---

## 🎯 Objective

Deploy and configure two Windows 11 Pro client machines that will:

- Join the lab domain
- Receive Group Policies
- Be managed through Active Directory
- Serve as test endpoints for future integrations (Entra, Intune, Action1)

This phase establishes the workstation layer of the lab environment.

---

## 🖥 Client Architecture

Two workstations will be deployed:

- WS-01 (Primary installation)
- WS-02 (Cloned from WS-01 snapshot)

Both machines will:

- Run Windows 11 Pro
- Connect to the same virtual switch
- Use static or DHCP configuration (depending on lab design)
- Join the lab.local domain

---

## 1. Install Windows 11 Pro on WS-01

### Virtual Machine Configuration

- VM Name: WS-01
- Startup Memory: 4096 MB
- Processor: 2 vCPU
- Virtual Disk: 60 GB (VHDX)

### Installation Steps

1. Create the virtual machine in Hyper-V.
2. Attach the Windows 11 Pro ISO.
3. Complete the Windows installation.
4. Create a temporary local administrator account.
5. Finish initial setup.

📸 **Hyper-V VM settings for WS-01**

![Hyper-V VM settings for WS-01](/screenshots/03/01.png)

📸 **First login screen**

![First login screen](/screenshots/03/02.png)

---

## 2. Create Snapshot of WS-01

After Windows installation is completed and before domain join:

1. Shut down WS-01.
2. In Hyper-V Manager, create a Checkpoint (Snapshot).
3. Name it: Windows 11 Pro clean install

This snapshot will serve as the base image for WS-02.

📸 **Windows 11 Pro clean install checkpoint**

![Windows 11 Pro clean install checkpoint](/screenshots/03/03.png)

---

## 3. Deploy WS-02 from Snapshot

- Export WS-01
- Import it as a new VM
- Rename it to WS-02

📸 **WS-02 Created from WS-01 checkpoint**

![WS-02 Created from WS-01 checkpoint](/screenshots/03/04.png)

---

## 4. Configure Computer Name and Network

### WS-01 Configuration

- Computer Name: WS-01
- IP Address: 10.10.10.101
- DNS Server: 10.10.10.10 (DC-01)
- Gateway: 10.10.10.1

📸 **Network settings for WS-01**

![Network settings for WS-01](/screenshots/03/05.png)

📸 **Screenshot showing WS-01 name**

![Screenshot showing WS-01 name](/screenshots/03/06.png)

### WS-02 Configuration

- Computer Name: WS-02
- IP Address: 10.10.10.102
- DNS Server: 10.10.10.10 (DC-01)
- Gateway: 10.10.10.1

📸 **Network settings for WS-02**

![Network settings for WS-02](/screenshots/03/07.png)

📸 **Screenshot showing WS-02 name**

![Screenshot showing WS-02 name](/screenshots/03/08.png)

---

## 5. Join Both Machines to the Domain

For each workstation:

1. Open System Settings.
2. Select "Rename this PC (Advanced)".
3. Choose "Domain".
4. Enter: bocorp.local
5. Provide domain credentials (BOCORP\Administrator).
6. Restart when prompted.

---

## 🔎 Post-Domain Join Validation

On DC01:

- Open Active Directory Users and Computers.
- Confirm WS-01 and WS-02 appear in the Computers container.

📸 **Screenshot of ADUC after both WS joined the domain**

![Screenshot of ADUC after both WS joined the domain](/screenshots/03/09.png)

On each workstation:

- Log in using a domain account.
- Confirm network access.
- Verify communication with the Domain Controller.

📸 **WS-01 logged in as BOCORP/Administrator**

![WS-01 logged in as BOCORP/Administrator](/screenshots/03/10.png)

📸 **WS-02 logged in as BOCORP/Administrator**

![WS-02 logged in as BOCORP/Administrator](/screenshots/03/11.png)

---

## 🧠 Design Notes

- Snapshotting before domain join prevents SID conflicts and duplicate computer objects.
- Each machine must be renamed before joining the domain.
- Proper DNS configuration is mandatory for domain operations.
- Using Windows 11 Pro is required for domain join capability.

---

## ✅ Outcome

By completing this phase:

- Two Windows 11 Pro workstations were deployed.
- A clean baseline snapshot was created.
- WS-02 was provisioned from the WS-01 base image.
- Both machines were properly configured with unique identities.
- WS-01 and WS-02 successfully joined the bocorp.local domain.

The lab environment now includes:

✔ One Domain Controller  
✔ Two domain-joined client machines  
✔ A functional Active Directory infrastructure
