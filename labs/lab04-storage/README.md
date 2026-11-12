# Lab 4 - Storage

Pair: none (worked alone)

Driver first half: n/a, I did all the steps myself

Machine: Windows laptop (host) with VMware Workstation Pro; guests: lab01 (Ubuntu Server) and lab02-win11 (Windows 11)

Date: 06.11.2026 (lab done), 07.11.2026 (uploaded to GitHub)

## What I did

1. Shut down both guests and added virtual disks in VMware: one 2 GB disk to the Windows guest and three 2 GB disks to the Linux guest (two for the mirror and one spare for the rebuild).
2. Windows: initialised the new disk as GPT, created one partition, formatted it as NTFS and gave it the letter E.
3. Linux: found the three new disks with lsblk (2 GB, no partitions, no mount point), so I was sure none of them was the system disk sda.
4. Partitioned two of them (sdb, sdc) with parted and built a RAID 1 mirror md0 with mdadm. I waited until the synchronisation finished and saved the healthy state.
5. Formatted the mirror as ext4, mounted it at /mnt/mirror, wrote proof.txt (with my surname and the time) and a 200 MB file random.bin, and saved their SHA-256 checksums.
6. Marked sdc1 as failed, saved the degraded state at once, and removed it from the array.
7. Unmounted and mounted the mirror again, so the files were read from the disk and not from the cache, and checked the checksums again.
8. Partitioned the spare disk sdd, added sdd1 to the array, waited until the rebuild finished and saved the rebuilt state.

Main commands:

```bash
sudo parted /dev/sdb --script mklabel gpt mkpart lab4 1MiB 100% set 1 raid on
sudo parted /dev/sdc --script mklabel gpt mkpart lab4 1MiB 100% set 1 raid on
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
sudo mkfs.ext4 -L lab4 /dev/md0
sudo mount /dev/md0 /mnt/mirror
sha256sum /mnt/mirror/proof.txt /mnt/mirror/random.bin > checksum-before.txt
sudo mdadm /dev/md0 --fail /dev/sdc1
sudo mdadm /dev/md0 --remove /dev/sdc1
sudo umount /mnt/mirror
sudo mount /dev/md0 /mnt/mirror
sha256sum /mnt/mirror/proof.txt /mnt/mirror/random.bin > checksum-after-failure.txt
diff checksum-before.txt checksum-after-failure.txt && echo MATCH
sudo mdadm /dev/md0 --add /dev/sdd1
```

## Windows

Commands used (PowerShell as Administrator):

```powershell
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter E
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel LAB4
```

Disk 0 (system disk): partition style GPT, firmware_type UEFI - because Windows 11 boots in UEFI mode, and UEFI boots only from a GPT disk (MBR is used with Legacy BIOS).

New disk: partition style GPT - because it is the modern style and I wanted the same as the system disk. A 2 GB disk would also work with MBR. The choice would matter for a disk bigger than 2 TB (MBR cannot use it), for more than four partitions (MBR allows only four primary partitions), or for booting a UEFI system from this disk (that needs GPT).

Output of Get-Disk:

```
Number Friendly   Serial Number                    HealthStatus         OperationalStatus      Total Size Partition
       Name                                                                                               Style
------ ---------- -------------                    ------------         -----------------      ---------- ----------
0      VMware ... F7FF_5A76_E80F_D8F5_000C_2967... Healthy              Online                      64 GB GPT
1      VMware ... 81EB_53C5_A4C0_1998_000C_2961... Healthy              Online                       2 GB GPT
```

Output of Get-Partition -DiskNumber 1:

```
   DiskPath: \\?\scsi#disk&ven_nvme&prod_vmware_virtual_n#5&25a13950&0&000001#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}

PartitionNumber  DriveLetter Offset                                       Size Type
---------------  ----------- ------                                       ---- ----
1                           17408                                    15.98 MB Reserved
2                E           16777216                                  1.98 GB Basic
```

Output of $env:firmware_type:

```
UEFI
```

## Linux layout - before

```
NAME                       SIZE TYPE FSTYPE      MOUNTPOINT
loop0                     66.8M loop squashfs    /snap/core24/1643
loop1                      1.5M loop squashfs    /snap/hwctl/123
loop2                     50.1M loop squashfs    /snap/snapd/27710
loop3                      1.5M loop squashfs    /snap/hwctl/131
sda                         25G disk             
├─sda1                       1M part             
├─sda2                       2G part ext4        /boot
└─sda3                      23G part LVM2_member 
  └─ubuntu--vg-ubuntu--lv 11.5G lvm  ext4        /
sdb                          2G disk             
sdc                          2G disk             
sdd                          2G disk             
sr0                        2.7G rom  iso9660     
```

## Linux layout - after the rebuild

```
NAME                       SIZE TYPE  FSTYPE            MOUNTPOINT
loop0                     66.8M loop  squashfs          /snap/core24/1643
loop1                      1.5M loop  squashfs          /snap/hwctl/123
loop2                     50.1M loop  squashfs          /snap/snapd/27710
loop3                      1.5M loop  squashfs          /snap/hwctl/131
sda                         25G disk                    
├─sda1                       1M part                    
├─sda2                       2G part  ext4              /boot
└─sda3                      23G part  LVM2_member       
  └─ubuntu--vg-ubuntu--lv 11.5G lvm   ext4              /
sdb                          2G disk                    
└─sdb1                       2G part  linux_raid_member 
  └─md0                      2G raid1 ext4              /mnt/mirror
sdc                          2G disk                    
└─sdc1                       2G part  linux_raid_member 
sdd                          2G disk                    
└─sdd1                       2G part  linux_raid_member 
  └─md0                      2G raid1 ext4              /mnt/mirror
sr0                        2.7G rom   iso9660           
```

| Role | Device |
|---|---|
| Mirror half A | sdb1 |
| Failed half | sdc1 |
| Replacement | sdd1 |

After the rebuild md0 sits under sdb1 and sdd1. The disk sdc is left with a partition that belongs to nothing.

## Result

| State of the array | What the file shows | Evidence file |
|---|---|---|
| Healthy | [2/2] [UU], state clean | array-healthy.txt |
| Degraded (after failing sdc1) | [2/1] [U_], sdc1 marked (F), state clean, degraded | array-degraded.txt |
| Rebuilt (after adding sdd1) | [2/2] [UU], state clean | array-rebuilt.txt |

Each state was saved at the moment it existed, so the date line in each file has a different time.

The checksums of proof.txt and random.bin before the failure and after the failure are identical (diff printed nothing and the word MATCH appeared). Because I unmounted and mounted the mirror before the second checksum, the files were read from the one remaining disk and not from RAM. So the data survived the loss of one disk.

During the degraded state there was only one copy of random.bin. During the rebuild there was still only one complete copy, and the second copy was complete only when the rebuild finished.

## What did not work the first time

- When I first opened VMware, both Windows VMs showed "Unable to open". I closed VMware completely and opened it again, and then all VMs were shown as "Powered off" and worked normally.
- I added the virtual disks and made a mistake, one disk was created as "Preallocated". I cancelled and started again, and VMware said that the file already exists. The cancelled disks had already created .vmdk files in the VM folder, so I gave the new disks new file names.
- I could not copy the evidence files out of the guest, because the shared folder /mnt/hgfs did not exist. The SSH service was also inactive, so I started it with sudo systemctl start ssh and copied the files to the host with scp.

## The question

Your colleague deleted the wrong file from the mirror an hour ago. Does RAID 1 help? Why?

No, RAID 1 does not help here. A mirror writes every change to both disks, and a deletion is also a change, so the file disappeared from both copies at the same time. What would have helped is a real backup or a snapshot, made before the deletion and stored separately.

## Evidence

- evidence/lsblk-before.txt - the disks before the lab: three new 2 GB disks with no partitions and no mount point
- evidence/array-healthy.txt - the healthy mirror, [UU], state clean
- evidence/array-degraded.txt -  one half failed, [U_], state clean, degraded
- evidence/checksum-before.txt - SHA-256 of the files before the failure
- evidence/checksum-after-failure.txt - SHA-256 after the failure, taken after umount and mount; identical to the one before
- evidence/array-rebuilt.txt - the array after the rebuild, [UU] again
