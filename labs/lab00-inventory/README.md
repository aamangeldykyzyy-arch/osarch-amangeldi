# Lab 0 — Inventory of My Machine

## System Inventory

| What | Value | Where I got it |
|---|---|---|
| CPU model | Intel Core 5 120U | `Get-CimInstance Win32_Processor \| Format-List *` |
| CPU core count | 10 | `Get-CimInstance Win32_Processor \| Format-List *` |
| CPU thread count | 12 | `Get-CimInstance Win32_Processor \| Format-List *` |
| Total RAM | 16 GB | `Get-CimInstance Win32_PhysicalMemory \| Format-List *` |
| Installed RAM modules | 2 | `Get-CimInstance Win32_PhysicalMemory \| Measure-Object` |
| RAM speed | 3200 MHz | `Get-CimInstance Win32_PhysicalMemory \| Format-List *` |
| Disk model | NVMe SAMSUNG MZVL8512HELU-00BTW | `Get-PhysicalDisk` |
| Disk type | NVMe SSD | `Get-PhysicalDisk` |
| Free space on C: | 441.14 GB | `Get-Volume` |
| Firmware type | UEFI | `systeminfo` |
| Firmware version | X1504VAP.313 | `systeminfo` |
| Firmware date | 23.09.2025 | `systeminfo` |
| Hardware virtualization supported | Not confirmed | `Get-CimInstance Win32_Processor \| Format-List *` |
| Hardware virtualization enabled | Not confirmed; Hypervisor detected | `systeminfo` |

## Virtualization Status

Windows detected a running hypervisor (`HyperVisorPresent: True`). However, the processor virtualization properties returned False, so the hardware virtualization status requires further verification.

## What Did Not Work

The virtualization properties returned False. The systeminfo command reported that a hypervisor was detected and that the Hyper-V requirements could not be displayed. Further verification is needed.
