{
  description = "niadot's dotfiles / Home Manager configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://ryoppippi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # follows しない。cache.numtide.com のバイナリが自身の nixpkgs 前提のため
    llm-agents.url = "github:numtide/llm-agents.nix";

    nix-claude-code = {
      url = "github:ryoppippi/nix-claude-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-claude-code,
      ...
    }@inputs:
    let
      # x86_64-darwin は llm-agents が非対応
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (mkPkgs system));

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ nix-claude-code.overlays.default ];
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "1password-cli"
              "claude"
            ];
        };

      mkHome =
        system: hostModule:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home.nix
            hostModule
          ];
        };

      wslHome = mkHome "x86_64-linux" ./hosts/wsl.nix;
      linuxHome = mkHome "x86_64-linux" ./hosts/linux.nix;
      macHome = mkHome "aarch64-darwin" ./hosts/mac.nix;
    in
    {
      homeConfigurations = {
        "nia@wsl" = wslHome;
        "nia@linux" = linuxHome;
        "nia@mac" = macHome;
      };

      checks = {
        x86_64-linux = {
          home-wsl = wslHome.activationPackage;
          home-linux = linuxHome.activationPackage;
        };
        aarch64-darwin.home-mac = macHome.activationPackage;
      };

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
