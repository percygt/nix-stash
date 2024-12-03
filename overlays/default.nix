{ inputs, outputs }:
{
  default = final: prev: {
    inherit (outputs.packages.${prev.system})
      clipmon
      ;
    master = inputs.nixpkgs-master.legacyPackages.${prev.system};
    stable = inputs.nixpkgs-stable.legacyPackages.${prev.system} // {
      inherit (outputs.packages.${prev.system})
        yaml2nix
        # anime-borb-launcher

        # anime-game-launcher

        # anime-games-launcher

        # honkers-railway-launcher

        # honkers-launcher

        ;
      inherit (inputs.nix-vscode-extensions.extensions.${prev.system}) vscode-marketplace;
      tmuxPlugins =
        prev.tmuxPlugins
        // (import ../packages/tmuxPlugins.nix) {
          inherit inputs;
          pkgs = prev;
        }
        // {
          inherit (outputs.packages.${prev.system}) tmux-switcher;
        };
    };
  };
}
