# -
日本人向けです。Rを使います。私はMacOSを使いました。windowsではUbuntuの使用を推奨します。

# ancdna-qpadm-pipeline
個人 SNP データを AADR (1240k) にマージして、`admixtools` の qpAdm で
- 2元: Jomon + (Korean / CHB.DG / Han.DG)
- 3元: Jomon + Yayoi(北東アジア代理) + Kofun(東アジア本土/CHB/Han or Kofun古DNA)

を推定・可視化する最小パイプライン。

## 依存
- PLINK 1.9 (`brew install plink`)
- EIGENSOFT の `convertf`, `mergeit` （EIG をビルド済み想定）
- R ≥ 4.3
- Rパッケージ: `admixtools`（CRAN 版推奨）

## ディレクトリ
~/ancdna/
├─ AADR/1240k/ # AADR v62の3点セットを置く
└─ work/ # 作業場（出力もここ）


## AADR（v62.0 1240k 公開版）の配置
Dataverse から以下 **3ファイル** を取得して `~/ancdna/AADR/1240k` に置く:
- `v62.0_1240k_public.geno`
- `v62.0_1240k_public.snp`
- `v62.0_1240k_public.ind`

そして同ディレクトリで:
```bash
ln -sf v62.0_1240k_public.geno aadr_1240k.geno
ln -sf v62.0_1240k_public.snp  aadr_1240k.snp
ln -sf v62.0_1240k_public.ind  aadr_1240k.ind

