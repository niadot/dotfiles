# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

Nix Home Managerを使った個人用dotfiles管理リポジトリ。設定ファイルをシンボリックリンクで管理し、宣言的に環境を構築する。

詳細なセットアップ手順は [docs/setup.md](docs/setup.md) を参照してください。

## ディレクトリ構造

- **`home/`**: Home Manager設定（flake.nix, home.nix）
- **`config/`**: 実際の設定ファイル（ホームディレクトリにシンボリックリンクされる）
- **`docs/`**: 詳細なドキュメント（セットアップ手順など）

## 基本コマンド

### 日常運用（home-manager がインストール済みの場合）

```bash
# 設定の適用
home-manager switch

# 設定の確認（ドライラン）
home-manager build

# フレーク依存関係の更新
cd ~/.config/home-manager && nix flake update
```

### 初期セットアップ（home-manager が未インストールの場合）

```bash
# 設定の適用
nix run home-manager -- switch -b backup

# シェル再起動
exec $SHELL -l
```

## 管理パッケージ

### Nixpkgs から提供されるパッケージ

| カテゴリ | パッケージ |
|---------|-----------|
| シェル | bash |
| Git | git, gh, ghq, lazygit, delta |
| エディタ | neovim |
| 検索 | ripgrep, fd, fzf |
| ユーティリティ | tree, jq, curl, bat, eza |
| 開発環境 | direnv, devenv, bun |

### llm-agents.nix から提供されるパッケージ

| カテゴリ | パッケージ |
|---------|-----------|
| LLM エージェント | opencode, codex, ccusage |

## 有効化されているプログラム

| プログラム | 説明 |
|-----------|------|
| home-manager | Home Manager 本体 |
| claude-code | Claude Code CLI |
| direnv | プロジェクトごとの環境変数管理（nix-direnv 有効） |

## 管理設定ファイル

| ファイル | 管理方法 |
|---------|---------|
| `.bashrc` | mkOutOfStoreSymlink |
| `.config/git/config` | mkOutOfStoreSymlink |
| `.claude/settings.json` | mkOutOfStoreSymlink |
| `.claude/skills` | mkOutOfStoreSymlink |
| `.claude/agents` | mkOutOfStoreSymlink |
| `.codex/config.toml` | mkOutOfStoreSymlink |
| `.codex/skills` | mkOutOfStoreSymlink |

## 設定ファイルの追加フロー

1. `config/`に設定ファイルを配置
2. `home/home.nix`の`home.file`に`mkOutOfStoreSymlink`でリンクを追加
3. `home-manager switch`で反映

## 注意事項

- 認証情報は`*.credentials.json`または`*.local.json`として保存（.gitignoreで除外）
