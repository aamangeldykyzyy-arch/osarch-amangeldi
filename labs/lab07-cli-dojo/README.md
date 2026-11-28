# Lab 7 - CLI dojo

I did all 20 challenges in cmd on the Windows 11 VM, without any GUI tools.
I started at 19:45, and the times are from the start.
(The clock in the VM is 1 hour ahead, so on the screenshots the start is 20:45.)

| # | Challenge | Command | Time |
|---|---|---|---|
| 1 | Current directory | `cd` | 00:01 |
| 2 | Computer name and user | `hostname & whoami` | 00:04 |
| 3 | Create two folders | `mkdir C:\dojo\logs\old C:\dojo\backup` | 00:09 |
| 4 | notes.txt with text and time | `(echo dojo started& time /t) > C:\dojo\notes.txt` | 00:12 |
| 5 | Path of ping | `where ping` | 00:13 |
| 6 | IPv4, gateway, DNS | `ipconfig /all \| findstr /c:"IPv4" /c:"Default Gateway" /c:"DNS Servers"` | 00:20 |
| 7 | Processes to file + line count | `tasklist > C:\dojo\procs.txt & type C:\dojo\procs.txt \| find /c /v ""` | 00:23 |
| 8 | Start Notepad and kill it by PID | `start notepad`, `tasklist /fi "imagename eq notepad.exe"`, `taskkill /pid 7680 /pid 7156` | 00:28 |
| 9 | Only ERROR lines | `findstr "ERROR" C:\dojo\logs\app.log` | 00:30 |
| 10 | Number of non-INFO lines | `type C:\dojo\logs\app.log \| find /v /c "INFO"` | 00:32 |
| 11 | Copy app.log, show both sizes | `copy /y C:\dojo\logs\app.log C:\dojo\backup\ & dir C:\dojo\logs\app.log C:\dojo\backup\app.log` | 00:33 |
| 12 | Error to errors.txt, nothing on screen | `dir C:\nothing-here > nul 2> C:\dojo\errors.txt` | 00:35 |
| 13 | gateway OK / DOWN | `ping -n 1 192.168.245.2 \| find "TTL=" > nul && echo gateway OK \|\| echo gateway DOWN` | 00:37 |
| 14 | Lines with user1 | `findstr /n /i "user1" C:\dojo\logs\app.log` | 00:40 |
| 15 | Scores high to low | `sort /r C:\dojo\scores.txt` | 00:42 |
| 16 | Processes over 50 MB | `tasklist /fi "memusage gt 51200"` | 00:44 |
| 17 | Process on port 135 | `netstat -ano \| findstr /c:":135 "`, `tasklist /svc /fi "pid eq 8"` | 00:46 |
| 18 | dojo.test → 127.0.0.1 and undo | `(echo.& echo 127.0.0.1 dojo.test) >> C:\Windows\System32\drivers\etc\hosts`, `ping -n 1 dojo.test`, `copy /y C:\dojo\hosts.bak C:\Windows\System32\drivers\etc\hosts`, `ping -n 1 dojo.test` | 00:51 |
| 19 | All files with size | `for /r C:\dojo %f in (*) do @echo %~ff %~zf` | 00:52 |
| 20 | robocopy mirror + exit codes | `robocopy C:\dojo\logs C:\dojo\backup\logs /MIR /LOG+:C:\dojo\robocopy.log /TEE`, `echo %ERRORLEVEL%` | 00:58 |

To save the output I added `>> %E% 2>&1` to every command (E = the evidence file).

## Notes

**13.** The gateway didn't answer the ping, so it printed `gateway DOWN`.

**14.** There are 13 lines, not 1, because findstr also finds user10–user19 (they have "user1" inside), and user1 is in INFO, ERROR and WARN lines.

**17.** PID 8 is svchost.exe (RpcSs service).

**18.** I opened an admin cmd with `powershell -nop -c "Start-Process cmd -Verb RunAs"` and made a backup of hosts first. The first ping went to 127.0.0.1, after the undo the second ping could not find dojo.test.

**20.** Exit codes:
- 1 - first run, files were copied
- 1 - new.txt was copied
- 2 - new.txt was deleted from the source, so /MIR deleted the extra file from the backup
- 0 - nothing changed, nothing to copy

For robocopy, codes below 8 mean it worked.
