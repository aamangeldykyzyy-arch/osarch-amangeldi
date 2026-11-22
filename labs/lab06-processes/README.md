# Lab 6 - Live processes and memory pressure

## 1. The process I picked

I picked **vmtoolsd** (VMware Tools Core Service). I chose it because it runs on **both** guests (Windows and Linux), so I could look at the same program in all three tools.

- On the Windows guest I looked at it in **Task Manager** and **Process Explorer** (the SYSTEM one, PID 3668).
- On the Linux guest I looked at it in **htop** (the root one, PID 1140).

The PIDs are different because these are two different machines. Every system numbers its processes on its own.

## 2. What the three tools showed

| Tool | PID | Parent | Memory | Handles / file descriptors |
|---|---|---|---|---|
| Task Manager | 3668 | not shown | 2,908 K (Memory, active private working set) | 398 handles |
| Process Explorer | 3668 | services.exe (824) | Private Bytes 10,592 K, Working Set 21,768 K, WS Private 2,844 K | 398 handles |
| htop (Linux) | 1140 | PPID 1 (systemd) | RES 11,072 K, VIRT 111M, SHR 9,396 K | 9 file descriptors |

How I got the numbers:
- Task Manager: Details tab, I added the **Handles** column (right click on a column header → Select columns).
- Process Explorer: I ran it as administrator, double clicked vmtoolsd.exe, then looked at the **Image** tab (Parent) and the **Performance** tab (memory and handles).
- htop: I ran `sudo htop`, filtered by `vmtoolsd` and added the **PPID** column in Setup. For file descriptors I used `sudo ls /proc/1140/fd | wc -l`.

Screenshots: `evidence/task-manager.png`, `evidence/process-explorer.png`, `evidence/htop.png`.

## 3. Where the tools disagree

### 3.1 Parent process
- **Task Manager** does not show the parent at all.
- **Process Explorer** shows it as "Parent": `services.exe (824)`. This is the Windows service manager, it starts services.
- **htop** calls it **PPID** (parent PID) and shows `1`, which is systemd, the first process on Linux.

So it is the same idea (who started this process), but one tool does not have it and the other two use different names.

### 3.2 Memory (the biggest disagreement)
For the **same** process (PID 3668) the memory numbers are different:
- Task Manager: **2,908 K**
- Process Explorer: **10,592 K** (Private Bytes) and **21,768 K** (Working Set)

None of them is wrong, they just measure different things:
- Task Manager by default shows only the private memory of the process that is in RAM right now ("active private working set").
- In Process Explorer the same thing is called **WS Private**, and it was **2,844 K**, almost the same as Task Manager. The small difference is because I looked at different moments.
- **Private Bytes** is all the memory the process asked for only for itself, even the part that is not in RAM right now.
- **Working Set** is everything the process has in RAM, including memory shared with other processes (like DLLs).

htop uses other names again:
- **RES** = how much is really in RAM (close to Working Set on Windows).
- **VIRT** = how much memory the process has reserved (much bigger, not all of it is really used).
- **SHR** = the part of RES that can be shared with other processes.

### 3.3 Handles vs file descriptors
- Windows calls it **handles** (398).
- Linux calls it **file descriptors** (9).

It is the same idea: things the process has open. But on Windows a handle can be not only a file, it can also be a registry key, a thread, an event and other objects. That is why the Windows number is much bigger.

### 3.4 Threads
- **htop** showed **4 rows** for vmtoolsd: the process itself (PID 1140) and 3 threads (1201, 1426, 1427, shown in green). They have the same memory numbers because threads share the memory of the process.
- **Task Manager** shows only **one row**.
- **Process Explorer** also shows one row and puts threads in a separate **Threads** tab.

## 4. Memory pressure on Linux

Before the test I took a snapshot of the Linux guest. The Linux guest has **1.6 GB RAM** and **2.0 GB swap**.

I used the python script from the brief. It takes 100 MB more every second. In a second terminal I ran `free -h -s 2` (it prints `free -h` every 2 seconds) to watch what happens.

What happened (full figures are in `evidence/memory-pressure.txt`):

| Moment | Mem used | Mem available | buff/cache | Swap used |
|---|---|---|---|---|
| Before | 552Mi | 1.0Gi | 786Mi | 0B |
| RAM filling | 939Mi | 655Mi | 728Mi | 0B |
| Swap starts | 1.2Gi | 414Mi | 457Mi | 8.0Ki |
| RAM full | 1.5Gi | 51Mi | 95Mi | 714Mi |
| Peak | 1.5Gi | 20Mi | 91Mi | 1.8Gi |
| After | 400Mi | 1.2Gi | 103Mi | 58Mi |

What I noticed:
- First Linux threw away its **cache** (buff/cache went down to about 90Mi). Only after that it started to use **swap**.
- Then RAM stayed full (1.5Gi) and all new memory went to swap, up to **1.8Gi out of 2.0Gi**.
- I did not notice a big slowdown, the counting kept going until the end.
- At **3300 MB** the process was killed. The terminal printed `Killed`.
- After the kill RAM was free again, but **58Mi stayed in swap**. These are pages of other processes that Linux moved to swap and did not need to bring back yet.

## 5. The kernel's record (Linux)

I found it with:

```
sudo dmesg -T | grep -i -E "oom|killed process"
```

The full output is in `evidence/kernel-log-extract.txt`. The important lines:

```
python3 invoked oom-killer: gfp_mask=..., order=0, oom_score_adj=0
oom-kill:constraint=CONSTRAINT_NONE,...,global_oom,task_memcg=/user.slice/user-1000.slice/session-5.scope,task=python3,pid=3157,uid=1000
Out of memory: Killed process 3157 (python3) total-vm:3339132kB, anon-rss:1279032kB, file-rss:2440kB, shmem-rss:0kB, UID:1000 pgtables:6556kB oom_score_adj:0
```

What it means:
- `python3 invoked oom-killer`: python asked for more memory, there was none left, so the kernel started the **OOM killer** (Out Of Memory killer).
- `global_oom`: the whole system ran out of memory, not only one group.
- `task=python3, pid=3157, uid=1000`: the kernel chose python3, it was started by my user from my ssh session (`session-5.scope`).
- `Killed process 3157 (python3) total-vm:3339132kB`: about **3.2 GB** in total, the same as the **3300 MB** in my terminal.
- `anon-rss:1279032kB`: about **1.2 GB** of it was in RAM at the moment of the kill. The rest was in swap.

The process was killed by the **kernel OOM killer**, not by systemd-oomd, so I did not need `journalctl -u systemd-oomd`.

**About the time:** the log says **10:14:46**, but I did the test at about **15:14** my time. This is because the Linux guest shows time in **UTC**, and my time zone is **UTC+5**. 10:14 + 5 hours = 15:14.

## 6. The Windows side

On Windows the same kind of event is **Event ID 2004** from **Microsoft-Windows-Resource-Exhaustion-Detector** in the **System** log.

### 6.1 First search
At first I searched only by the number:

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Id=2004} -MaxEvents 5
```

It found an event 2004, but it was from **Microsoft-Windows-Setup** ("Successfully logged OS information"), not about memory. Event IDs are only unique inside one source, so I had to search by the source too:

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'} -MaxEvents 5
```

This found nothing, so the Windows guest had never run out of memory before.

### 6.2 Making it happen
I took a snapshot of the Windows guest and filled the memory with PowerShell (100 MB every second):

```powershell
$a = @()
while ($true) {
    $a += ,([byte[]]::new(100MB))
    Write-Host ($a.Count * 100) "MB"
    Start-Sleep -Seconds 1
}
```

I watched **Task Manager → Performance → Memory**:
- Before: RAM 4.0 GB, in use 2.8 GB, **Committed 2.9/5.4 GB**.
- During: **Committed 11.8/11.9 GB**. The limit grew from 5.4 GB to 11.9 GB, because Windows made the page file bigger by itself.
- RAM "in use" stayed at about 2.7 GB. Windows counts **committed** memory (memory it promised to programs), even if the program did not write anything into it yet.
- At **9000 MB** PowerShell started to get `System.OutOfMemoryException`. Windows did **not** kill PowerShell, it just refused to give more memory.
- Then my session was logged off with the message **"Your session was logged off because DWM crashed"**. DWM (Desktop Window Manager) draws all the windows. It could not get memory and crashed. PowerShell was closed together with the session and the memory was free again.

### 6.3 The event
After I logged in again:

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'} -MaxEvents 5 | Format-List
```

```
TimeCreated  : 11/22/2026 4:41:09 PM
ProviderName : Microsoft-Windows-Resource-Exhaustion-Detector
Id           : 2004
Message      : Windows successfully diagnosed a low virtual memory condition. The following programs
               consumed the most virtual memory: powershell.exe (6988) consumed 9635581952 bytes,
               MsMpEng.exe (3776) consumed 364384256 bytes, and msedgewebview2.exe (8356) consumed 149377024
               bytes.
```

- `powershell.exe (6988) consumed 9635581952 bytes` = about **9 GB**, the same as the **9000 MB** in my PowerShell window.
- The other two are Microsoft Defender (MsMpEng.exe) and Edge WebView, they used much less.

**About the time:** the event says **4:41 PM**, but my laptop showed **15:41**. The Windows guest clock is set to a different time zone (one hour ahead), so the times look different, but it is the same moment.

### 6.4 Linux vs Windows
| | Linux | Windows |
|---|---|---|
| What happens when memory runs out | The kernel **kills** one process (the OOM killer chooses the biggest one) | Windows **refuses** to give more memory, nobody is killed on purpose |
| Who suffered | Only python3 | PowerShell got errors, and also **DWM** (a system program) crashed and my session was logged off |
| Where it is logged | Kernel log (`dmesg`): "Out of memory: Killed process" | System log, Event 2004 "low virtual memory condition" |
| What the log says | Which process was killed and how much memory it had | Which programs used the most memory, nobody was killed |

## Evidence

```
evidence/
├── task-manager.png
├── process-explorer.png
├── htop.png
├── memory-pressure.txt
├── kernel-log-extract.txt
├── windows-memory-before.png    (extra: Task Manager before the Windows test)
├── windows-memory-during.png    (extra: OutOfMemoryException and Committed 11.8/11.9 GB)
└── windows-dwm-crash.png        (extra: "DWM crashed" message)
```
