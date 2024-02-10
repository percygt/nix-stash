{
  description = "My stash of nix overlays";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    
    codeium.url = "github:Exafunction/codeium.nvim";
    codeium.inputs.nixpkgs.follows = "nixpkgs-stable";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:guibou/nixgl";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    tmuxinoicer.url = "github:percygt/tmuxinoicer";

    wezterm.url = "github:wez/wezterm?dir=nix";
    wezterm.inputs.nixpkgs.follows = "nixpkgs";

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
    self,
    ...
  }: let
    lib = import ./lib {inherit inputs;};
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
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
          lib.flake.stashVimPlugins {inherit system;}
          // lib.flake.stashTmuxPlugins {inherit system;}
          // {
            vscode-with-extensions = pkgs.vscode-with-extensions.override {
              vscode = pkgs.vscodium;
              vscodeExtensions = lib.flake.vscodeExtensions {inherit system;};
            };
            inherit (inputs.nixgl.packages.${system}) nixVulkanIntel nixGLIntel;
            wezterm = lib.flake.wrapped_wezterm {
              inherit system;
              inherit (self'.packages) nixVulkanIntel nixGLIntel;
            };
          };
        overlayAttrs = {
          stash = inputs.nixpkgs-stable.legacyPackages.${system} // {
            inherit (self'.packages) nixVulkanIntel nixGLIntel;
            inherit (self'.packages) wezterm;
            inherit (inputs.nix-vscode-extensions.extensions.${system}) vscode-marketplace;
            vimPlugins = pkgs.vimPlugins // lib.flake.stashVimPlugins {inherit system;};
            tmuxPlugins = pkgs.tmuxPlugins // lib.flake.stashTmuxPlugins {inherit system;};
          };
        };
      };
    };
}
