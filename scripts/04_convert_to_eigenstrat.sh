#!/usr/bin/env bash
set -euo pipefail
bfile="${1:?plink prefix}"    # e.g., me_qc_np
outp="${2:?eigen out prefix}" # e.g., me.eigenstrat
cd "$HOME/ancdna/work"

cat > par.convertf <<EOF
genotypename:     ${bfile}.bed
snpname:          ${bfile}.bim
indivname:        ${bfile}.fam
outputformat:     EIGENSTRAT
genotypeoutname:  ${outp}.geno
snpoutname:       ${outp}.snp
indivoutname:     ${outp}.ind
familynames:      NO
EOF
convertf -p par.convertf

# （必要なら）ターゲット個体のラベルを "me" に統一する例:
# awk '{$1=$3="me"; print}' ${outp}.ind > ${outp}.ind.tmp && mv ${outp}.ind.tmp ${outp}.ind

echo "[OK] EIGENSTRAT -> ${outp}.{geno,snp,ind}"
