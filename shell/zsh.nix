{ config, ... }:

{
  programs.zsh = {
    enable = true;
    # シェル本体と基本の見た目は macOS 標準のものを使う。
    package = null;

    autocd = true;
    setOptions = [
      "EXTENDED_GLOB"
      "AUTO_LIST"
      "INC_APPEND_HISTORY"
    ];

    history = {
      append = true;
      ignoreDups = true;
      ignoreSpace = true;
      path = "${config.home.homeDirectory}/.zsh_history";
      save = 100000;
      share = false;
      size = 100000;
    };

    initContent = ''
      ${builtins.readFile ./common.sh}

      [ -n "$LS_COLORS" ] && zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu select
    '';
  };
}
