
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
