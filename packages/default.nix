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
      vscodeExtensions = import ./vscode_extensions.nix {inherit inputs system;};
    };
    emacsWithConfig = let
      outside-emacs = with pkgs; [
        (python3.withPackages (p: (with p; [
          python-lsp-server
          python-lsp-ruff
          pylsp-mypy
        ])))
        nil
        parallel
        ripgrep
      ];
      org-tangle-elisp-blocks =
        (pkgs.callPackage ./emacs/org.nix {
          inherit pkgs;
          from-elisp = inputs.from-elisp;
        })
        .org-tangle (
          {
            language,
            flags,
          }: let
            is-elisp = (language == "emacs-lisp") || (language == "elisp");
            is-tangle =
              if flags ? ":tangle"
              then flags.":tangle" == "yes" || flags.":tangle" == "y"
              else false;
          in
            is-elisp && is-tangle
        );
      config-el = pkgs.writeText "config.el" (org-tangle-elisp-blocks (builtins.readFile ./emacs/config.org));
    in
      pkgs.callPackage
      (
        {emacsWithPackagesFromUsePackage}: (emacsWithPackagesFromUsePackage {
          package = pkgs.emacs-pgtk;
          config = config-el;
          alwaysEnsure = true;
          defaultInitFile = true;
          extraEmacsPackages = epkgs:
            with epkgs;
              [
                # (treesit-grammars.with-grammars (g:
                #   with g; [
                #     tree-sitter-rust
                #     tree-sitter-python
                #   ]))
                treesit-grammars.with-all-grammars
              ]
              ++ outside-emacs;
          override = final: prev: {
            final.buildInputs = prev.buildInputs or [] ++ outside-emacs;
          };
        })
      )
      {};

    inherit (inputs.waybar.packages.${system}) waybar;
  }
  // (import ./vimPlugins.nix {inherit inputs pkgs;})
  // (import ./tmuxPlugins.nix {inherit inputs pkgs;})
