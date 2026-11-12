# Lab 5 - Encoding forensics

Machine: Windows laptop (host), VMware Workstation Pro, guest lab01 (Ubuntu Server 26.04.1 LTS)

Date: 12.11.2026

> **Result:** the file was in **RK1048** with **CRLF** line endings and **no BOM**. I converted it to **UTF-8 + BOM + LF**, and now the names read correctly in Excel, LibreOffice and cat.

## What I did

1. Copied `staff-broken.csv` from the host into Ubuntu with `scp` and saved its checksum.
2. Ran `file` and `xxd` on the untouched original and saved the output.
3. Found the encoding with `iconv` and the line ending with `cat -A`.
4. Opened a copy of the broken file in Excel, LibreOffice and `cat` to see what each one does.
5. Tested a BOM / no-BOM version in Excel and LibreOffice.
6. Fixed the file with `scripts/fix.sh` and checked it in all three programs.

```bash
$ sha256sum staff-broken.csv
919027f1f8c71d85cba3f12aad0f6c927d4e0450cfb2a2d63378a69f14cab270  staff-broken.csv
```

## Diagnosis (before the fix)

### file says (`evidence/file-before.txt`)

```bash
$ file staff-broken.csv
staff-broken.csv: Non-ISO extended-ASCII text, with CRLF line terminators
$ file -e csv staff-broken.csv
staff-broken.csv: Non-ISO extended-ASCII text, with CRLF line terminators
```

### First 16 bytes (`evidence/hexdump-before.txt`)

```bash
$ xxd -l 16 staff-broken.csv
00000000: d2e0 e12e b93b d4c8 ce3b c4ee ebe6 edee  .....;...;......
```

| Offset | Bytes | What they are |
|---|---|---|
| 00-02 | `D2 E0 E1` | `Таб`: no BOM; one Cyrillic letter = one byte |
| 03 | `2E` | `.` |
| 04 | `B9` | `№` |
| 05 | `3B` | `;` column separator |
| 06-08 | `D4 C8 CE` | `ФИО` |
| 09 | `3B` | `;` column separator |
| 0A-0F | `C4 EE EB E6 ED EE` | `Должно` (start of `Должность`) |

### Encoding: RK1048

**Evidence 1: it is not UTF-8.** In UTF-8 a Russian letter takes 2 bytes (`Т` = `D0 A2`); here it takes 1 (`D2`).

```bash
$ iconv -f UTF-8 -t UTF-8 staff-broken.csv > /dev/null && echo valid
iconv: illegal input sequence at position 0
```

**Evidence 2: the Kazakh letters pick the code page.** CP1251, RK1048 and PT154 all show the Russian letters correctly, so I compared row 1001:

```bash
$ iconv -f CP1251 -t UTF-8 staff-broken.csv | head -20
1001;Ќасымова Јлия Серікќызы;Главный бухгалтер;...      (wrong)
$ iconv -f PT154 -t UTF-8 staff-broken.csv | head -20
1001;Қасымова Јлия Серікқызы;Главный бухгалтер;...      (wrong)
$ iconv -f RK1048 -t UTF-8 staff-broken.csv | head -20
1001;Қасымова Әлия Серікқызы;Главный бухгалтер;...      (correct)
```

**Evidence 3: RK1048 reads the whole file with no error.**

```bash
$ iconv -f RK1048 -t UTF-8 staff-broken.csv > /dev/null && echo ok
ok
```

### Line ending: CRLF

**Evidence:** `^M$` at the end of every line, and the number of CR bytes equals the number of LF bytes.

```bash
$ cat -A staff-broken.csv | head -3
M-RM-`M-a.M-9;M-TM-HM-N;...;E-mail;M-DM-`M-rM-` M-oM-pM-hM-8M-lM-`^M$
1001;M-^MM-`M-qM-{M-lM-nM-bM-` ...;a.kassymova@tumar-office.kz;12.03.2019^M$
1002;M-HM-bM-`M-mM-nM-b ...;s.ivanov@tumar-office.kz;01.09.2017^M$
$ tr -cd '\r' < staff-broken.csv | wc -c
26
$ wc -l staff-broken.csv
26 staff-broken.csv
```

### BOM: absent

**Evidence:** the file starts with `D2` (`Т`), not with `EF BB BF`.

## What each application was doing wrong

| Application | Assumed | Because | What I saw |
|---|---|---|---|
| **Excel** | CP1251 | There is no BOM, so Excel used the Windows default (CP1251 on Russian Windows) | Russian OK; Kazakh wrong: `Ќасымова`, `Јбенова`, `Нўрланов` |
| **LibreOffice** | Windows-1251 | It guesses from the bytes and picked the nearest Cyrillic code page | Same as Excel; its Text Import window showed "Кириллица (Windows-1251)" |
| **cat** | UTF-8 (the terminal) | cat converts nothing, and one-byte letters are not valid UTF-8 | Every letter became `�`; numbers, e-mails and dates were fine |

The file was **not damaged**: every program just read the bytes with the wrong encoding.

## Fix

Command / script: `scripts/fix.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
SRC_ENC="RK1048"
IN=evidence/staff-broken.csv
OUT=evidence/staff-fixed.csv

{
  printf '\xEF\xBB\xBF'                                  # add a UTF-8 BOM
  iconv -f "$SRC_ENC" -t UTF-8 "$IN" | sed 's/\r$//'     # RK1048 -> UTF-8, CRLF -> LF
} > "$OUT"

file -e csv "$OUT"
xxd -l 16 "$OUT"
```

```bash
$ bash scripts/fix.sh
evidence/staff-fixed.csv: Unicode text, UTF-8 (with BOM) text
00000000: efbb bfd0 a2d0 b0d0 b12e e284 963b d0a4  .............;..
```

| What | Before | After | Why |
|---|---|---|---|
| Encoding | RK1048 | UTF-8 | Every program can read UTF-8 |
| Line ending | CRLF | LF | CR breaks Linux scripts (see the awk check below) |
| BOM | none | `EF BB BF` | **Excel decided it** (see the test below) |

**BOM test.** I made the same UTF-8 file with and without a BOM and opened both:

| Reader | Without BOM | With BOM |
|---|---|---|
| Excel (double-click) | wrong: `РўР°Р±.в„–` | correct |
| LibreOffice | correct | correct |
| cat | correct | correct |

Without a BOM Excel reads UTF-8 as CP1251, so I added the BOM.

## Verification

### file after (`evidence/file-after.txt`)

```bash
$ file staff-fixed.csv
staff-fixed.csv: Unicode text, UTF-8 (with BOM) text
$ file -e csv staff-fixed.csv
staff-fixed.csv: Unicode text, UTF-8 (with BOM) text
```

### The original was not changed

```bash
$ sha256sum staff-broken.csv
919027f1f8c71d85cba3f12aad0f6c927d4e0450cfb2a2d63378a69f14cab270  staff-broken.csv
```

This is the same checksum as at the start.

### The check a script would do

```bash
$ awk -F';' '{ print $NF "|" }' staff-fixed.csv | head -3
Дата приёма|
12.03.2019|
01.09.2017|
$ awk -F';' '{ print $NF "|" }' staff-broken.csv | head -3
|��� �����
|2.03.2019
|1.09.2017
```

With LF the `|` stays after the date. With CRLF the hidden CR moves `|` to the start of the line, and it covers the first digit.

### Opened in (`evidence/opens-correctly.png`)

| Application | Version | How I opened it | Result |
|---|---|---|---|
| Excel | Microsoft 365 | Double-click in Explorer | Correct: `Қасымова Әлия Серікқызы`, columns split |
| LibreOffice Calc | 26.8.3.1 | Open with → Calc; it chose **UTF-8** by itself | All names correct |
| cat | Ubuntu 26.04.1 LTS | `cat staff-fixed.csv` over SSH | All names correct |

## What did not work the first time

- **A typo in my evidence.** I forgot `.csv` in one command, and the error message got saved into `file-before.txt`. I saw it with `cat` and made the file again from the original.
- **♦ instead of Kazakh letters.** The VMware console showed ♦ even with RK1048. That was the console font, not the file. Over SSH from PowerShell all letters were correct.
- **Excel turned into LibreOffice.** After I installed LibreOffice, CSV files opened in it. I set Excel back as the default app.
- **Wrong file in the screenshot.** The first time, LibreOffice had the old broken copy open. I opened `staff-fixed.csv` and took the screenshot again.

## Evidence

| File | What it proves |
|---|---|
| `evidence/staff-broken.csv` | The original, not changed (same checksum at the start and the end) |
| `evidence/file-before.txt` | Before the fix: extended-ASCII text with CRLF |
| `evidence/hexdump-before.txt` | First 16 bytes: one byte per letter, no BOM |
| `evidence/staff-fixed.csv` | The converted file |
| `evidence/file-after.txt` | After the fix: UTF-8 with BOM, no CRLF |
| `evidence/opens-correctly.png` | Excel, LibreOffice and cat all show the names correctly |
| `scripts/fix.sh` | The conversion: RK1048 -> UTF-8, CRLF -> LF, BOM added |
