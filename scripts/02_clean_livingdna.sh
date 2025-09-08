#!/usr/bin/env bash
set -euo pipefail
in="${1:?raw txt path}"; out="${2:?clean txt}"

# 入力: rsid chr pos genotype（1-2文字） or 雑多
awk 'BEGIN{OFS="\t"}
  /^#/ {next}
  NR==1 && ($1=="rsid"||$1=="RSID") {next}
  {
    g=toupper($4)
    gsub(/[^ACGT]/,"",g)
    if (length(g)==1) g=g g
    if (length(g)!=2) g="--"
    print $1,$2,$3,g
  }' "$in" > "$out"

echo "[OK] cleaned -> $out"
