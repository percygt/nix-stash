{
  inputs,
  vimPluginSrc,
  tmuxPluginSrc,
  pkgs ? (import ../nixpkgs.nix) {},
  ...
}: let
  inherit (pkgs) system;
in rec {
  stashTmuxPlugins = pkgs.callPackage ./tmuxPlugins.nix {inherit pkgs tmuxPluginSrc;};
  stashVimPlugins = pkgs.callPackage ./vimPlugins.nix {inherit pkgs vimPluginSrc;};
  wezterm_nightly = inputs.wezterm.packages.${system}.default;
  wrapped_wezterm = pkgs.callPackage ./wrapped_wezterm.nix {inherit pkgs wezterm_nightly;};
  vscode-with-extensions = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = pkgs.callPackage ./vscode_extensions.nix {inherit inputs system;};
  };
  inherit (inputs.nixgl.packages.${system}) nixVulkanIntel nixGLIntel;
}
