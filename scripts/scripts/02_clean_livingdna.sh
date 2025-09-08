#!/usr/bin/env bash
set -euo pipefail
raw_clean="${1:?clean 23file path}"
outpref="${2:?out prefix}"   # e.g., me_qc_np

cd "$HOME/ancdna/work"

# 取込み
plink --23file "$raw_clean" 0 --make-bed --out me_raw

# QC（SNP/個体 欠損5%）
plink --bfile me_raw --geno 0.05 --mind 0.05 --make-bed --out me_qc

# パリンドロミック除外
awk '($5$6=="AT"||$5$6=="TA"||$5$6=="CG"||$5$6=="GC"){print $2}' me_qc.bim > palindromic.snps
plink --bfile me_qc --exclude palindromic.snps --make-bed --out "$outpref"

echo "[OK] PLINK QC -> $outpref.{bed,bim,fam}"
