{ inputs, outputs }:
{
  default = final: prev: {
    inherit (outputs.packages.${prev.system})
      nixVulkanIntel
      nixGLIntel
      wezterm_nightly
      wezterm_wrapped
      ;
    master = inputs.nixpkgs-master.legacyPackages.${prev.system};
    stable = inputs.nixpkgs-stable.legacyPackages.${prev.system} // {
      inherit (outputs.packages.${prev.system})
        yaml2nix
        # yazi
        # waybar
        # keepmenu
        # anime-borb-launcher

        # anime-game-launcher

        # anime-games-launcher

        # honkers-railway-launcher

        # honkers-launcher

        ;
      inherit (inputs.nix-vscode-extensions.extensions.${prev.system}) vscode-marketplace;
      # vimPlugins =
      #   prev.vimPlugins
      #   // (import ../packages/vimPlugins.nix {
      #     inherit inputs;
      #     pkgs = prev;
      #   })
      #   // {inherit (outputs.packages.${prev.system}) codeium-nvim;};
      tmuxPlugins =
        prev.tmuxPlugins
        // (import ../packages/tmuxPlugins.nix) {
          inherit inputs;
          pkgs = prev;
        }
        // {
          inherit (outputs.packages.${prev.system}) tmuxinoicer;
        };
    };
  };
}
