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
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      flake = {
        lib = import ./lib {inherit inputs;};
      };
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
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
        formatter = pkgs.alejandra;
        packages =
          self.lib.stashVimPlugins {inherit system;}
          // self.lib.stashTmuxPlugins {inherit system;};
        overlayAttrs = {
          stash = {
            inherit (inputs.nix-vscode-extensions.extensions."${system}") vscode-marketplace;
            vimPlugins = pkgs.vimPlugins // config.packages.vimPlugins;
            tmuxPlugins = pkgs.tmuxPlugins // config.packages.tmuxPlugins;
          };
        };
      };
    };
}
