{ ... }:

{
  imports = [ ../shell/bash.nix ];

  home.homeDirectory = "/home/nia";
  home.sessionVariables.HM_TARGET = "nia@linux";

  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };
}
