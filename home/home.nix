{ config, pkgs, inputs, lib, ... }:

let
  repoRoot = "${config.home.homeDirectory}/ghq/github.com/niadot/dotfiles";
  oos = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.username = "nia";
  home.homeDirectory = "/home/nia";
  home.stateVersion = "25.11"; # Please read the comment before changing.

  home.packages = (with pkgs; [
    # シェル
    bash
    # エディタ
    neovim
    # Git
    git
    gh
    ghq
    lazygit
    delta
    # 検索・ファイル操作
    ripgrep
    fd
    fzf
    tree
    # ユーティリティ
    jq
    curl
    bat
    eza
    # 開発環境
    devenv
    bun
  ]) ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    # LLM エージェント
    ccusage
    codex
  ]);

  home.file = {
    ".bashrc".source = oos "${repoRoot}/config/.bashrc";
    ".config/git/config".source = oos "${repoRoot}/config/.config/git/config";
    ".claude/settings.json".source = oos "${repoRoot}/config/.claude/settings.json";
    ".claude/skills".source = oos "${repoRoot}/config/.claude/skills";
    ".claude/agents".source = oos "${repoRoot}/config/.claude/agents";
    ".codex/config.toml".source = oos "${repoRoot}/config/.codex/config.toml";
    ".codex/skills".source = oos "${repoRoot}/config/.codex/skills";
  };

  home.sessionVariables = {
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
