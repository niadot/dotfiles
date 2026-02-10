# CLAUDE.md

Nix Home Managerを使った個人用dotfiles管理リポジトリ。

## ディレクトリ構造

```
home/              Home Manager設定（flake.nix, home.nix）
home/scripts/      セットアップスクリプト（install-skills.sh）
config/            設定ファイル（ホームディレクトリにシンボリックリンク）
config/.agents/    エージェントスキル共通ディレクトリ（Skillfile, skills/）
docs/              ドキュメント
```

## よく使うコマンド

```bash
nix run ./home#setup             # 初回セットアップ
nix run ./home#update            # 依存関係の更新＋設定適用
nix run ./home#skills            # Skillfile に基づくスキルインストール
nix run ./home#cleanup           # 古い世代の削除＋ガベージコレクション
home-manager switch              # 設定のみ適用
home-manager build               # ドライラン
```

## home.nix の構造

```nix
# パッケージ追加
home.packages = (with pkgs; [
  パッケージ名
]) ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
  # llm-agents flakeからのパッケージ
]);

# シンボリックリンク追加
home.file = {
  ".config/app/config".source = oos "${repoRoot}/config/.config/app/config";
};

# プログラム設定
programs.アプリ名 = {
  enable = true;
};
```

## よくある作業パターン

### パッケージを追加する
1. `home/home.nix` の `home.packages` にパッケージ名を追加
2. `home-manager switch` で適用

### 設定ファイルを追加する
1. `config/` に設定ファイルを配置
2. `home/home.nix` の `home.file` に `oos` でリンクを追加
3. `home-manager switch` で適用

### 依存関係を更新する
1. `nix run ./home#update` で更新＋適用

## 管理している設定ファイル

- `.bashrc`
- `.config/git/config`
- `.agents/skills` — エージェントスキル共通ディレクトリ（Skillfile で宣言的に管理）
- `.claude/settings.json`, `.claude/skills`（→ `.agents/skills` と同じ実体）
- `.codex/config.toml`

## インストール済みパッケージ

**シェル・Git**: bash, git, gh, ghq, lazygit, delta
**エディタ**: neovim
**検索**: ripgrep, fd, fzf
**ユーティリティ**: tree, jq, curl, bat, eza
**開発環境**: direnv（nix-direnv有効）, devenv, nodejs_latest, pnpm, bun
**LLMエージェント**: claude-code, opencode, codex, ccusage

## 注意事項

- 認証情報は `*.credentials.json` または `*.local.json` として保存（.gitignore で除外済み）
- 詳細なセットアップ手順は [docs/setup.md](docs/setup.md) を参照
- Home Manager の詳細な操作は [home/CLAUDE.md](home/CLAUDE.md) を参照
