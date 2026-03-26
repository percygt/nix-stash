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
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nix-sources.url = "github:percygt/nix-sources";
    nixpkgs.follows = "nix-sources/nixpkgs";
    nixpkgs-stable.follows = "nix-sources/nixpkgs-stable";
    nixpkgs-unstable.follows = "nix-sources/nixpkgs-unstable";
    nixpkgs-master.follows = "nix-sources/nixpkgs-master";

    nixos-cli.url = "github:nix-community/nixos-cli";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    tmux-switcher.url = "github:percygt/tmux-switcher";

    hyprlock.url = "github:hyprwm/hyprlock";

    television.url = "github:alexpasmantier/television";

    elephant.url = "github:abenz1267/elephant";
    elephant.inputs.nixpkgs.follows = "nixpkgs";
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };

    sherlock = {
      url = "github:Skxxtz/sherlock/unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up to date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "";
    };
    statix = {
      url = "github:molybdenumsoftware/statix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { inputs, ... }:
      {
        imports = [ inputs.flake-parts.flakeModules.easyOverlay ];
        perSystem =
          {
            inputs',
            system,
            pkgs,
            pkgs-stable,
            config,
            ...
          }:
          let
            pkgAttrs = {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                inputs.emacs-overlay.overlays.default
                inputs.neovim-nightly-overlay.overlays.default
                inputs.fenix.overlays.default
              ];
            };
          in
          {
            _module.args = {
              pkgs = import inputs.nixpkgs pkgAttrs;
              pkgs-stable = import inputs.nixpkgs-stable pkgAttrs;
            };
            overlayAttrs.stax = config.packages;
            packages = {
              sherlock = inputs'.sherlock.packages.default;
              statix = inputs'.statix.packages.default;
              tmux-switcher = inputs'.tmux-switcher.packages.default;
              hyprlock = inputs'.hyprlock.packages.default;
              television = inputs'.television.packages.default;
              walker = inputs'.walker.packages.default;
              elephant = inputs'.elephant.packages.default;
              zen-browser = inputs'.zen-browser.packages.default;
              zen-browser-beta = inputs'.zen-browser.packages.beta;
              zen-browser-twilight = inputs'.zen-browser.packages.twilight;
              nixos-cli = inputs'.nixos-cli.packages.default;
              rust-analyzer-nightly = inputs'.fenix.packages.rust-analyzer;
              rust-minimal-toolchain = inputs'.fenix.packages.minimal.toolchain;

              cctv-viewer = pkgs.callPackage ({ cctv-viewer }: cctv-viewer) { };
              universal-android-debloater = pkgs.callPackage (
                { universal-android-debloater }: universal-android-debloater
              ) { };
              emacs-unstable = pkgs.callPackage (
                { emacs-unstable }: emacs-unstable.override { withTreeSitter = true; }
              ) { };
              emacs-pgtk = pkgs.callPackage ({ emacs-pgtk }: emacs-pgtk.override { withTreeSitter = true; }) { };
              emacs-unstable-pgtk = pkgs.callPackage (
                { emacs-unstable-pgtk }: emacs-unstable-pgtk.override { withTreeSitter = true; }
              ) { };

              neovim-unstable = pkgs.callPackage ({ neovim }: neovim) { };

              wezterm = pkgs-stable.callPackage ({ wezterm }: wezterm) { };
              foot = pkgs-stable.callPackage ({ foot }: foot) { };

              mesa = pkgs-stable.callPackage ({ mesa }: mesa) { };
              mesa-32 = pkgs-stable.callPackage ({ pkgsi686Linux }: pkgsi686Linux.mesa) { };
              intel-vaapi-driver = pkgs-stable.callPackage (
                { intel-vaapi-driver }:
                intel-vaapi-driver.override {
                  enableHybridCodec = true;
                }
              ) { };
              intel-vaapi-driver-32 = pkgs-stable.callPackage (
                { driversi686Linux }:
                driversi686Linux.intel-vaapi-driver.override {
                  enableHybridCodec = true;
                }
              ) { };
              intel-media-driver = pkgs-stable.callPackage ({ intel-media-driver }: intel-media-driver) { };
              intel-media-driver-32 = pkgs-stable.callPackage (
                { driversi686Linux }: driversi686Linux.intel-media-driver
              ) { };
              intel-ocl = pkgs-stable.callPackage ({ intel-ocl }: intel-ocl) { };
              intel-compute-runtime = pkgs-stable.callPackage (
                { intel-compute-runtime }: intel-compute-runtime
              ) { };
              vpl-gpu-rt = pkgs-stable.callPackage ({ vpl-gpu-rt }: vpl-gpu-rt) { };

            };
          };

        # after — pull from nixpkgs lib
        systems = inputs.flake-parts.lib.defaultSystems;
      }
    );
}
