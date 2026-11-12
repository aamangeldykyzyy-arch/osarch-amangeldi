#!/usr/bin/env bash
# Lab 5 — convert staff-broken.csv from RK1048 to UTF-8 with BOM and LF
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
