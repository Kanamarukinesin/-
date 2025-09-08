
---

# scripts/01_setup.sh
```bash
#!/usr/bin/env bash
set -euo pipefail

# ユーザー bin
mkdir -p "$HOME/.local/bin"

# EIG ツールを PATH（src/EIG をビルド済み想定）
if [[ -x "$HOME/src/EIG/src/convertf" ]]; then
  ln -sf "$HOME/src/EIG/src/convertf"  "$HOME/.local/bin/convertf"
fi
if [[ -x "$HOME/src/EIG/src/mergeit" ]]; then
  ln -sf "$HOME/src/EIG/src/mergeit"   "$HOME/.local/bin/mergeit"
fi

# PATH へ
if ! grep -q '\.local/bin' "$HOME/.zshrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi

# 作業ディレクトリ
mkdir -p "$HOME/ancdna/work" "$HOME/ancdna/AADR/1240k"

echo "[OK] setup done. Make sure plink is installed (brew install plink)."
