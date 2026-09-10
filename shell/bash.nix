{ ... }:

{
  programs.bash = {
    enable = true;
    # シェル本体は Ubuntu 標準のものを使う。
    package = null;

    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    historySize = 100000;
    historyFileSize = 100000;

    shellOptions = [
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
    ];

    initExtra = builtins.readFile ./common.sh;
  };
}
