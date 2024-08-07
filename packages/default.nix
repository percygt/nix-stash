{
  pkgs ? (import ./nixpkgs.nix) { },
  system,
  inputs,
}:
let
  inherit (inputs.nixpkgs) lib;
in
rec {
  yazi = inputs.yazi.packages.${system}.default;
  wezterm_nightly = inputs.wezterm.packages.${system}.default;
  # keepmenu = inputs.keepmenu.packages.${system}.default;
  yaml2nix = inputs.yaml2nix.packages."${system}".default;
  tmuxinoicer = inputs.tmuxinoicer.packages."${system}".default;
  inherit (inputs.nixgl.packages.${system}) nixVulkanIntel nixGLIntel;
  wezterm_wrapped =
    (import ./nixGLMesaVulkanWrap.nix {
      inherit
        nixGLIntel
        nixVulkanIntel
        pkgs
        lib
        ;
    }).nixGLMesaVulkanWrap
      wezterm_nightly;
  vscode-with-extensions = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = import ./vscode_extensions.nix { inherit pkgs; };
  };

  # waybar = (inputs.waybar.packages.${system}.waybar).override {
  #   cavaSupport = false;
  #   evdevSupport = true;
  #   experimentalPatches = false;
  #   hyprlandSupport = false;
  #   inputSupport = false;
  #   jackSupport = false;
  #   mpdSupport = false;
  #   mprisSupport = false;
  #   nlSupport = true;
  #   pulseSupport = true;
  #   rfkillSupport = false;
  #   sndioSupport = false;
  #   swaySupport = true;
  #   traySupport = true;
  #   udevSupport = false;
  #   upowerSupport = false;
  #   wireplumberSupport = false;
  #   withMediaPlayer = false;
  # };
}
# // (import ./vimPlugins.nix {inherit inputs pkgs;})
// (import ./tmuxPlugins.nix { inherit inputs pkgs; })
