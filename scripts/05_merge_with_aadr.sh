#!/usr/bin/env bash
set -euo pipefail
aadr="${1:?AADR base path (without .geno)}"    # ~/ancdna/AADR/1240k/aadr_1240k
mine="${2:?your eigenstrat prefix}"            # me.eigenstrat
outp="${3:?merged prefix}"                     # merged_1240k

cd "$HOME/ancdna/work"
cat > par.mergeit <<EOF
geno1: ${aadr}.geno
snp1:  ${aadr}.snp
ind1:  ${aadr}.ind

geno2: ${mine}.geno
snp2:  ${mine}.snp
ind2:  ${mine}.ind

genooutfilename: ${outp}.geno
snpoutfilename:  ${outp}.snp
indoutfilename:  ${outp}.ind
EOF

mergeit -p par.mergeit
ls -lh ${outp}.{geno,snp,ind}
echo "[OK] merged -> ${outp}"
