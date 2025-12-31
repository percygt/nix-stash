{
  description = "My stash of nix overlays";
  nixConfig = {
    extra-substituters = [
      "https://percygtdev.cachix.org"
      "https://nix-community.cachix.org"
      "https://watersucks.cachix.org"
    ];
    extra-trusted-public-keys = [
      "percygtdev.cachix.org-1:AGd4bI4nW7DkJgniWF4tS64EX2uSYIGqjZih2UVoxko="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
    ];
  };

  inputs = {
    nix-sources.url = "github:percygt/nix-sources";
    nixpkgs.follows = "nix-sources/nixpkgs";
    nixpkgs-stable.follows = "nix-sources/nixpkgs-stable";
    nixpkgs-unstable.follows = "nix-sources/nixpkgs-unstable";
    nixpkgs-master.follows = "nix-sources/nixpkgs-master";

    nixos-cli.url = "github:nix-community/nixos-cli";
    emacs-overlay.url = "github:nix-community/emacs-overlay/";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

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

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

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
      overlays = {
        emacs = inputs.emacs-overlay.overlays.default;
        neovim-nightly = inputs.neovim-nightly-overlay.overlays.default;
        fenix = inputs.fenix.overlays.default;
      };
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
                overlays = builtins.attrValues overlays;
                config.allowUnfree = true;
              }
            )
          ))
        );
      forAllSystems = packagesFrom inputs.nixpkgs;
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
      packages = forAllSystems (
        pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
        in
        {
          tmux-switcher = inputs.tmux-switcher.packages."${system}".default;
          hyprlock = inputs.hyprlock.packages."${system}".default;
          television = inputs.television.packages."${system}".default;

          walker = inputs.walker.packages."${system}".default;
          elephant = inputs.elephant.packages."${system}".default;

          zen-browser = inputs.zen-browser.packages."${system}".default;
          zen-browser-beta = inputs.zen-browser.packages."${system}".beta;
          zen-browser-twilight = inputs.zen-browser.packages."${system}".twilight;

          ghostty = pkgs.callPackage ({ ghostty }: ghostty) { };
          tilix = pkgs.callPackage ({ tilix }: tilix) { };
          xfce4-terminal = pkgs.callPackage ({ xfce }: xfce.xfce4-terminal) { };
          wezterm = pkgs.callPackage ({ wezterm }: wezterm) { };
          foot = pkgs.callPackage ({ foot }: foot) { };

          cctv-viewer = pkgs.callPackage ({ cctv-viewer }: cctv-viewer) { };
          universal-android-debloater = pkgs.callPackage (
            { universal-android-debloater }: universal-android-debloater
          ) { };
          emacs-unstable = pkgs.callPackage (
            { emacs-unstable }:
            emacs-unstable.override {
              withTreeSitter = true;
            }
          ) { };
          emacs-pgtk = pkgs.callPackage (
            { emacs-pgtk }:
            emacs-pgtk.override {
              withTreeSitter = true;
            }
          ) { };
          emacs-unstable-pgtk = pkgs.callPackage (
            { emacs-unstable-pgtk }:
            emacs-unstable-pgtk.override {
              withTreeSitter = true;
            }
          ) { };
          neovim-unstable = pkgs.callPackage ({ neovim }: neovim) { };
          nixos-cli = inputs.nixos-cli.packages.${system}.default;

          rust-analyzer-nightly = inputs.fenix.packages.${system}.rust-analyzer;
          rust-minimal-toolchain = inputs.fenix.packages.${system}.minimal.toolchain;
        }
      );
      overlays = {
        default =
          final: prev:
          let
            inherit (prev.stdenv.hostPlatform) system;
          in
          {
            inherit (outputs.packages.${system})
              rust-analyzer-nightly
              rust-minimal-toolchain
              emacs-unstable
              emacs-pgtk
              emacs-unstable-pgtk
              neovim-unstable
              nixos-cli
              cctv-viewer
              hyprlock
              television
              walker
              elephant
              zen-browser
              zen-browser-beta
              zen-browser-twilight

              foot
              ghostty
              tilix
              xfce4-terminal
              wezterm
              ;
            tmuxPlugins = prev.tmuxPlugins // {
              inherit (outputs.packages.${system}) tmux-switcher;
            };
          };
      };

    };
}
