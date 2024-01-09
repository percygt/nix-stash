{
  description = "Neovim plugin overlay";
  inputs = {
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
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"];
    overlay = final: prev: let
      mkPlugin = name: value:
        prev.pkgs.vimUtils.buildVimPlugin {
          pname = name;
          version = value.lastModifiedDate;
          src = value;
        };
      plugins = prev.lib.filterAttrs (name: _: name != "self" && name != "nixpkgs") [
        inputs.neovim-session-manager
        inputs.nvim-web-devicons
        inputs.better-escape
        inputs.vim-maximizer
      ];
    in {
      vimPlugins =
        prev.vimPlugins
        // builtins.mapAttrs mkPlugin plugins;
    };
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".alejandra);
    legacyPackages = forAllSystems (
      system:
        import inputs.nixpkgs {
          inherit system;
          overlays = [overlay];
          config.allowUnfree = true;
        }
    );
    overlays.default = overlay;
    #TODO:Add github actions
    # nixosConfigurations.test = nixpkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   modules = [
    #     ({pkgs, ...}: {
    #       boot.isContainer = true;
    #       nixpkgs.overlays = [overlay];
    #       system.stateVersion = "22.11";
    #       programs.neovim = {
    #         enable = true;
    #         configure.packages.myVimPackage = {
    #           opt = builtins.attrValues pkgs.nvimPlugins;
    #         };
    #       };
    #     })
    #   ];
    # };
  };
}
