
# Task 1 - Inventory and interpret

## 1a

| What | Value | Where I got it |
|---|---|---|
| CPU model |  Intel(R) Core(TM) 5 120U | `Get-CimInstance Win32_Processor \| Format-List *` |
| Core count | 10 | `Get-CimInstance Win32_Processor \| Format-List *` |
| Logical processors  | 12 | `Get-CimInstance Win32_Processor \| Format-List *` |
| Hardware virtualization supported | Not confirmed | `Get-CimInstance Win32_Processor \| Format-List *` |
| Hardware virtualization enabled | Not confirmed; Hypervisor detected | `systeminfo` |
| Memory total/available now | 16 GB / 10 GB | `systeminfo` |
| Disk Size | 512 GB | `Get-PhysicalDisk \| Format-List *` |
| Free space |  354.26 GB | ` Get-Volume ` |
| Disk type | NVMe SSD | `Get-PhysicalDisk` |
| Partition style of the system disk | GPT | `Get-Disk \| Format-Table Number, FriendlyName, PartitionStyle -AutoSize ` |
| OS and version | Microsoft Windows 11 Pro, 10.0.22631 | `Get-CimInstance Win32_OperatingSystem \| Format-List Caption, Version, OSArchitecture` |

## 1b 

1. Both guests? Host has 4 threads, 8 GB of RAM and 31 GB free on the VM volume. I gave the guest(ubuntu) 2 vCPU, 2 GB of RAM and 20 GB dynamically allocated disk. For windows guest I gave also 3 vCPU, 4 GB of RAM and 25 GB storage. In this way, this laptop could hardly run both of the guests at the same time. 
Calculation of RAM:
remaining= 8-2-4=2 GB(used memory was nit given, but still remaining 2 GB is critically small because causes high risk of slow performance)
Storage calculation:
remaining=128-31-20-25=52 GB(which is also not a big amount)
I wouldn't recommend running both guests at the same time due to the risk of slow performance and bad working. Perhaps we could run them separately for better work, even though it might cause some issues.

2. First, I would upgrade the amount of RAM, if its possible. At least 16 GB would be better for running VNs on this laptop. When it comes to the storage, it still has acceptable space left, so it is nit that urgent. 
