{
  pkgs ? (import ./nixpkgs.nix) {},
  system,
  inputs,
}: let
  inherit (inputs.nixpkgs) lib;
in
  rec {
    yazi = inputs.yazi.packages.${system}.default;
    wezterm_nightly = inputs.wezterm.packages.${system}.default;
    keepmenu = inputs.keepmenu.packages.${system}.default;
    # swayfx-unwrapped = inputs.swayfx.packages.${system}.default;
    # swayfx = pkgs.swayfx.override {inherit swayfx-unwrapped;};
    # inherit (inputs.aagl.packages.${system}) honkers-launcher honkers-railway-launcher anime-borb-launcher anime-games-launcher anime-game-launcher;
    firefox-ui-fix = pkgs.callPackage ./firefox-ui-fix.nix {inherit (inputs) firefox-ui-fix;};
    gauth = pkgs.callPackage ./gauth.nix {inherit (inputs) gauth;};
    yaml2nix = inputs.yaml2nix.packages."${system}".default;
    tmuxinoicer = inputs.tmuxinoicer.packages."${system}".default;
    inherit (inputs.codeium.packages."${system}".vimPlugins) codeium-nvim;
    inherit (inputs.nixgl.packages.${system}) nixVulkanIntel nixGLIntel;
    wezterm_wrapped = (import ./nixGLMesaVulkanWrap.nix {inherit nixGLIntel nixVulkanIntel pkgs lib;}).nixGLMesaVulkanWrap wezterm_nightly;
    vscode-with-extensions = pkgs.vscode-with-extensions.override {
      vscode = pkgs.vscodium;
      vscodeExtensions = import ./vscode_extensions.nix {inherit pkgs;};
    };
    emacs-unstable-pgtk = pkgs.callPackage ({emacs-unstable-pgtk}: emacs-unstable-pgtk) {};
    emacs-unstable = pkgs.callPackage ({emacs-unstable}: emacs-unstable) {};
    neovim = pkgs.callPackage ({neovim}: neovim) {};
    inherit (inputs.waybar.packages.${system}) waybar;
  }
  // (import ./vimPlugins.nix {inherit inputs pkgs;})
  // (import ./tmuxPlugins.nix {inherit inputs pkgs;})
