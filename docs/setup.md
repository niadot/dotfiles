# Nix + Home Manager 入門ガイド

## 目次

- [1. 概要](#1-概要)
- [2. クイックスタート: 既存環境の復元](#2-クイックスタート-既存環境の復元)
- [3. 初回構築](#3-初回構築)
- [4. 日常運用](#4-日常運用)
- [5. トラブルシューティング](#5-トラブルシューティング)

## 1. 概要

このドキュメントでは Nix + Home Manager を使って **再現性の高い dotfiles を構築する** 手順を説明する。

**dotfiles** とは、`.bashrc` や `.config/git/config` などホームディレクトリに配置される設定ファイルを管理するリポジトリである。Git で管理することで、どの環境でも同じ開発環境を一瞬で再現できる。

- **対象**: Windows + WSL2 (Ubuntu)
- **前提**: Nix/Home Manager の経験がない、または浅い方（初心者〜中級者）
- **ゴール**: 同じ CLI 環境が再現できる dotfiles を構築する

### 1.1 ディレクトリ構成

最終的に以下の構成を目指す。

```text
dotfiles/
├─ home/         # Home Manager の設定本体
│  ├─ flake.nix
│  ├─ home.nix
│  └─ flake.lock
├─ config/       # ~ に配置される設定ファイルの実体
│  ├─ .bashrc
│  ├─ .config/git/config
│  ├─ .claude/...
│  └─ .codex/...
└─ .gitignore
```

### 1.2 プレースホルダー

| プレースホルダー | 例 |
|----------------|-----|
| `<linux_user>` | nia |
| `<github_user>` | niadot |
| `<distro_name>` | NixDev |
| `<email>` | user@example.com |

### 1.3 参考リンク

- [Nix 公式ドキュメント](https://nixos.org/manual/nix/stable/)
- [Home Manager 公式ドキュメント](https://nix-community.github.io/home-manager/)
- [search.nixos.org](https://search.nixos.org/packages)

## 2. クイックスタート: 既存環境の復元

既存の dotfiles リポジトリから環境を復元する場合の手順である。  
[3.1 WSL 導入](#31-wsl-の導入と更新) 〜 [3.3 trusted-users 設定](#33-trusted-users-の設定)、[3.5 Git/SSH 初期設定](#35-gitssh-の初期設定) を済ませた状態を想定する。

```bash
# GitHub ユーザー名を宣言
export GITHUB_USER=<github_user>
# dotfiles リポジトリをクローン
nix-shell -p git ghq --run "ghq get -p $GITHUB_USER/dotfiles"
# Home Manager 設定にシンボリックリンクを作成
ln -s "$HOME/ghq/github.com/$GITHUB_USER/dotfiles/home" ~/.config/home-manager
# Home Manager を適用（既存ファイルを backup に退避）
nix run home-manager -- switch -b backup

# シェルを再起動して変更を反映
exec $SHELL -l
```

## 3. 初回構築

新しい環境を構築する場合の手順である。

### 3.1 WSL の導入と更新

WSL 上で Nix と Home Manager を動かすため、まず Linux を用意する。  
PowerShell を管理者権限で起動し、WSL を導入する。  
インストール完了後に WSL を再起動し、パッケージを更新して環境を整える。

```powershell
wsl --install -d Ubuntu --name <distro_name>
```

インストールが完了すると Ubuntu が起動してユーザー名とパスワードを聞かれる。

```powershell
wsl --shutdown
wsl ~ -d <distro_name>
```

```bash
sudo apt update && sudo apt upgrade -y
```

### 3.2 Nix のインストール（Determinate Nix）

Determinate Nix はマルチユーザー構成で安定運用できる。  
Home Manager を前提にする場合に相性が良い。  
途中で確認が出たら Yes で進める。  
導入後はシェルを再起動し、`nix --version` で導入の成功を確認する。

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
exec $SHELL -l
nix --version
```

### 3.3 trusted-users の設定

flake.nix で指定するキャッシュサーバーを利用するため、Nix の trusted-users に自分のユーザーを追加する。  
反映には Nix デーモンの再起動が必要なため、WSL を再起動する。

```bash
echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.custom.conf
exit
```

```powershell
wsl --shutdown
wsl ~ -d <distro_name>
```

### 3.4 Home Manager の初期化

Home Manager を初期化して設定ファイルを生成する。  
`~/.config/home-manager/` に `flake.nix` と `home.nix` が作られる。  
以降はこれらを編集してパッケージや設定を管理する。  
初回は生成を確認できれば十分である。

```bash
nix run home-manager/master -- init
# GitHub ユーザー名を変数として宣言
export GITHUB_USER=<github_user>
```

### 3.5 Git/SSH の初期設定

dotfiles を GitHub で管理するため、Git と SSH を初期設定する。  
`.gitconfig` ではなく XDG 準拠の `~/.config/git/config` を使う。  
GitHub CLI (gh) を使って SSH 鍵の生成と GitHub 登録を行う。

```bash
# Git 設定ファイルの準備
mkdir -p ~/.config/git && touch ~/.config/git/config
# Git ユーザー設定
git config --global user.name "$GITHUB_USER"
git config --global user.email "<email>"
git config --global init.defaultBranch main
# GitHub SSH 認証設定
nix-shell -p gh openssh --run "gh auth login -p ssh -w"
nix-shell -p openssh --run "ssh -T git@github.com"
```

**対話の流れ**:

1. `GitHub.com` を選択
2. `SSH` を選択
3. `Upload an SSH key?` で `Yes` を選択
4. パスフレーズを入力（空でも可）
5. SSH 鍵のタイトルは Enter を押してデフォルト（ホスト名）を使用
6. ブラウザが開き、GitHub で認証

### 3.6 flake.nix の編集

Nix フレークの設定を記述して、パッケージリポジトリと Home Manager、LLM エージェントを定義する。

`~/.config/home-manager/flake.nix` を編集してください。以下を参考に：

```nix
{
  description = "Home Manager configuration of <linux_user>";

  nixConfig = {
    # ビルド高速化用のキャッシュ設定
    extra-substituters = [
      "https://cache.nixos.org"
      "https://ryoppippi.cachix.org"
    ];
    # 上記キャッシュの公開鍵
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="
    ];
  };

  inputs = {
    # Home Manager と追加 overlay の入力
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { nixpkgs, home-manager, claude-code-overlay, llm-agents, ... }@inputs:
    let
      system = "x86_64-linux";
      # 標準では legacyPackages を使うが、オプションを渡せないため import nixpkgs を使う
      pkgs = import nixpkgs {
        inherit system;
        # Claude Code を許可 (unfree)
        config.allowUnfreePredicate =
          pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude" ];
        # Claude Code を overlay で追加
        overlays = [ claude-code-overlay.overlays.default ];
      };
    in {
      homeConfigurations."<linux_user>" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # llm-agents を home.nix に渡す
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
}
```

### 3.7 home.nix の編集と反映

インストールするパッケージとプログラムの設定を記述する。

`~/.config/home-manager/home.nix` を編集してください。以下を参考に：

```nix
{ config, pkgs, inputs, ... }:

{
  home.username = "<linux_user>";
  home.homeDirectory = "/home/<linux_user>";
  home.stateVersion = "25.11";

  home.packages = (with pkgs; [
    # 基本的な CLI ツール
    git          # リポジトリ管理
    bash         # 既定シェル
    gh           # GitHub CLI
    ghq          # リポジトリの整理と取得
    curl         # 外部スクリプト取得
    devenv       # 開発環境の再現 (devenv.nix)

    # 開発支援ツール
    ripgrep      # grep のモダンな代替
    fd           # find のモダンな代替
    fzf          # 対話的フィルタ
    tree         # ディレクトリ構造表示
    bat          # cat のモダンな代替
    eza          # ls のモダンな代替
    jq           # JSON 処理

    # Git 関連
    lazygit      # Git の TUI
    delta        # Git diff ビューア

    # エディタ
    neovim       # モダンな Vim 派生エディタ

    # 環境管理
    direnv       # プロジェクトごとの環境切り替え
    bun          # JavaScript ランタイム
  ]) ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    # llm-agents.nix から導入
    opencode     # Claude Code エージェント
    codex        # Claude Code エージェント
    ccusage      # Claude Code 使用状況ツール
  ]);

  home.file = {
    # ここは後の手順で追記する
  };

  programs.home-manager.enable = true;

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

設定を反映して CLI ツールを揃える。  
ターミナルを再起動し、git が Nix 経由のものに切り替わったか確認する。

```bash
nix run home-manager -- switch -b backup
exec $SHELL -l
which git
```

### 3.8 dotfiles リポジトリ化と config/ 移行

Home Manager 設定を Git で管理し、設定ファイルの実体を `config/` 配下に集約する。

GitHub で dotfiles リポジトリを作成する。  
[https://github.com/new](https://github.com/new) を開き、以下の設定で作成する。

- Repository name: `dotfiles`
- Add a README file: チェック（main ブランチ作成のため）
- .gitignore: **Linux**
- License: MIT（推奨）

作成後にリポジトリをクローンし、Home Manager 設定を移動する。

```bash
# リポジトリをクローン
ghq get -p "$GITHUB_USER/dotfiles"
cd "$HOME/ghq/github.com/$GITHUB_USER/dotfiles"

# home ディレクトリを作成して設定を移動
mkdir -p home && mv ~/.config/home-manager/* home/ && rm -r ~/.config/home-manager

# Home Manager 設定のシンボリックリンクを作成
ln -s "$HOME/ghq/github.com/$GITHUB_USER/dotfiles/home" ~/.config/home-manager

# .gitignore に追記（ローカル設定やビルド結果を除外）
cat << 'EOF' >> .gitignore
# dotfiles 固有ルール
*.credentials.json
*.local.json
.env
result
result-*
EOF

# config ディレクトリを作成して設定ファイルを移動
mkdir -p config/.config/git && mv ~/.config/git/config config/.config/git/config

# Claude Code 設定ディレクトリを作成（設定ファイルは後で作ったら移動）
mkdir -p config/.claude/{skills,agents}
# 既存の .bashrc があれば移動（なければ空ファイルを作成）
if [ -f ~/.bashrc ]; then
  mv ~/.bashrc config/.bashrc
else
  touch config/.bashrc
fi
```

`~/.config/home-manager/home.nix` を編集してください。以下を参考に：

Claude Code の設定ファイルを作成した場合は、`config/.claude/` に移動して以下を追記してください。

```nix
{ config, pkgs, inputs, lib, ... }:

let
  # dotfiles リポジトリの位置
  repoRoot = "${config.home.homeDirectory}/ghq/github.com/<github_user>/dotfiles";
  # Nix ストア外のファイルへリンクするためのヘルパー
  oos = lib.file.mkOutOfStoreSymlink;
in
{
  # ... (他の設定はそのまま)

  home.file = {
    ".bashrc".source = oos "${repoRoot}/config/.bashrc";
    ".config/git/config".source = oos "${repoRoot}/config/.config/git/config";
    ".claude/settings.json".source = oos "${repoRoot}/config/.claude/settings.json";
    ".claude/skills".source = oos "${repoRoot}/config/.claude/skills";
    ".claude/agents".source = oos "${repoRoot}/config/.claude/agents";
  };
}
```

設定を反映して Git に保存する。  
ここまでの状態が「再現可能な基準点」である。

```bash
home-manager switch -b backup
git add .
git commit -m "Initial dotfiles setup with Home Manager"
git push
```

#### 設定ファイルの管理方法

新しく設定ファイルを追加する場合は、以下の手順で管理します。

1. **CLI ツールの設定コマンドやエディタで設定ファイルを作成する**
   - 例: `gh config set editor nvim` → `~/.config/gh/config.yml` に作成
   - 例: `lazygit config file.openCommand "code {{filename}}"` → `~/.config/lazygit/config.yml` に作成
   - 例: エディタで `~/.config/tool/config.toml` を直接編集

2. **作成した設定ファイルを config/ に移動する**
   - 例: `mv ~/.config/gh/config.yml config/.config/gh/config.yml`
   - 例: `mv ~/.config/lazygit/config.yml config/.config/lazygit/config.yml`

3. **home.nix の home.file に追記する**
   ```nix
   home.file = {
     ".config/gh/config.yml".source = oos "${repoRoot}/config/.config/gh/config.yml";
     ".config/lazygit/config.yml".source = oos "${repoRoot}/config/.config/lazygit/config.yml";
   };
   ```

4. **反映する**
   ```bash
   home-manager switch
   ```


## 4. 日常運用

### 4.1 パッケージの追加

`home.nix` にパッケージを追加して反映する。

```bash
vim ~/.config/home-manager/home.nix
home-manager switch
```

### 4.2 Flake の更新

`flake.lock` の更新をコミットして push し、履歴を残す。

```bash
cd ~/.config/home-manager
nix flake update
home-manager switch

git add flake.lock
git commit -m "Update flake dependencies"
git push
```

### 4.3 古いジェネレーションの削除

Home Manager は switch のたびに世代を作成する。  
不要な世代を削除してディスク容量を確保する。

```bash
home-manager expire-generations "-7 days"
nix-collect-garbage
```

`expire-generations "-7 days"` は 1 週間以上前の世代を削除対象にする。  
数字を変えると「N 日前より古い世代」を指定できる（例: `"-0 days"` で現行以外の全世代）。  
`nix-collect-garbage` で参照されなくなったパッケージを実際に削除する。

## 5. トラブルシューティング

### 5.1 既存ファイルがあると失敗する

**症状**: `error: path '/home/user/.bashrc' already exists` というエラーが出る

**原因**: Home Manager は既存ファイルを上書きしない

**対処**:

1. 既存ファイルを `config/` に移動して管理する（推奨）
2. 既存ファイルを削除して再実行
3. `-b backup` オプションで退避する（既存ファイルが `*.backup` になる）

### 5.2 flake update 後にビルドエラー

**症状**: `error: The option 'foo.bar' does not exist` というエラーが出る

**原因**: 依存パッケージの破壊的変更が原因の可能性がある

**対処**:

```bash
# 変更を確認
git diff home/flake.lock

# 前のバージョンに戻す
git checkout home/flake.lock
```

### 5.3 trusted-users が反映されない

**症状**: キャッシュが使われず、毎回ビルドされる

**原因**: Determinate Nix では `/etc/nix/nix.custom.conf` に設定を書く必要がある

**対処**:

```bash
# 設定ファイルを確認
cat /etc/nix/nix.custom.conf

# 設定を追記
echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.custom.conf
exit
```

PowerShell で `wsl --shutdown` して再度ログイン。

### 5.4 macOS でエラーが出る場合

**症状**: Linux 用のコマンドが動かない

**対処**: `flake.nix` の `system` を以下に変更
- Apple Silicon Mac: `system = "aarch64-darwin";`
- Intel Mac: `system = "x86_64-darwin";`

### 5.5 ジェネレーションをロールバックする

新しいジェネレーションに問題がある場合に戻す。

```bash
home-manager generations
home-manager switch --generation <id>
```
