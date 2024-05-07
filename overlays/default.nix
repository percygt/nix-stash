{
  inputs,
  outputs,
}: {
  default = final: prev: {
    stash =
      inputs.nixpkgs-stable.legacyPackages.${prev.system}
      // {
        inherit (outputs.packages.${prev.system}) firefox-ui-fix nixVulkanIntel nixGLIntel wezterm_wrapped wezterm_nightly yaml2nix yazi swayfx swayfx-unwrapped;
        inherit (inputs.nix-vscode-extensions.extensions.${prev.system}) vscode-marketplace;
        vimPlugins =
          prev.vimPlugins
          // (import ../packages/vimPlugins.nix {
            inherit inputs;
            pkgs = prev;
          })
          // {inherit (outputs.packages.${prev.system}) codeium-nvim;};
        tmuxPlugins =
          prev.tmuxPlugins
          // (import ../packages/tmuxPlugins.nix) {
            inherit inputs;
            pkgs = prev;
          }
          // {inherit (outputs.packages.${prev.system}) tmuxinoicer;};
      };
  };
}
