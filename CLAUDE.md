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

# フレーク依存関係の更新
nix flake update --flake home
```

## 注意事項

- 認証情報は`*.credentials.json`または`*.local.json`として保存（.gitignoreで除外）
- 各サブディレクトリに専用のCLAUDE.mdがある場合、そちらに詳細情報がある
