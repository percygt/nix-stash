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

      forAllStableSystems = packagesFrom inputs.nixpkgs-stable;

      stablePkgs = forAllStableSystems (pkgs: {
        wezterm = pkgs.callPackage ({ wezterm }: wezterm) { };
        foot = pkgs.callPackage ({ foot }: foot) { };
        mesa = pkgs.callPackage ({ mesa }: mesa) { };
        mesa-32 = pkgs.callPackage ({ pkgsi686Linux }: pkgsi686Linux.mesa) { };
        intel-vaapi-driver = pkgs.callPackage (
          { intel-vaapi-driver }:
          intel-vaapi-driver.override {
            enableHybridCodec = true;
          }
        ) { };
        intel-vaapi-driver-32 = pkgs.callPackage (
          { driversi686Linux }:
          driversi686Linux.intel-vaapi-driver.override {
            enableHybridCodec = true;
          }
        ) { };
        intel-media-driver = pkgs.callPackage ({ intel-media-driver }: intel-media-driver) { };
        intel-media-driver-32 = pkgs.callPackage (
          { driversi686Linux }: driversi686Linux.intel-media-driver
        ) { };
        intel-ocl = pkgs.callPackage ({ intel-ocl }: intel-ocl) { };
        intel-compute-runtime = pkgs.callPackage ({ intel-compute-runtime }: intel-compute-runtime) { };
        vpl-gpu-rt = pkgs.callPackage ({ vpl-gpu-rt }: vpl-gpu-rt) { };
      });
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt);
      packages =
        stablePkgs
        // (forAllSystems (
          pkgs:
          let
            inherit (pkgs.stdenv.hostPlatform) system;
          in
          {
            sherlock = inputs.sherlock.packages."${system}".default;
            statix = inputs.statix.packages."${system}".default;
            tmux-switcher = inputs.tmux-switcher.packages."${system}".default;
            hyprlock = inputs.hyprlock.packages."${system}".default;
            television = inputs.television.packages."${system}".default;

            walker = inputs.walker.packages."${system}".default;
            elephant = inputs.elephant.packages."${system}".default;

            zen-browser = inputs.zen-browser.packages."${system}".default;
            zen-browser-beta = inputs.zen-browser.packages."${system}".beta;
            zen-browser-twilight = inputs.zen-browser.packages."${system}".twilight;

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
        ));
      overlays = {
        default =
          final: prev:
          let
            inherit (prev.stdenv.hostPlatform) system;
          in
          {
            stax = {
              inherit (outputs.packages.${system})

                statix
                sherlock
                nixos-cli
                cctv-viewer
                hyprlock
                television

                # walker
                walker
                elephant

                # zen browser
                zen-browser
                zen-browser-beta
                zen-browser-twilight

                # graphics
                mesa
                mesa-32
                intel-vaapi-driver
                intel-vaapi-driver-32
                intel-media-driver
                intel-media-driver-32
                intel-ocl
                intel-compute-runtime
                vpl-gpu-rt

                # rust
                rust-analyzer-nightly
                rust-minimal-toolchain

                # emacs
                emacs-unstable
                emacs-pgtk
                emacs-unstable-pgtk

                # neovim
                neovim-unstable

                # stable builds
                foot
                ghostty
                tilix
                xfce4-terminal
                wezterm

                ;
            };
            tmuxPlugins = prev.tmuxPlugins // {
              stax = {
                inherit (outputs.packages.${system}) tmux-switcher;
              };
            };
          };
      };

    };
}
