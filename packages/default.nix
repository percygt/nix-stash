{
  pkgs,
  inputs,
}:
let
  inherit (inputs.nixpkgs) lib;
in
rec {
  # yazi = inputs.yazi.packages.${pkgs.system}.default;
  wezterm_nightly = inputs.wezterm.packages.${pkgs.system}.default;
  # keepmenu = inputs.keepmenu.packages.${system}.default;
  yaml2nix = inputs.yaml2nix.packages."${pkgs.system}".default;
  tmuxinoicer = inputs.tmuxinoicer.packages."${pkgs.system}".default;
  inherit (inputs.nixgl.packages.${pkgs.system}) nixVulkanIntel nixGLIntel;
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
}
// (import ./tmuxPlugins.nix { inherit inputs pkgs; })
