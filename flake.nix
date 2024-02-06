{
  description = "My stash of nix overlays";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    codeium.url = "github:Exafunction/codeium.nvim";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    tmuxinoicer.url = "github:percygt/tmuxinoicer";
    # wezterm.url = "github:wez/wezterm?dir=nix";
    tmux-onedark-theme = {
      url = "github:percygt/tmux-onedark-theme";
      flake = false;
    };
    fzf-url = {
      url = "github:wfxr/tmux-fzf-url";
      flake = false;
    };
    hmts = {
      url = "github:calops/hmts.nvim";
      flake = false;
    };
    ts-context-commentstring = {
      url = "github:JoosepAlviste/nvim-ts-context-commentstring";
      flake = false;
    };
    neovim-session-manager = {
      url = "github:Shatur/neovim-session-manager";
      flake = false;
    };
    nvim-web-devicons = {
      url = "github:percygt/nvim-web-devicons";
      flake = false;
    };
    better-escape = {
      url = "github:max397574/better-escape.nvim";
      flake = false;
    };
    vim-maximizer = {
      url = "github:szw/vim-maximizer";
      flake = false;
    };
  };
  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    self,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"];
    overlay = final: prev: let
      mkNvimPlugin = name: value:
        prev.pkgs.vimUtils.buildVimPlugin {
          pname = name;
          version = value.lastModifiedDate;
          src = value;
        };
      nvPlugins = {
        inherit
          (inputs)
          neovim-session-manager
          nvim-web-devicons
          vim-maximizer
          better-escape
          ts-context-commentstring
          hmts
          ;
      };
      mkTmuxPlugin = name: value:
        prev.pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = name;
          version = value.lastModifiedDate;
          rtpFilePath = "${name}.tmux";
          src = value;
        };
      tmPlugins = {
        inherit (inputs) tmux-onedark-theme fzf-url;
      };
      vimPlugins =
        prev.vimPlugins
        // builtins.mapAttrs mkNvimPlugin nvPlugins
        // {
          inherit (inputs.codeium.packages."${prev.system}".vimPlugins) codeium-nvim;
        };
      tmuxPlugins =
        prev.tmuxPlugins
        // builtins.mapAttrs mkTmuxPlugin tmPlugins
        // {
          tmuxinoicer = inputs.tmuxinoicer.packages."${prev.system}".default;
        };
    in {
      stash = {
        inherit (inputs.nix-vscode-extensions.extensions."${prev.system}") vscode-marketplace;
        inherit vimPlugins;
        inherit tmuxPlugins;
      };
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [act];
          };
        };
      };
      flake = {
        formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".alejandra);
        overlays.default = overlay;

        legacyPackages = forAllSystems (
          system:
            import inputs.nixpkgs {
              inherit system;
              overlays = [overlay];
              config.allowUnfree = true;
            }
        );
        nixosConfigurations.test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({pkgs, ...}: {
              boot.isContainer = true;
              nixpkgs.overlays = [overlay];
              system.stateVersion = "22.11";
              programs.neovim = {
                enable = true;
                configure.packages.vimPackage = {
                  opt = builtins.attrValues pkgs.stash.vimPlugins;
                };
              };
            })
          ];
        };
      };
    };
}
