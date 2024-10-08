{
  description = "My stash of nix overlays";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nix-sources.url = "github:percygt/nix-sources";
    nixpkgs.follows = "nix-sources/nixpkgs";
    nixpkgs-stable.follows = "nix-sources/nixpkgs-stable";
    nixpkgs-master.follows = "nix-sources/nixpkgs-master";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    keepmenu.url = "github:percygt/keepmenu";
    keepmenu.inputs.nixpkgs.follows = "nixpkgs";

    # aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    # aagl.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:guibou/nixgl";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    yaml2nix.url = "github:euank/yaml2nix";
    yaml2nix.inputs.nixpkgs.follows = "nixpkgs";

    tmuxinoicer.url = "github:percygt/tmuxinoicer";
    fzf-url = {
      url = "github:wfxr/tmux-fzf-url";
      flake = false;
    };
  };
  outputs =
    { self, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      # overlays = [ ];
      forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
      packagesFrom =
        inputs-nixpkgs:
        (
          function:
          (forEachSystem (
            system:
            function (
              import inputs-nixpkgs {
                inherit system;
                # overlays = builtins.attrValues overlays;
                config.allowUnfree = true;
              }
            )
          ))
        );
      forAllSystems = packagesFrom inputs.nixpkgs;
    in
    {
      packages = forAllSystems (pkgs: import ./packages { inherit pkgs inputs; });
      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
      overlays = import ./overlays { inherit inputs outputs; };
    };
}
