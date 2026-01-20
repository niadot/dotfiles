# dotfiles

Nix Home Manager を使った個人用 dotfiles。

## 前提条件

- [Nix](https://nixos.org/)（[Determinate Nix](https://github.com/DeterminateSystems/nix-installer) 推奨）
- WSL2 / Linux / macOS

## クイックスタート

このリポジトリの環境を再現する場合：

```bash
git clone https://github.com/niadot/dotfiles.git ~/ghq/github.com/niadot/dotfiles
cd ~/ghq/github.com/niadot/dotfiles/home
nix run home-manager -- switch -b backup --flake .
exec $SHELL -l
```

## 構成

```
dotfiles/
├─ home/      # Home Manager 設定 (flake.nix, home.nix)
├─ config/    # 実際の設定ファイル
│  ├─ .claude/    # Claude Code 設定
│  ├─ .codex/     # Codex 設定
│  └─ .config/    # その他の設定
└─ docs/      # ドキュメント
```

## インストール済みパッケージ

**シェル・Git**: bash, git, gh, ghq, lazygit, delta
**エディタ**: neovim
**検索**: ripgrep, fd, fzf
**ユーティリティ**: tree, jq, curl, bat, eza
**開発環境**: direnv（nix-direnv）, devenv, bun
**LLM エージェント**: claude-code, opencode, codex, ccusage

## 日常運用

| 操作 | コマンド |
|------|---------|
| 設定を適用 | `home-manager switch` |
| 依存関係を更新 | `nix flake update --flake home` |
| 古い世代を削除 | `nix-collect-garbage -d` |

## ドキュメント

- [詳細なセットアップ手順](docs/setup.md) - Nix 初心者向けガイド
