# dotfiles

Nix Home Managerを使った個人用dotfiles。

## セットアップ（WSL）

### 1. WSLのインストール

PowerShellで実行：

```powershell
wsl --install -d Ubuntu --name <name>
```

### 2. Nixのインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 3. dotfilesの展開

```bash
git clone https://github.com/niadot/dotfiles.git ~/ghq/github.com/niadot/dotfiles
cd ~/ghq/github.com/niadot/dotfiles/home
nix run home-manager -- switch --flake .
```

## 使い方

- 設定変更後: `home-manager switch`
- 依存更新: `nix flake update --flake home`