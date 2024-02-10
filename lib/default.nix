{inputs}: {
  flake = let
    inherit (inputs) nixpkgs;
  in {
    # Wezterm
    wrapped_wezterm = {system, nixVulkanIntel, nixGLIntel}: let
      inherit (nixpkgs) legacyPackages lib;
      pkgs = legacyPackages.${system};
      wezterm = inputs.wezterm.packages.${system}.default;
      nixGLVulkanMesaWrap = pkg:
        pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
          mkdir $out
          ln -s ${pkg}/* $out
          rm $out/bin
          mkdir $out/bin
          for bin in ${pkg}/bin/*; do
           wrapped_bin=$out/bin/$(basename $bin)
           echo "${lib.getExe nixGLIntel} ${
            lib.getExe nixVulkanIntel
          } $bin \$@" > $wrapped_bin
           chmod +x $wrapped_bin
          done
        '';
    in
      nixGLVulkanMesaWrap wezterm;
    ## TMUX PLUGINS
    stashTmuxPlugins = {system}: let
      inherit (nixpkgs) legacyPackages;
      pkgs = legacyPackages.${system};
      tmuxPluginSrc = {
        inherit
          (inputs)
          tmux-onedark-theme
          fzf-url
          ;
      };
      extraTmuxPluginSrc = {
        tmuxinoicer = inputs.tmuxinoicer.packages."${system}".default;
      };
      mkStashTmuxPlugin = name: value: let
        inherit (pkgs) tmuxPlugins;
        inherit (tmuxPlugins) mkTmuxPlugin;
      in
        mkTmuxPlugin {
          pluginName = name;
          version = value.lastModifiedDate;
          rtpFilePath = "${name}.tmux";
          src = value;
        };
    in
      builtins.mapAttrs mkStashTmuxPlugin tmuxPluginSrc
      // extraTmuxPluginSrc;

    ## VIM PLUGINS
    stashVimPlugins = {system}: let
      inherit (nixpkgs) legacyPackages;
      pkgs = legacyPackages.${system};
      vimPluginSrc = {
        inherit
          (inputs)
          neovim-session-manager
          nvim-web-devicons
          vim-maximizer
          better-escape
          ts-context-commentstring
          hmts
          ;
      };
      extraVimPluginSrc = {
        inherit (inputs.codeium.packages."${system}".vimPlugins) codeium-nvim;
      };
      mkStashVimPlugin = name: value: let
        inherit (pkgs) vimUtils;
        inherit (vimUtils) buildVimPlugin;
      in
        buildVimPlugin {
          pname = name;
          version = value.lastModifiedDate;
          src = value;
        };
    in
      builtins.mapAttrs mkStashVimPlugin vimPluginSrc
      // extraVimPluginSrc;

    ## VSCODE EXTENSIONS
    vscodeExtensions = {system}:
      with inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
        adpyke.codesnap
        johnnymorganz.luau-lsp
        anderseandersen.html-class-suggestions
        antfu.iconify
        astro-build.astro-vscode
        asvetliakov.vscode-neovim
        bbenoist.nix
        bernardogualberto.solidjs
        britesnow.vscode-toggle-quotes
        christian-kohler.npm-intellisense
        christian-kohler.path-intellisense
        codezombiech.gitignore
        dbaeumer.vscode-eslint
        donjayamanne.python-environment-manager
        esbenp.prettier-vscode
        formulahendry.auto-close-tag
        formulahendry.auto-rename-tag
        foxundermoon.shell-format
        github.vscode-pull-request-github
        gitlab.gitlab-workflow
        helixquar.randomeverything
        jock.svg
        kamadorueda.alejandra
        kastorcode.kastorcode-dark-purple-theme
        kevinrose.vsc-python-indent
        mads-hartmann.bash-ide-vscode
        mgesbert.python-path
        mikestead.dotenv
        mkhl.direnv
        mohsen1.prettify-json
        mrmlnc.vscode-scss
        ms-azuretools.vscode-docker
        ms-python.python
        charliermarsh.ruff
        ms-vscode-remote.remote-ssh
        ms-vscode.remote-explorer
        oderwat.indent-rainbow
        patbenatar.advanced-new-file
        pmneo.tsimporter
        pranaygp.vscode-css-peek
        redhat.vscode-yaml
        sibiraj-s.vscode-scss-formatter
        simonsiefke.svg-preview
        sleistner.vscode-fileutils
        solnurkarim.html-to-css-autocompletion
        steoates.autoimport
        sumneko.lua
        tamasfe.even-better-toml
        timonwong.shellcheck
        usernamehw.errorlens
        vscode-icons-team.vscode-icons
        vunguyentuan.vscode-css-variables
        tobias-z.vscode-harpoon
        johnnymorganz.stylua
      ];
  };
}
