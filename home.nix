{
  config,
  pkgs,
  inputs,
  ...
}:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  dotfiles = "${config.home.homeDirectory}/ghq/github.com/niadot/dotfiles";

  # store を経由しない symlink。編集が switch なしで反映される代わりに、
  # 世代をロールバックしても中身は戻らない（git で戻すこと）。
  mkLink =
    relPath:
    config.lib.file.mkOutOfStoreSymlink (if relPath == "" then dotfiles else "${dotfiles}/${relPath}");
in
{
  home.username = "nia";
  # homeDirectory は hosts/*.nix

  # 初回セットアップ時の値。動かさないこと
  home.stateVersion = "26.05";

  home.packages =
    (with pkgs; [
      # 基本CLI
      bat
      curl
      fd
      jq
      ripgrep

      # 開発ランタイムと環境
      bun
      devenv
      nodejs
      pnpm
      python3

      # Git / GitHub
      gh
      ghq
      lazygit

      # エディタとセッション
      neovim
      tmux

      # 秘密情報
      _1password-cli
    ])
    ++ (with llmAgents; [
      codex
      opencode
    ]);

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less -FR";
  };

  # XDG_{CONFIG,CACHE,DATA,STATE,BIN}_HOME を home.sessionVariables に入れる
  xdg.enable = true;

  home.shellAliases = {
    grep = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";

    ls = "eza";
    ll = "eza -l --git";
    la = "eza -la --git";
    lt = "eza --tree";
    l = "eza -1";

    gs = "git status -sb";
  };

  # XDG に対応していないものだけ home.file に置く
  home.file = {
    # claude / codex は独自ディレクトリ固定
    ".claude/settings.json".source = mkLink "claude/settings.json";
    ".codex/config.toml".source = mkLink "codex/config.toml";

    # エージェント共通のスキル。読む側が違うので 2 箇所に同じ実体を張る
    ".agents/skills".source = mkLink "skills";
    ".claude/skills".source = mkLink "skills";
  };

  xdg.configFile = {
    "home-manager".source = mkLink "";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "niadot";
        email = "18033425+niadot@users.noreply.github.com";
      };
      merge.conflictStyle = "zdiff3";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      ghq.root = "~/ghq";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza.enable = true;

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f";
    fileWidget.command = "fd --type f";
    changeDirWidget.command = "fd --type d";
  };

  programs.uv.enable = true;

  programs.zoxide.enable = true;

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
  };

  services.home-manager.autoExpire = {
    enable = true;
    timestamp = "-30 days";
  };
}
