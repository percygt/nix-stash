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
    nixpkgs-old.follows = "nix-sources/nixpkgs-old";
    nixpkgs-master.follows = "nix-sources/nixpkgs-master";
    nixpkgs-stable.follows = "nix-sources/nixpkgs-stable";
    nixpkgs-unstable.follows = "nix-sources/nixpkgs-unstable";

    tmux-switcher.url = "github:percygt/tmux-switcher";
    tmux-nvim.url = "github:aserowy/tmux.nvim";
    tmux-nvim.flake = false;
    naersk = {
      url = "github:nix-community/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-completion-language-server = {
      url = "github:estin/simple-completion-language-server";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.naersk.follows = "naersk";
    };
    hyprlock.url = "github:hyprwm/hyprlock";
    hyprlock.inputs.nixpkgs.follows = "nixpkgs";

    television = {
      url = "github:alexpasmantier/television";
      inputs.naersk.follows = "naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noogle-cli = {
      url = "github:juliamertz/noogle-cli";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-master.follows = "nixpkgs-master";
    };
    elephant.url = "github:abenz1267/elephant";
    elephant.inputs.nixpkgs.follows = "nixpkgs";

    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };

    # anyrun = {
    #   url = "github:/anyrun-org/anyrun";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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
      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
      packages = forAllSystems (pkgs: {
        tmux-switcher = inputs.tmux-switcher.packages."${pkgs.system}".default;
        hyprlock = inputs.hyprlock.packages."${pkgs.system}".default;
        television = inputs.television.packages."${pkgs.system}".default;
        noogle-cli = inputs.noogle-cli.packages."${pkgs.system}".default;
        walker = inputs.walker.packages."${pkgs.system}".default;
        elephant = inputs.elephant.packages."${pkgs.system}".default;
        # inherit (inputs.anyrun.packages."${pkgs.system}")
        #   anyrun
        #   anyrun-with-all-plugins
        #   applications
        #   dictionary
        #   kidex
        #   nix-run
        #   randr
        #   rink
        #   shell
        #   stdin
        #   symbols
        #   translate
        #   websearch
        #   niri-focus
        #   anyrun-provider
        #   ;
        #
        simple-completion-language-server =
          inputs.simple-completion-language-server.defaultPackage.${pkgs.system};
      });
      overlays = {
        default = final: prev: {
          inherit (outputs.packages.${prev.system})
            simple-completion-language-server
            hyprlock
            television
            noogle-cli
            walker
            elephant
            ;
          # anyrunPackages = {
          #   inherit (outputs.packages.${prev.system})
          #     anyrun
          #     anyrun-with-all-plugins
          #     applications
          #     dictionary
          #     kidex
          #     nix-run
          #     randr
          #     rink
          #     shell
          #     stdin
          #     symbols
          #     translate
          #     websearch
          #     niri-focus
          #     anyrun-provider
          #     ;
          # };
          tmuxPlugins = prev.tmuxPlugins // {
            inherit (outputs.packages.${prev.system}) tmux-switcher;
          };
        };
      };

    };
}
