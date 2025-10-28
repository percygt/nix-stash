{
  description = "My stash of nix overlays";
  nixConfig = {
    extra-substituters = [
      "https://percygtdev.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "percygtdev.cachix.org-1:AGd4bI4nW7DkJgniWF4tS64EX2uSYIGqjZih2UVoxko="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nix-sources.url = "github:percygt/nix-sources";
    nixpkgs.follows = "nix-sources/nixpkgs";
    nixpkgs-stable.follows = "nix-sources/nixpkgs-stable";
    nixpkgs-unstable.follows = "nix-sources/nixpkgs-unstable";
    nixpkgs-master.follows = "nix-sources/nixpkgs-master";

    tmux-switcher.url = "github:percygt/tmux-switcher";
    tmux-nvim.url = "github:aserowy/tmux.nvim";
    tmux-nvim.flake = false;

    hyprlock.url = "github:hyprwm/hyprlock";
    hyprlock.inputs.nixpkgs.follows = "nixpkgs";

    television.url = "github:alexpasmantier/television";
    elephant.url = "github:abenz1267/elephant";
    elephant.inputs.nixpkgs.follows = "nixpkgs";

    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up to date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      # overlays = {};
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
      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
      packages = forAllSystems (pkgs: {
        tmux-switcher = inputs.tmux-switcher.packages."${pkgs.system}".default;
        hyprlock = inputs.hyprlock.packages."${pkgs.system}".default;
        television = inputs.television.packages."${pkgs.system}".default;
        walker = inputs.walker.packages."${pkgs.system}".default;
        elephant = inputs.elephant.packages."${pkgs.system}".default;
        zen-browser = inputs.zen-browser.packages."${pkgs.system}".default;
        zen-browser-beta = inputs.zen-browser.packages."${pkgs.system}".beta;
        zen-browser-twilight = inputs.zen-browser.packages."${pkgs.system}".twilight;
      });
      overlays = {
        default = final: prev: {
          inherit (outputs.packages.${prev.system})
            hyprlock
            television
            walker
            elephant
            zen-browser
            zen-browser-beta
            zen-browser-twilight
            ;
          tmuxPlugins = prev.tmuxPlugins // {
            inherit (outputs.packages.${prev.system}) tmux-switcher;
          };
        };
      };

    };
}
