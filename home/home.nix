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
    # ターミナルマルチプレクサ
    tmux
    zellij
    # ユーティリティ
    jq
    curl
    bat
    eza
    # 開発環境
    devenv
    nodejs_latest
    pnpm
    bun
  ]) ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    # LLM エージェント
    ccusage
    codex
    opencode
  ]);

  home.file = {
    # シェル
    ".bashrc".source = oos "${repoRoot}/config/.bashrc";
    # Git
    ".config/git/config".source = oos "${repoRoot}/config/.config/git/config";
    # エージェント共通
    ".agents/skills".source = oos "${repoRoot}/config/.agents/skills";
    # Claude Code
    ".claude/settings.json".source = oos "${repoRoot}/config/.claude/settings.json";
    ".claude/skills".source = oos "${repoRoot}/config/.agents/skills";
    # Codex
    ".codex/config.toml".source = oos "${repoRoot}/config/.codex/config.toml";
    # tmux
    ".config/tmux/tmux.conf".source = oos "${repoRoot}/config/.config/tmux/tmux.conf";
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
