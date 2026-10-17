# Lab 1: First Virtual Machine

## Resource justification

My host has 12 threads (10 cores; I count threads, as in Lab 0), 16 GB of RAM
and 441 GB free on C: (Lab 0). Idle, the host already uses about 5.9 GB of RAM,
so about 9.7 GB is free.

**vCPU:** I gave the guest 2 vCPU of my 12 threads. Ubuntu Server needs at
least 1, and 2 leaves some headroom for the install. The upper limit from the
lab is 6 (half of my threads), but I do not use it, because the remaining
threads are needed by the host and by next week's Windows guest.

**RAM:** I gave the guest 2 GB of my 16 GB. The installer is comfortable with
1.5-2 GB. Upper limit: 16 - 5.9 (host) - 4 (reserve for the Windows guest in
Lab 2, since Windows 11 requires at least 4 GB) = about 6 GB. I use 2 GB, not
6, to keep a safety margin: if the guests take almost all of the free memory,
the host starts swapping and everything slows down. Check: host 5.9 + Ubuntu 2
+ Windows 4 = about 11.9 GB of 16, leaving about 4 GB free.

**Disk:** I created a 25 GB dynamically allocated disk (stored as a single
file, not preallocated) out of 441 GB free. Ubuntu Server needs about 5 GB, and
25 GB leaves room for updates and packages. The file only grows as the guest
writes to it. Check: 25 GB + 60 GB or more for the Windows guest = about 85 GB
of 441 GB, leaving more than 350 GB.

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

- The installer's LVM layout gave `/` only 11.5 GB of the 25 GB disk, and the
  other 11.5 GB stayed free in the volume group. I did not change it, as the
  lab says.
- [Inside the guest: `nproc` showed __, `free -h` showed __ total memory,
  `df -h /` showed __ for the root filesystem.]
- [Anything else that really went wrong and what I did about it, for example
  login problems with the Broadcom account, or typing `yes` at the SSH prompt.]
