# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

Nix Home Managerを使った個人用dotfiles管理リポジトリ。設定ファイルをシンボリックリンクで管理し、宣言的に環境を構築する。

## ディレクトリ構造

- **`home/`**: Home Manager設定（flake.nix, home.nix）
- **`config/`**: 実際の設定ファイル（ホームディレクトリにシンボリックリンクされる）

## 基本コマンド

```bash
# 設定の適用
home-manager switch

# 設定の確認（ドライラン）
home-manager build

# フレーク依存関係の更新
cd ~/.config/home-manager && nix flake update
# または: nix flake update --flake home (リポジトリルートから)
```

## 管理パッケージ

| カテゴリ | パッケージ |
|---------|-----------|
| シェル | bash |
| Git | git, gh, ghq, lazygit, delta |
| エディタ | neovim |
| 検索 | ripgrep, fd, fzf |
| ユーティリティ | tree, jq, curl, bat, eza |
| 開発環境 | direnv |

## 管理設定ファイル

| ファイル | 管理方法 |
|---------|---------|
| `.bashrc` | mkOutOfStoreSymlink |
| `.config/git/config` | mkOutOfStoreSymlink |
| `.claude/*` | mkOutOfStoreSymlink |

## 注意事項

- 認証情報は`*.credentials.json`または`*.local.json`として保存（.gitignoreで除外）

## 設定ファイルの追加フロー

1. `config/`に設定ファイルを配置
2. `home/home.nix`の`home.file`に`mkOutOfStoreSymlink`でリンクを追加
3. `home-manager switch`で反映
