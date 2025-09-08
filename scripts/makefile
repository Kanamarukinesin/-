# ===== ancdna-qpadm-pipeline : Makefile =====

# ---- パラメータ（必要に応じて make VAR=... で上書き）----
SCRIPTS_DIR   ?= scripts
WORKDIR       ?= $(HOME)/ancdna/work
AADR_PREFIX   ?= $(HOME)/ancdna/AADR/1240k/aadr_1240k

# 入力（RAW は LivingDNA/23andMe 由来のテキスト; 4列: rsid chr pos genotype）
RAW           ?= $(WORKDIR)/me_raw.txt

# 出力/中間物のプレフィックス
CLEAN_TXT     ?= $(WORKDIR)/me_raw_clean.txt
BFILE_PREFIX  ?= $(WORKDIR)/me_qc_np          # PLINK で QC 後
EIG_PREFIX    ?= $(WORKDIR)/me.eigenstrat     # convertf 後
MERGED_PREFIX ?= $(WORKDIR)/merged_1240k      # mergeit 後（AADRと結合）

# .ind のラベルを "me" に統一するか（1=する / 0=しない）
RELABEL_ME    ?= 1
ME_LABEL      ?= me

# ---- 使い方 ------------------------------------------------
.PHONY: help
help:
	@echo ""
	@echo "Usage:"
	@echo "  make all RAW=/path/to/raw.txt"
	@echo ""
	@echo "Main targets:"
	@echo "  setup        : PATH整備、作業ディレクトリ作成"
	@echo "  aadr-check   : AADR 3点セットの存在確認"
	@echo "  clean        : 生ファイル整形 -> $(CLEAN_TXT)"
	@echo "  qc           : PLINK 取込み+QC+パリンドロミック除外 -> $(BFILE_PREFIX).*"
	@echo "  eigen        : convertf -> $(EIG_PREFIX).{geno,snp,ind}"
	@echo "  label        : .ind のラベルを '$(ME_LABEL)' に統一（RELABEL_ME=$(RELABEL_ME)）"
	@echo "  merge        : AADR とマージ -> $(MERGED_PREFIX).{geno,snp,ind}"
	@echo "  qpadm2       : 2元（Jomon+Korean/CHB/Han）と図"
	@echo "  qpadmgrid    : 2元のロバスト格子と図"
	@echo "  qpadm3       : 3元（Jomon+Yayoi(NEA)+Kofun(EA)）と図"
	@echo "  all          : 上記を一括実行（qpadm3 は任意）"
	@echo ""

# ---- 前提ツールのチェック --------------------------------
.PHONY: check-tools
check-tools:
	@command -v plink >/dev/null 2>&1 || { echo "[ERR] plink not found"; exit 1; }
	@command -v convertf >/dev/null 2>&1 || { echo "[ERR] convertf not found"; exit 1; }
	@command -v mergeit  >/dev/null 2>&1 || { echo "[ERR] mergeit not found";  exit 1; }
	@command -v R        >/dev/null 2>&1 || { echo "[ERR] R not found";        exit 1; }
	@echo "[OK] tools present."

# ---- セットアップ ------------------------------------------
.PHONY: setup
setup:
	@bash "$(SCRIPTS_DIR)/01_setup.sh"

# ---- AADR の存在確認 ---------------------------------------
.PHONY: aadr-check
aadr-check:
	@[ -f "$(AADR_PREFIX).geno" ] && [ -f "$(AADR_PREFIX).snp" ] && [ -f "$(AADR_PREFIX).ind" ] \
		|| { echo "[ERR] Missing AADR: $(AADR_PREFIX).{geno,snp,ind}"; exit 1; }
	@echo "[OK] AADR present: $(AADR_PREFIX).{geno,snp,ind}"

# ---- クリーニング ------------------------------------------
$(CLEAN_TXT): $(RAW)
	@mkdir -p "$(WORKDIR)"
	@bash "$(SCRIPTS_DIR)/02_clean_livingdna.sh" "$(RAW)" "$(CLEAN_TXT)"
clean: $(CLEAN_TXT)

# ---- PLINK QC ----------------------------------------------
# me_raw, me_qc などは内部で作成される
.PHONY: qc
qc: $(CLEAN_TXT)
	@bash "$(SCRIPTS_DIR)/03_plink_qc.sh" "$(CLEAN_TXT)" "$(BFILE_PREFIX)"

# ---- convertf ----------------------------------------------
.PHONY: eigen
eigen: qc
	@bash "$(SCRIPTS_DIR)/04_convert_to_eigenstrat.sh" "$(BFILE_PREFIX)" "$(EIG_PREFIX)"

# ---- ラベル統一（任意）-------------------------------------
.PHONY: label
label: eigen
ifneq ($(RELABEL_ME),0)
	@awk 'BEGIN{OFS=" "}{ $$1="$(ME_LABEL)"; print }' "$(EIG_PREFIX).ind" > "$(EIG_PREFIX).ind.tmp" && mv "$(EIG_PREFIX).ind.tmp" "$(EIG_PREFIX).ind"
	@echo "[OK] relabeled IND -> $(ME_LABEL)"
else
	@echo "[SKIP] relabel (RELABEL_ME=$(RELABEL_ME))"
endif

# ---- mergeit ------------------------------------------------
.PHONY: merge
merge: aadr-check label
	@bash "$(SCRIPTS_DIR)/05_merge_with_aadr.sh" "$(AADR_PREFIX)" "$(EIG_PREFIX)" "$(MERGED_PREFIX)"

# ---- qpAdm 2-way -------------------------------------------
.PHONY: qpadm2
qpadm2: merge
	@cd "$(WORKDIR)" && R --vanilla -q -f "$(PWD)/$(SCRIPTS_DIR)/06_qpadm_2way.R"

# ---- 2-way ロバスト格子 ------------------------------------
.PHONY: qpadmgrid
qpadmgrid: merge
	@cd "$(WORKDIR)" && R --vanilla -q -f "$(PWD)/$(SCRIPTS_DIR)/07_qpadm_robust_grid.R"

# ---- 3-way --------------------------------------------------
.PHONY: qpadm3
qpadm3: merge
	@cd "$(WORKDIR)" && R --vanilla -q -f "$(PWD)/$(SCRIPTS_DIR)/08_qpadm_3way.R"

# ---- フルパイプライン --------------------------------------
.PHONY: all
all: check-tools setup aadr-check clean qc eigen label merge qpadm2 qpadmgrid
	@echo "[DONE] all (3-way は `make qpadm3` で実行)"

# ---- お片付け ----------------------------------------------
.PHONY: clean-outputs distclean
clean-outputs:
	@rm -f "$(WORKDIR)"/qpadm_*.{csv,png}
	@echo "[OK] removed qpadm outputs."

distclean: clean-outputs
	@rm -f "$(WORKDIR)"/me_raw.* "$(WORKDIR)"/me_qc* \
	        "$(WORKDIR)"/palindromic.snps \
	        "$(EIG_PREFIX)".{geno,snp,ind} \
	        "$(MERGED_PREFIX)".{geno,snp,ind}
	@echo "[OK] removed intermediates."


# 1) 依存確認＆初期化
make check-tools setup aadr-check

# 2) 一気通し（RAW を指定）
make all RAW=~/Downloads/your_raw.txt

# 3) 3元も試す
make qpadm3
