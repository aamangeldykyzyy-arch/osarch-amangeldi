# Lab 1: First Virtual Machine

## Resource justification
My host has 12 threads, 16 GB of RAM and 441 GB free on the VM volume (Lab 0).
Idle, the host already uses about 5.9 GB of RAM.
I gave the guest 2 vCPU of my 12 threads because Ubuntu Server needs at least 1, 2 leaves headroom for the install, and the remaining threads are needed by the host and by the Windows guest next week (the upper limit is 6, half of my threads).
I gave it 2 GB of my 16 GB RAM because the installer is comfortable with 1.5-2 GB, and I keep 4 GB for the Windows guest in Lab 2 (Windows 11 requires at least 4 GB). The upper limit is 16 - 5.9 - 4 = about 6 GB, but I stay at 2 GB so the host does not start swapping when both guests run.
I gave it a 25 GB dynamically allocated disk of my 441 GB free because Ubuntu Server needs about 5 GB, 25 GB leaves room for updates and packages, the file only grows as the guest writes, and more than 350 GB stays free for the Windows guest (60 GB or more).

## What I broke and how I confirmed it

I chose option A: delete the hostname file.

- Before: `cat /etc/hostname` printed `lab01`.
- Break: `sudo rm /etc/hostname`, then `sudo reboot`.
- Confirmed broken: `cat /etc/hostname` printed `No such file or directory`,
  and `hostnamectl` showed `Static hostname: (unset)`
  (see `evidence/broken.png`).
- Rollback: I took the snapshot `clean-install` before breaking anything, and
  later reverted with VM -> Snapshot -> Revert to Snapshot.
- Confirmed fixed: after the rollback `cat /etc/hostname` printed `lab01`
  again. The snapshot list is in `evidence/snapshot-list.png`.

## What did not work

- **Root filesystem smaller than the disk.** I created a 25 GB disk, but the
  installer's LVM layout gave `/` only 11.5 GB; the other 11.5 GB stayed free
  in the volume group. I did not change it, as the lab says.
- **Screenshot order.** I forgot to take `vm-settings.png` before the first
  power-on, so I took it later from the VM settings. The settings were not
  changed in between, so it shows the same 2 vCPU, 2 GB RAM and 25 GB disk.
- **SSH prompt.** I could not answer the `yes` prompt on the first SSH
  connection, so I used `ssh -o StrictHostKeyChecking=accept-new` instead,
  and `guest-release.txt` was created correctly.
