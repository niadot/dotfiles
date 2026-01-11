# CLAUDE.md - Home Manager設定

This file provides guidance to Claude Code (claude.ai/code) when working with code in this directory.

## ファイル構成

- **flake.nix**: Nixフレーク定義。依存関係（nixpkgs, home-manager, claude-code-overlay等）を管理
- **home.nix**: Home Manager設定本体。パッケージ、シンボリックリンク、プログラム設定を定義

## シンボリックリンクの仕組み

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
# 設定の適用
home-manager switch

# 設定の確認（ドライラン）
home-manager build

# フレーク依存関係の更新
nix flake update

# 特定のインプットのみ更新
nix flake lock --update-input nixpkgs
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

## 注意事項

- 既存のファイル/ディレクトリがあると`home-manager switch`がエラーになる場合がある。その場合は既存のものを削除してから再実行
- `programs.claude-code.enable = true`でClaude CodeがHome Manager経由で管理されている
