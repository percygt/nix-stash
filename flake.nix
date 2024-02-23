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
    nixpkgs,
    ...
  }: let
    tmuxPluginSrc = {
      inherit
        (inputs)
        tmux-onedark-theme
        fzf-url
        ;
    };
    vimPluginSrc = {
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
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      flake = {
        lib = import ./lib {inherit inputs vimPluginSrc tmuxPluginSrc;};
      };
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
          // self.lib.stashTmuxPlugins {inherit system;}
          // {
            #tmux flake plugin
            tmuxinoicer = inputs.tmuxinoicer.packages."${system}".default;
            #vim flake plugin
            inherit (inputs.codeium.packages."${system}".vimPlugins) codeium-nvim;
            #vscodium
            vscode-with-extensions = pkgs.vscode-with-extensions.override {
              vscode = pkgs.vscodium;
              vscodeExtensions = self.lib.vscodeExtensions {inherit system;};
            };
            #nixgl wrapper
            inherit (inputs.nixgl.packages.${system}) nixVulkanIntel nixGLIntel;
            #wezterm
            wezterm_nightly = inputs.wezterm.packages.${system}.default;
            wezterm_wrapped = self.lib.wrapped_wezterm {
              inherit system;
              inherit (self'.packages) nixVulkanIntel nixGLIntel wezterm_nightly;
            };
          };
        overlayAttrs = {
          stash =
            inputs.nixpkgs-stable.legacyPackages.${system}
            // {
              inherit (self'.packages) nixVulkanIntel nixGLIntel wezterm_wrapped wezterm_nightly;
              inherit (inputs.nix-vscode-extensions.extensions.${system}) vscode-marketplace;
              vimPlugins =
                pkgs.vimPlugins
                // self.lib.stashVimPlugins {inherit system;}
                // {inherit (self'.packages) codeium-nvim;};
              tmuxPlugins =
                pkgs.tmuxPlugins
                // self.lib.stashTmuxPlugins {inherit system;}
                // {inherit (self'.packages) tmuxinoicer;};
            };
        };
      };
    };
}
