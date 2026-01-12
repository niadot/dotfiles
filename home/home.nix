{ config, pkgs, inputs, lib, ... }:

let
  repoRoot = "${config.home.homeDirectory}/ghq/github.com/niadot/dotfiles";
  oos = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.username = "nia";
  home.homeDirectory = "/home/nia";
  home.stateVersion = "25.11"; # Please read the comment before changing.

nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "claude" ];

  home.packages = (with pkgs; [
    bash
    git
    gh
    ghq
    neovim
    tree
    # 検索・ファイル操作
    ripgrep
    fd
    fzf
    jq
    curl
    # 表示改善
    bat
    eza
    delta
    # Git TUI
    lazygit
    # Runtime
    bun
  ]) ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
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
    # EDITOR = "emacs";
  };

  programs.home-manager.enable = true;
  
  programs.claude-code.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
