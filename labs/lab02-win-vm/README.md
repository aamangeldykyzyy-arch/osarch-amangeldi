# Lab 2 — Windows VM, network and memory

## Network diagram

```
            Internet
               |
        My laptop (host)
               |
      VMware NAT (VMnet8)
      gateway 192.168.245.2
         |             |
   lab01 (Ubuntu)   lab02-win11 (Windows 11)
   192.168.245.129  192.168.245.130
```

## Why I chose NAT

I used NAT mode for both VMs.
The VMs must see each other and have internet.
NAT does both: both VMs are on the same virtual network (192.168.245.x), and they get internet through my laptop.
I did not use bridged, because the campus network blocks devices that are not registered.
I did not use host-only, because it has no internet.

## Firewall

- Ping from Windows to Ubuntu worked right away.
- Ping from Ubuntu to Windows did not work (100% packet loss).

Why: Windows marked the network as **Public** (I checked with `Get-NetConnectionProfile`). On a public network the Windows firewall blocks incoming ping.

I did not turn off the firewall. I added one rule that allows only ping from my local network:

```
New-NetFirewallRule -DisplayName "Lab02 - allow ping (ICMPv4 echo)" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -RemoteAddress LocalSubnet -Action Allow
```

After that, ping works both ways (see `evidence/ping-both-ways.txt`).

## Memory experiment

My laptop has **16 GB** of RAM.
I gave the VMs more than that: Ubuntu **8 GB** + Windows **12 GB** = **20 GB**.

| | Before (VMs off) | After (Ubuntu loaded) |
|---|---|---|
| In use | 4.5 GB | 13.0 GB |
| Available | 11.1 GB | 2.5 GB |
| Committed | 4.5 / 17.1 GB | 10.3 / 17.1 GB |

What happened:
- Ubuntu started. I loaded it with `stress-ng`, it used about 5.7 GB.
- Windows **did not start**. VMware showed an error: not enough memory for 12 GB (see `evidence/hypervisor-refused.png`). My laptop can only promise 17.1 GB in total (RAM + page file), and there was not enough left.
- Free memory on the laptop dropped from 11.1 GB to 2.5 GB.
- The laptop was still usable, the disk was almost idle, so there was no heavy swapping.

After the experiment I set memory back: Ubuntu 2 GB, Windows 4 GB. Both VMs start and ping each other again.

## What did not work

- `ssh ... > file.txt` from Windows got stuck on the password. I saved the file inside Ubuntu and copied it with `scp` instead.
- Windows could not start with 12 GB (this was the result of the experiment).
