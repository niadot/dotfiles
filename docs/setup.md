# Windows + WSL で dotfiles を再現する手順

## 目次

- [1. 概要](#1-概要)
- [2. クイックスタート: 再構築](#2-クイックスタート-再構築)
- [3. 初回構築](#3-初回構築)
- [4. 日常運用](#4-日常運用)
- [5. トラブルシューティング](#5-トラブルシューティング)
- [Appendix](#appendix)

## 1. 概要

### 1.1 対象と目的

対象：**Windows + WSL2 (Ubuntu)**
目的：Nix + Home Manager で dotfiles を構築し、別環境でも同じ CLI 環境を再現できるようにする。

### 1.2 ディレクトリ構成

```text
dotfiles/
├─ home/         # Home Manager 設定 (flake.nix, home.nix)
├─ config/       # ~ に配置される設定ファイルの実体
│  ├─ .bashrc
│  ├─ .config/git/config
│  └─ .claude/...
└─ .gitignore
```

### 1.3 プレースホルダー

| プレースホルダー | 説明 |
|-----------------|------|
| `<DistroName>` | WSL ディストリ名（例: NixDev） |
| `<github_user>` | GitHub ユーザー名 |
| `<email>` | GitHub に紐づくメールアドレス |
| `<linux_user>` | Linux ユーザー名（Nix ファイル内で使用） |

コマンド用に変数を設定する（シェル再起動後は再設定が必要）。

```bash
GITHUB_USER=<github_user>
```

## 2. クイックスタート: 再構築

**既存の dotfiles リポジトリがある場合**の最短パス。

### 2.1 事前準備

以下を先に済ませる:
1. [3.1 WSL 導入](#31-wsl-導入) 〜 [3.3 trusted-users 設定](#33-trusted-users-設定)
2. [3.5 Git/SSH セットアップ](#35-gitssh-セットアップ)（`nix-shell` 版を使用）

### 2.2 クローンと反映

```bash
GITHUB_USER=<github_user>
nix-shell -p git ghq --run "ghq get -p $GITHUB_USER/dotfiles"
ln -s "$HOME/ghq/github.com/$GITHUB_USER/dotfiles/home" ~/.config/home-manager
nix run home-manager -- switch -b backup
exec $SHELL -l
```

`-b backup` は既存ファイルを `*.backup` に退避して上書きする。

## 3. 初回構築

### 3.1 WSL 導入

PowerShell（管理者）で WSL を導入する。

```powershell
wsl --install -d Ubuntu --name <DistroName>
```

ユーザー作成後に `exit` で終了し、再ログインする。

```powershell
wsl ~ -d <DistroName>
```

パッケージを更新する。

```bash
sudo apt update && sudo apt upgrade -y
```

### 3.2 Nix インストール

Determinate Nix を導入する。

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
exec $SHELL -l
nix --version
```

### 3.3 trusted-users 設定

キャッシュ利用のため trusted-users に追加する。

```bash
echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.custom.conf
exit
```

PowerShell で WSL を再起動する。

```powershell
wsl --shutdown
wsl ~ -d <DistroName>
```

### 3.4 Home Manager 初期化

```bash
nix run home-manager/master -- init
```

`~/.config/home-manager/` に `flake.nix` と `home.nix` が生成される。

### 3.5 Git/SSH セットアップ

XDG 準拠の `~/.config/git/config` を使う。

```bash
mkdir -p ~/.config/git && touch ~/.config/git/config
git config --global user.name "<github_user>"
git config --global user.email "<email>"
git config --global init.defaultBranch main
```

`gh auth login` で SSH 鍵の生成から GitHub 登録まで行う。

```bash
nix-shell -p gh openssh --run "gh auth login -p ssh -w"
```

`nix-shell -p <packages>` は一時的にパッケージを利用できる環境を作る。Home Manager 設定前でも任意のコマンドを実行できる。

対話の流れ:
1. GitHub.com を選択
2. SSH を選択
3. SSH 鍵を生成: Yes
4. パスフレーズを入力（空でも可）
5. SSH 鍵のタイトル: Enter でホスト名
6. ブラウザで認証

疎通を確認する。

```bash
nix-shell -p openssh --run "ssh -T git@github.com"
```

### 3.6 Home Manager 設定

既存の `flake.nix` に以下を追記する（Claude Code と LLM エージェントを追加する例）。

```nix
# flake.nix
{
  description = "Home Manager configuration of <linux_user>";

  # === 追記 ===
  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://ryoppippi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # === 追記 ===
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  # === 変更: outputs の引数に claude-code-overlay, llm-agents を追加 ===
  outputs = { nixpkgs, home-manager, claude-code-overlay, llm-agents, ... }@inputs:
    let
      system = "x86_64-linux";
      # === 変更: legacyPackages を import nixpkgs に置き換え ===
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude" ];
        overlays = [ claude-code-overlay.overlays.default ];
      };
    in {
      homeConfigurations."<linux_user>" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # === 追記 ===
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
}
```

`home.nix` を編集する。

```nix
# home.nix
# === 変更: inputs, lib を追加 ===
{ config, pkgs, inputs, lib, ... }:

# === 追記 ===
let
  repoRoot = "${config.home.homeDirectory}/ghq/github.com/<github_user>/dotfiles";
  oos = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.username = "<linux_user>";
  home.homeDirectory = "/home/<linux_user>";
  home.stateVersion = "25.11";

  # === 変更: 空の [] を置き換え ===
  home.packages = (with pkgs; [
    # 最小構成
    git
    gh
    bash
    ghq
    curl
    devenv

    # おすすめ
    ripgrep     # 高速 grep
    fd          # 高速 find
    fzf         # ファジーファインダー
    bat         # cat + シンタックスハイライト
    eza         # モダンな ls
    jq          # JSON パーサー
    tree        # ディレクトリツリー表示
    lazygit     # Git TUI
    delta       # Git diff ハイライト
    neovim      # エディタ
  ]) ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    # llm-agents.nix から導入
    ccusage
    codex
  ]);

  # === 追記 ===
  home.file = {
    # 3.8 で追記する
  };

  programs.home-manager.enable = true;

  # === 追記 ===
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

`oos` (mkOutOfStoreSymlink) の詳細は [Appendix A](#a-mkoutofstoresymlink-について) を参照。

### 3.7 反映

```bash
nix run home-manager -- switch -b backup
exec $SHELL -l
which git  # Nix 経由のパスになれば成功
```

### 3.8 dotfiles リポジトリ化

[GitHub](https://github.com/new) で dotfiles リポジトリを作成する。
- Add a README file: 有効
- .gitignore: Linux
- License: MIT

クローンして Home Manager 設定を移動する。

```bash
ghq get -p "$GITHUB_USER/dotfiles"
cd "$HOME/ghq/github.com/$GITHUB_USER/dotfiles"

mkdir -p home
mv ~/.config/home-manager/* home/
rm -r ~/.config/home-manager
ln -s "$HOME/ghq/github.com/$GITHUB_USER/dotfiles/home" ~/.config/home-manager
```

設定ファイルを `config/` に集約する。

```bash
cat << 'EOF' >> .gitignore
# dotfiles 固有ルール
*.credentials.json
*.local.json
result
result-*
EOF

mkdir -p config/.config/git
mv ~/.config/git/config config/.config/git/config
```

`home.nix` の `home.file` にリンクを追加する。

```nix
home.file = {
  ".bashrc".source = oos "${repoRoot}/config/.bashrc";
  ".config/git/config".source = oos "${repoRoot}/config/.config/git/config";
  ".claude/settings.json".source = oos "${repoRoot}/config/.claude/settings.json";
};
```

反映してコミットする。

```bash
home-manager switch -b backup
git add .
git commit -m "Initial dotfiles setup with Home Manager"
git push
```

## 4. 日常運用

### 4.1 Flake の更新

```bash
cd ~/.config/home-manager
nix flake update
home-manager switch
git add flake.lock && git commit -m "Update flake dependencies" && git push
```

### 4.2 古いジェネレーションの削除

```bash
home-manager expire-generations "-0 days"  # 現行以外を削除
nix-collect-garbage
```

`-7 days` で1週間以上前を指定など、日数は変更可能。

## 5. トラブルシューティング

### 既存ファイルがあると失敗する

Home Manager は既存ファイルを上書きしない。
対処: `config/` に移動するか削除、または `-b backup` で退避する。

### flake update 後にビルドエラー

依存パッケージの破壊的変更が原因の可能性。
対処: `git checkout home/flake.lock` で戻す。

### trusted-users が反映されない

Determinate Nix は `/etc/nix/nix.custom.conf` を使う。
対処: `/etc/nix/nix.conf` ではなく `nix.custom.conf` に追記されているか確認。

## Appendix

### A. mkOutOfStoreSymlink について

`config.lib.file.mkOutOfStoreSymlink` は Nix ストア外のファイルへのシンボリックリンクを作成する。

| 方法 | 動作 |
|-----|------|
| 通常の `source` | Nix ストアにコピー → 編集が反映されない |
| `mkOutOfStoreSymlink` | リポジトリに直接リンク → 編集が即座に反映 |

dotfiles のように頻繁に編集するファイルには `mkOutOfStoreSymlink` を使う。

### B. パッケージの追加方法

`home.packages` に追記して `home-manager switch` で反映する。

```nix
home.packages = with pkgs; [
  ripgrep fd bat eza jq fzf lazygit delta neovim
];
```

### C. devenv の使い方

プロジェクトごとの開発環境を宣言的に管理する。

```bash
cd your-project && devenv init
```

`devenv.nix` の例:

```nix
{ pkgs, ... }:
{
  languages.python.enable = true;
  packages = [ pkgs.curl pkgs.jq ];
}
```

```bash
devenv shell  # 開発環境に入る
```

`direnv` 連携: `.envrc` に `use devenv` と書くとディレクトリ移動で自動有効化。

### D. Claude Code 設定ファイル

`~/.claude/` 配下の設定ファイル:

| パス | 説明 |
|-----|------|
| `settings.json` | モデル、テーマ、動作設定 |
| `skills/` | カスタムスキル定義 |
| `agents/` | カスタムエージェント定義 |
