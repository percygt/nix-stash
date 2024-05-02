{
  pkgs ? (import ./nixpkgs.nix) {},
  system,
  inputs,
}: let
  inherit (inputs.nixpkgs) lib;
in
  rec {
    yazi = inputs.yazi.packages.${system}.default;
    yaml2nix = inputs.yaml2nix.packages."${system}".default;
    tmuxinoicer = inputs.tmuxinoicer.packages."${system}".default;
    inherit (inputs.codeium.packages."${system}".vimPlugins) codeium-nvim;
    inherit (inputs.nixgl.packages.${system}) nixVulkanIntel nixGLIntel;
    wezterm_nightly = inputs.wezterm.packages.${system}.default;
    wezterm_wrapped = (import ./nixGLMesaVulkanWrap.nix {inherit nixGLIntel nixVulkanIntel pkgs lib;}).nixGLMesaVulkanWrap wezterm_nightly;
    vscode-with-extensions = pkgs.vscode-with-extensions.override {
      vscode = pkgs.vscodium;
      vscodeExtensions = import ./vscode_extensions.nix {inherit inputs system;};
    };
    inherit (inputs.nixpkgs-wayland.packages.${system}) waybar;
  }
  // (import ./vimPlugins.nix {inherit inputs pkgs;})
  // (import ./tmuxPlugins.nix {inherit inputs pkgs;})
