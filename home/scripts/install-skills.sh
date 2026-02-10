#!/usr/bin/env bash
# Skillfile に記載されたスキルを npx skills でインストールする
set -e

# flake.nix から渡される Skillfile のパス
SKILLFILE="$1"

# Skillfile の存在確認
if [ ! -f "$SKILLFILE" ]; then
  echo "Skillfile not found: $SKILLFILE"
  exit 1
fi

# スキルのインストール先
SKILLS_DIR="$HOME/.agents/skills"

# コメント行(#)と空行を除去してスキル一覧を取得
mapfile -t skills < <(rg -v '^\s*(#|$)' "$SKILLFILE")

# 1件ずつグローバルインストール
for skill in "${skills[@]}"; do
  # owner/repo@skill-name の @ 以降をディレクトリ名として取得
  name="${skill##*@}"
  # インストール済みならスキップ
  if [ -d "$SKILLS_DIR/$name" ]; then
    echo "Skipping (already installed): $name"
    continue
  fi
  echo "Installing skill: $skill"
  npx skills add "$skill" -g -y
done

echo "All skills installed."
