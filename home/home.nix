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
  ]) ++ (with inputs.llm-agents.packages.${pkgs.system}; [
    # 将来用。。。あとあと使うかも
  ]);

  home.file = {
    ".config/git/config".source = oos "${repoRoot}/config/.config/git/config";
    ".claude/settings.json".source = oos "${repoRoot}/config/.claude/settings.json";
    ".claude/skills".source = oos "${repoRoot}/config/.claude/skills";
    ".claude/agents".source = oos "${repoRoot}/config/.claude/agents";
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
