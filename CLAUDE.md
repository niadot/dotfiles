# CLAUDE.md

Nix Home Managerを使った個人用dotfiles管理リポジトリ。

## ディレクトリ構造

```
home/       Home Manager設定（flake.nix, home.nix）
config/     設定ファイル（ホームディレクトリにシンボリックリンク）
docs/       ドキュメント
```

## よく使うコマンド

```bash
home-manager switch              # 設定を適用
home-manager build               # ドライラン
nix flake update                 # 依存関係を更新（home/で実行）
```

## 設定ファイルの追加方法

1. `config/` に設定ファイルを配置
2. `home/home.nix` の `home.file` に `mkOutOfStoreSymlink` でリンクを追加
3. `home-manager switch` で反映

## 管理している設定ファイル

- `.bashrc`
- `.config/git/config`
- `.claude/settings.json`, `.claude/skills`, `.claude/agents`
- `.codex/config.toml`, `.codex/skills`

## インストール済みパッケージ

**シェル・Git**: bash, git, gh, ghq, lazygit, delta
**エディタ**: neovim
**検索**: ripgrep, fd, fzf
**ユーティリティ**: tree, jq, curl, bat, eza
**開発環境**: direnv（nix-direnv有効）, devenv, bun
**LLMエージェント**: claude-code, opencode, codex, ccusage

## 注意事項

- 認証情報は `*.credentials.json` または `*.local.json` として保存（.gitignore で除外済み）
- 詳細なセットアップ手順は [docs/setup.md](docs/setup.md) を参照
