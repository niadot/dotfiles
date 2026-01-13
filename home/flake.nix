{
  description = "Home Manager configuration of nia";

  nixConfig = {
    # llm-agents.nix用の設定
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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Claude Code Overlayを追記
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    # llm-agents.nixを追記
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    { nixpkgs, home-manager, claude-code-overlay, llm-agents, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude" ];
        overlays = [ claude-code-overlay.overlays.default ];
      };
    in
    {
      homeConfigurations."nia" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # 追記分 引数を渡す(llm-agents用)
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
}
