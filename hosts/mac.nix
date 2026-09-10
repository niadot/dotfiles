{ ... }:

{
  imports = [ ../shell/zsh.nix ];

  home.homeDirectory = "/Users/nia";
  home.sessionVariables.HM_TARGET = "nia@mac";
}
