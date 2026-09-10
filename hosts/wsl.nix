{ config, ... }:

let
  globalInstructions = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ghq/github.com/niadot/dotfiles/claude/CLAUDE.md";
in
{
  imports = [ ../shell/bash.nix ];

  home.homeDirectory = "/home/nia";
  home.sessionVariables.HM_TARGET = "nia@wsl";

  home.file = {
    ".claude/CLAUDE.md".source = globalInstructions;
    ".codex/AGENTS.md".source = globalInstructions;
  };

  # Windows 側の ssh-agent / 1Password の鍵を使う。
  programs.git.settings.core.sshCommand = "ssh.exe";

  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };
}
