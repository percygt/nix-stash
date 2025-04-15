{ inputs, outputs }:
{
  default = final: prev: {
    inherit (outputs.packages.${prev.system})
      simple-completion-language-server
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
}
