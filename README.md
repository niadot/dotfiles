# dotfiles

Nix Home Managerを使った個人用dotfiles。

## 必要条件

- Nix（Determinate Systems推奨）
- Home Manager

## インストール

1. リポジトリをクローン
2. `cd home && home-manager switch`

## 使い方

- 設定変更後: `home-manager switch`
- 依存更新: `nix flake update --flake home`