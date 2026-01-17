# dotfiles

Nix Home Manager を使った個人用 dotfiles。

詳細なセットアップ手順は [docs/setup.md](docs/setup.md) を参照してください。

## クイックスタート

このリポジトリの環境を再現する場合：

```bash
git clone https://github.com/niadot/dotfiles.git ~/ghq/github.com/niadot/dotfiles
cd ~/ghq/github.com/niadot/dotfiles/home
nix run home-manager -- switch -b backup --flake .
exec $SHELL -l
```

## 使い方

- 設定変更後: `home-manager switch -b backup`
- 依存更新: `nix flake update --flake home`

## 構成

```
dotfiles/
├─ home/      # Home Manager 設定 (flake.nix, home.nix)
├─ config/    # 実際の設定ファイル
│  ├─ .claude/    # OpenCode 設定
│  ├─ .codex/     # Codex 設定
│  └─ .config/    # その他の設定
└─ docs/      # ドキュメント
```

## 主なパッケージ

- `opencode`: AI コーディングエージェント
- `codex`: AI コーディングアシスタント
- `neovim`: エディタ
- `lazygit`: Git TUI
- `ripgrep`, `fd`, `fzf`: 検索ツール
