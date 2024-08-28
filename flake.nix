{
  description = "My stash of nix overlays";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://yazi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
    ];
  };

  inputs = {
    nix-sources.url = "github:percygt/nix-sources";
    nixpkgs.follows = "nix-sources/nixpkgs";
    nixpkgs-stable.follows = "nix-sources/nixpkgs-stable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    keepmenu.url = "github:percygt/keepmenu";
    keepmenu.inputs.nixpkgs.follows = "nixpkgs";

    # aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    # aagl.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:guibou/nixgl";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    # yazi = {
    #   url = "github:sxyazi/yazi";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.rust-overlay.follows = "rust-overlay";
    # };
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    # waybar.url = "github:Alexays/Waybar";
    # waybar.inputs.nixpkgs.follows = "nixpkgs";

    yaml2nix.url = "github:euank/yaml2nix";
    yaml2nix.inputs.nixpkgs.follows = "nixpkgs";

    tmuxinoicer.url = "github:percygt/tmuxinoicer";
    fzf-url = {
      url = "github:wfxr/tmux-fzf-url";
      flake = false;
    };
  };
  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
      overlays = {
        nix-vscode-extensions = inputs.nix-vscode-extensions.overlays.default;
      };
      legacyPackages = forEachSystem (
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
      );
    in
    {
      packages = forEachSystem (
        system:
        (import ./packages {
          pkgs = legacyPackages.${system};
          inherit system inputs;
        })
      );
      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
      overlays = import ./overlays { inherit inputs outputs; };
      pkgLib = import ./packages/lib.nix { inherit inputs; };
    };
}
