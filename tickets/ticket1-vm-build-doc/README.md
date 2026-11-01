# Ticket 1 — VM build document

## 1. What was asked

> From: Aigerim T. (Office Manager)
> Subject: test machine for new dev
>
> Hi, we have someone starting on Monday and he needs a test computer
> set up. Nothing special, just so he can try things without breaking
> anything. Can you write down how to do it so I can do the next one
> myself? Thanks

## 2. What was actually needed

The request is short and leaves out most of the details. Here is what I noticed, what I would have asked, and what I assumed.

**"A test computer" — physical PC or virtual machine?**
I assumed a **virtual machine**. The request says "try things without breaking anything". A VM is separated from the real computer, and with a snapshot it can be put back to a clean state in seconds. A physical PC cannot be undone like that.

**Who is the real reader of BUILD.md?**
**Aigerim**, not the developer. She said "so I can do the next one myself". She is an office manager, not an IT person. So BUILD.md has a screenshot for most steps, explains every click, avoids jargon, and says *why* each option is chosen.

**Which operating system?**
Not said. Many developers work on Linux, but Windows is easier for Aigerim to check. Because I don't know, BUILD.md builds **both**: an Ubuntu Server VM and a Windows 11 VM.
*Would ask:* "Which OS will he develop for?"

**On which computer will the VMs run?**
Not said. The VMs must run on the computer the developer will use, not necessarily Aigerim's laptop.
*Assumed:* a computer like mine (16 GB RAM, enough free disk). BUILD.md says what to change if it has only 8 GB.
*Would ask:* "Which computer will he use, and how much memory does it have?"

**Network?**
Not said. "Try things" almost always needs the internet, and it is useful if the two VMs can reach each other.
*Assumed:* both VMs need internet and must see each other. I used **NAT**: it gives internet and keeps the VMs hidden from the office network.

**"Without breaking anything" — breaking what?**
Not said. I assumed three things must stay safe: the **real computer** (the VMs get only part of its memory), the **office network** (NAT, not bridged), and the **VM itself** (a `clean-install` snapshot to roll back to).

**Windows licence**
Not mentioned. I used the free **Windows 11 Enterprise Evaluation** — legal, no key needed, but it works for **90 days only**.
*Would ask:* "Does the company have a Windows licence? If not, the VM has to be rebuilt every 90 days."

**"On Monday" — is there time?**
It took me about 2.5 hours with screenshots, and I have done it before. For Aigerim it will probably take **2–3 hours** the first time (Windows alone installs for 20–30 minutes). She should start before Monday.

**Where the request is slightly wrong:** it says "nothing special", but a safe test machine needs several non-default decisions (resources, network mode, local account, firewall rule, snapshot). Each one is explained in BUILD.md.

## 3. What I did

I rebuilt both VMs from nothing, following my own document, and took a screenshot at each step: [BUILD.md](BUILD.md).

**Resources, calculated from my host** (16 GB RAM, 395 GB free disk — from Lab 0 and Lab 2):

| | Ubuntu (`test-ubuntu`) | Windows (`test-win11`) | Total | Left for the host |
|---|---|---|---|---|
| Memory | 2 GB | 4 GB | 6 GB | 10 GB of 16 |
| CPUs | 2 | 2 | — | host has 12 logical CPUs |
| Disk (max, thin) | 25 GB | 64 GB | 89 GB | 306 GB of 395 |

Windows 11 refuses to install below 4 GB / 2 CPUs / 64 GB. Ubuntu Server has no desktop, so 2 GB is enough. In Lab 2 I tested what happens when the guests are given more memory than the host has — VMware refused to start the second guest — so I kept the total well below the host.

**Settings that differ from the default, and why:**

| Setting | Default | What I chose | Why (and the alternative) |
|---|---|---|---|
| Ubuntu memory | VMware's suggestion | 2 GB | Server has no desktop; leaves memory for Windows and the host |
| Network | NAT (VMware) | NAT, checked on both VMs | Internet + VMs see each other + hidden from the office. Bridged is often blocked by MAC filtering on office/campus networks; host-only has no internet |
| Disk | Split into multiple files | Single file, not pre-allocated | Easier to copy; grows only when used instead of taking 25/64 GB at once |
| Windows install | Easy Install (may ask for a key) | "Install the OS later" + attach ISO by hand | Evaluation ISO, no licence key, no surprises |
| Windows TPM | — | "Only the files needed to support a TPM are encrypted" | Windows 11 requires a TPM; VMware remembers the password |
| Windows account | Microsoft account | Local account (Domain join instead) | A test machine should not be tied to a personal account |
| Privacy toggles | On | All off | Test machine does not need to send data |
| SSH on Ubuntu | Off | Install OpenSSH server | Needed to copy files in and out |
| Windows firewall | Blocks incoming ping | One rule: ICMPv4 echo, inbound, LocalSubnet only | Allows exactly ping from the test network. Turning the firewall off would open everything |
| Snapshot | None | `clean-install` on both VMs | One-click way back if the developer breaks something |

**Commands used for the evidence:**

In `test-ubuntu`:
```
uname -a > 04-guest-uname.txt
lsb_release -a >> 04-guest-uname.txt
```

In `test-win11` (cmd), then copied to Ubuntu:
```
ping -n 4 192.168.245.132 > ping-win.txt
ping -n 2 8.8.8.8 >> ping-win.txt
scp ping-win.txt student@192.168.245.132:
```

In `test-ubuntu`:
```
cat ping-win.txt > 05-ping-between-guests.txt
ping -c 4 192.168.245.133 >> 05-ping-between-guests.txt
ping -c 2 8.8.8.8 >> 05-ping-between-guests.txt
```

On the host, to get the files out:
```
scp student@192.168.245.132:04-guest-uname.txt .
scp student@192.168.245.132:05-ping-between-guests.txt .
```

**What went wrong, and how I fixed it:**
- During the Ubuntu install the "Updating system" stage showed a red kernel warning: `watchdog: BUG: soft lockup - CPU#1 stuck for 34s!`. It means the virtual CPU did not get time from the host for a moment. I waited, did not reset the VM, and the installer finished by itself. I added a note about it in BUILD.md (step A15) so Aigerim does not panic.
- The Ubuntu mirror check ran for more than ten minutes without finishing. I pressed **Done** while it was still checking, and the installer continued normally. BUILD.md (step A12) now tells Aigerim to do the same if the check takes longer than about ten minutes.
- After installing VMware Tools, the Windows VM window stayed black. The VM was running (green triangle), the screen was just off. **VM → Power → Restart Guest** brought it back after a short wait. I added this to BUILD.md (step B13).
- On the host I first typed `scp student 192.168...` with a space instead of `@`, so scp tried to log in as my host user. Retyped it with `@`.

## 4. Evidence

| File | What it proves |
|---|---|
| [evidence/01-new-vm-wizard.png](evidence/01-new-vm-wizard.png) | The New VM wizard with the Ubuntu ISO selected and detected |
| [evidence/02-disk-settings.png](evidence/02-disk-settings.png) | Windows disk: 64 GB, single file, not pre-allocated |
| [evidence/03-network-adapter.png](evidence/03-network-adapter.png) | The network adapter is set to NAT |
| [evidence/04-guest-uname.txt](evidence/04-guest-uname.txt) | The Ubuntu guest really runs: `Linux test-ubuntu 7.0.0-42-generic … x86_64`, `Ubuntu 26.04.1 LTS` |
| [evidence/05-ping-between-guests.txt](evidence/05-ping-between-guests.txt) | Windows → Ubuntu (192.168.245.132) 0% loss; Windows → 8.8.8.8 0% loss; Ubuntu → Windows (192.168.245.133) 0% loss; Ubuntu → 8.8.8.8 0% loss. Both guests reach each other and the internet |
| [evidence/06-snapshot-list.png](evidence/06-snapshot-list.png) | Snapshot Manager shows the `clean-install` snapshot |

All step screenshots are in [img/](img/) and are used in BUILD.md.

## 5. What I would do differently

I would test BUILD.md on a computer with **8 GB of memory** before giving it to Aigerim. I only built on my 16 GB laptop, so the 8 GB advice in BUILD.md (1 GB for Ubuntu, close other programs) is untested, and the new developer's computer may well be smaller than mine. I would also save a screenshot of every warning when it happens — I did not keep one of the soft lockup message, so it is only described in text.
