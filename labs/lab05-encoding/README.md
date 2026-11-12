# Lab 5 - Encoding forensics

## Diagnosis (before the fix)

file says:            (from evidence/file-before.txt)
```
staff-broken.csv: Non-ISO extended-ASCII text, with CRLF line terminators
staff-broken.csv: Non-ISO extended-ASCII text, with CRLF line terminators
```

First 16 bytes:       (from evidence/hexdump-before.txt)
```
00000000: d2e0 e12e b93b d4c8 ce3b c4ee ebe6 edee  .....;...;......
```

| Offset | Bytes | What they are |
|---|---|---|
| 00–02 | `D2 E0 E1` | `Таб`: no BOM, the file starts with letters. 1 letter = 1 byte |
| 03 | `2E` | `.` |
| 04 | `B9` | `№` |
| 05 | `3B` | `;` (column separator) |
| 06–08 | `D4 C8 CE` | `ФИО` |
| 09 | `3B` | `;` (column separator) |
| 0A–0F | `C4 EE EB E6 ED EE` | `Должно` (start of `Должность`) |

There is no line ending in the first 16 bytes: the header line is longer.

**Encoding:     RK1048** (Kazakh Windows code page)
Evidence:
- Not UTF-8: a Russian letter is 1 byte here (`Т` = `D2`), but in UTF-8 it is 2 bytes (`D0 A2`). `iconv -f UTF-8` gave `illegal input sequence at position 0`.
- CP1251, RK1048 and PT154 all show Russian letters correctly. The Kazakh letters decided it:
  - CP1251 gives `Ќасымова Јлия` (wrong)
  - PT154 gives `Јлия` (wrong)
  - RK1048 gives `Қасымова Әлия` (correct)
- `iconv -f RK1048 -t UTF-8 staff-broken.csv > /dev/null && echo ok` printed `ok`. All 25 names were correct.

**Line ending:  CRLF** (Windows)
Evidence:
- `cat -A` shows `^M$` at the end of every line.
- `tr -cd '\r' < staff-broken.csv | wc -c` gave 26 CR.
- `wc -l` gave 26 LF.
- CR = LF = 26 lines, so it is CRLF.

**BOM:          absent**
Evidence: the file starts with `D2`, not `EF BB BF`.

## What each application was doing wrong

**Excel:**        assumed CP1251, because the file has no BOM, so Excel used the Windows default encoding (CP1251 on Russian Windows). Russian names were correct, but Kazakh letters became other letters: `Қасымова` → `Ќасымова`, `Әбенова` → `Јбенова`, `Нұрланов` → `Нўрланов`.

**LibreOffice:**  guessed the encoding from the bytes and chose Windows-1251 (shown in the Text Import window). Same result as Excel: Russian correct, Kazakh wrong.

**cat:**          does not convert anything. The terminal reads everything as UTF-8, and 1-byte letters are not valid UTF-8, so all Russian and Kazakh letters became `�`. Numbers, e-mails and dates were fine.

## Fix

Command / script:  `scripts/fix.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
SRC_ENC="RK1048"
IN=evidence/staff-broken.csv
OUT=evidence/staff-fixed.csv

{
  printf '\xEF\xBB\xBF'
  iconv -f "$SRC_ENC" -t UTF-8 "$IN" | sed 's/\r$//'
} > "$OUT"

file -e csv "$OUT"
xxd -l 16 "$OUT"
```

Changed:
- **encoding:** RK1048 → UTF-8
- **line ending:** changed to LF
- **BOM:** added, because Excel decided it

I tested both versions. Without a BOM, Excel showed garbage (`РўР°Р±.в„–`); with a BOM it showed all names correctly. LibreOffice and cat worked with both.

I changed CRLF to LF because CR breaks Linux scripts:
- `awk -F';' '{ print $NF "|" }' staff-broken.csv` prints `|2.03.2019` (broken)
- the same command on `staff-fixed.csv` prints `12.03.2019|`

Bytes before and after:
```
before: d2e0 e12e b93b d4c8 ce3b c4ee ebe6 edee
after:  efbb bfd0 a2d0 b0d0 b12e e284 963b d0a4
```

## Verification

file after:   (from evidence/file-after.txt)
```
staff-fixed.csv: Unicode text, UTF-8 (with BOM) text
staff-fixed.csv: Unicode text, UTF-8 (with BOM) text
```
CRLF is gone.

Opened in:    Excel (Microsoft 365), LibreOffice Calc 26.8.3.1, cat on Ubuntu 26.04.1 LTS
              — evidence/opens-correctly.png

- **Excel:** opened by double-click, names correct, columns split.
- **LibreOffice:** chose UTF-8 by itself, names correct.
- **cat:** names correct.

The checksum of `staff-broken.csv` is the same at the start and at the end (`919027f1…14cab270`), so the original was not changed.

## What did not work the first time

- **Typo in the evidence file.** I forgot `.csv` in one command, and the error message was saved into `file-before.txt`. I noticed it with `cat` and made the file again.
- **Kazakh letters showed as ♦.** In the VMware console even RK1048 showed ♦ instead of Ә, Қ, Ұ. The reason was the console font, which does not have these letters. I connected with SSH from PowerShell, and there all letters were correct.
- **Excel opened as LibreOffice.** After installing LibreOffice, double-click opened CSV in LibreOffice. I set Excel back as the default app in Windows settings.
- **Wrong file in the screenshot.** The first time, LibreOffice had the old broken file open. I opened `staff-fixed.csv` and took the screenshot again.
