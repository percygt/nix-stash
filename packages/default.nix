{
  pkgs ? (import ./nixpkgs.nix) {},
  system,
  inputs,
}: let
  inherit (inputs.nixpkgs) lib;
in
  rec {
    yazi = inputs.yazi.packages.${system}.default;
    swayfx-unwrapped = (pkgs.swayfx-unwrapped.override {wlroots = pkgs.wlroots_0_17;}).overrideAttrs (old: {
      version = "0.4.0-git";
      src = pkgs.lib.cleanSource inputs.swayfx;
      nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.cmake];
      buildInputs = old.buildInputs ++ [pkgs.scenefx];
    });
    swayfx = pkgs.swayfx.override {inherit swayfx-unwrapped;};
    anime-borb-launcher = inputs.aagl.packages.${system}.anime-borb-launcher;
    anime-game-launcher = inputs.aagl.packages.${system}.anime-game-launcher;
    anime-games-launcher = inputs.aagl.packages.${system}.anime-games-launcher;
    honkers-railway-launcher = inputs.aagl.packages.${system}.honkers-railway-launcher;
    honkers-launcher = inputs.aagl.packages.${system}.honkers-launcher;

    firefox-ui-fix = pkgs.callPackage ./firefox-ui-fix.nix {inherit (inputs) firefox-ui-fix;};
    gauth = pkgs.callPackage ./gauth.nix {inherit (inputs) gauth;};
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
