# CLAUDE.md - Home Manager設定

This file provides guidance to Claude Code (claude.ai/code) when working with code in this directory.

## ファイル構成

- **flake.nix**: Nixフレーク定義。依存関係（nixpkgs, home-manager, claude-code-overlay等）を管理
- **home.nix**: Home Manager設定本体。パッケージ、シンボリックリンク、プログラム設定を定義

## flake.nix の構造

### inputs（依存関係）

| input | 説明 |
|-------|------|
| nixpkgs | Nix パッケージコレクション（unstable） |
| home-manager | ユーザー環境管理 |
| claude-code-overlay | Claude Code パッケージ提供 |
| llm-agents | LLM エージェントツール（codex, opencode, ccusage） |

### nixConfig（キャッシュ設定）

llm-agents.nix 用のバイナリキャッシュを設定。
ビルド時間を短縮するため、信頼済みキャッシュからダウンロード。

### overlays

`claude-code-overlay` を適用して `pkgs.claude-code` を利用可能に。

### allowUnfreePredicate

claude パッケージのみ unfree を許可。

### apps（セットアップ・更新コマンド）

`nix run` で実行できるコマンドを定義。

| app | 説明 |
|-----|------|
| setup | 初回セットアップ用。`nix run home-manager` 経由で `home-manager switch` を実行 |
| update | `nix flake update` + `home-manager switch` を一括実行 |
| cleanup | 現行以外の全世代を削除 + `nix-collect-garbage` を実行 |

## home.nix の構造

### シンボリックリンク

`mkOutOfStoreSymlink`を使用して、Nixストア外のファイルへのシンボリックリンクを作成：

```nix
repoRoot = "${config.home.homeDirectory}/ghq/github.com/niadot/dotfiles";
oos = config.lib.file.mkOutOfStoreSymlink;

home.file = {
  ".config/git/config".source = oos "${repoRoot}/config/.config/git/config";
};
```

これにより、設定ファイルを直接編集でき、`home-manager switch`なしで即座に反映される。

### リンク確認方法

```bash
# 最終リンク先を確認（Nixストアを経由しても実ファイルを指す）
readlink -f ~/.config/git/config
```

## よく使うコマンド

```bash
# 初回セットアップ（home-manager未インストール時）
nix run .#setup

# 依存関係の更新＋設定適用
nix run .#update

# 古い世代の削除＋ガベージコレクション
nix run .#cleanup

# 設定のみ適用
home-manager switch

# 設定の確認（ドライラン）
home-manager build

# 特定のインプットのみ更新
nix flake lock --update-input nixpkgs
```

## パッケージの追加方法

### nixpkgs からのパッケージ

```nix
home.packages = with pkgs; [
  ripgrep
  fd
];
```

### llm-agents からのパッケージ

```nix
home.packages = (with pkgs; [
  # ...
]) ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
  codex
  opencode
]);
```

### programs モジュール経由

```nix
programs.claude-code = {
  enable = true;
  package = pkgs.claude-code;
};
```

## 設定ファイルの追加手順

1. **設定ファイルを`config/`に配置**
   ```bash
   mkdir -p ../config/.config/アプリ名
   ```

2. **`home.nix`の`home.file`にシンボリックリンク定義を追加**
   ```nix
   ".config/アプリ名/config".source = oos "${repoRoot}/config/.config/アプリ名/config";
   ```

3. **適用**
   ```bash
   home-manager switch
   ```

## トラブルシューティング

### 既存ファイルとの競合

```
error: existing file '...' is in the way
```

既存ファイルを削除またはバックアップしてから `home-manager switch` を再実行。

### ビルドエラー

```bash
# キャッシュをクリアして再ビルド
nix-collect-garbage
home-manager switch
```

### パッケージが見つからない

```bash
# nixpkgs でパッケージを検索
nix search nixpkgs パッケージ名
```

## 注意事項

- 既存のファイル/ディレクトリがあると`home-manager switch`がエラーになる場合がある。その場合は既存のものを削除してから再実行
- `programs.claude-code.enable = true`でClaude CodeがHome Manager経由で管理されている
