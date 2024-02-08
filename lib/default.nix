{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in rec {
  ## TMUX PLUGINS
  stashTmuxPlugins = {system}: let
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
  stashVscodeExtensions = {system}: let
    inherit (inputs.nix-vscode-extensions.extensions."${system}") vscode-marketplace;
  in
    with vscode-marketplace; {
      inherit (adpyke) codesnap;
      inherit (anderseandersen) html-class-suggestions;
      inherit (antfu) iconify;
      inherit (astro-build) astro-vscode;
      inherit (asvetliakov) vscode-neovim;
      inherit (bbenoist) nix;
      inherit (bernardogualberto) solidjs;
      inherit (britesnow) vscode-toggle-quotes;
      inherit (charliermarsh) ruff;
      inherit (christian-kohler) npm-intellisense;
      inherit (christian-kohler) path-intellisense;
      inherit (codezombiech) gitignore;
      inherit (dbaeumer) vscode-eslint;
      inherit (donjayamanne) python-environment-manager;
      inherit (esbenp) prettier-vscode;
      inherit (formulahendry) auto-close-tag;
      inherit (formulahendry) auto-rename-tag;
      inherit (foxundermoon) shell-format;
      inherit (github) vscode-pull-request-github;
      inherit (gitlab) gitlab-workflow;
      inherit (helixquar) randomeverything;
      inherit (jock) svg;
      inherit (kamadorueda) alejandra;
      inherit (kastorcode) kastorcode-dark-purple-theme;
      inherit (kevinrose) vsc-python-indent;
      inherit (mads-hartmann) bash-ide-vscode;
      inherit (mgesbert) python-path;
      inherit (mikestead) dotenv;
      inherit (mkhl) direnv;
      inherit (mohsen1) prettify-json;
      inherit (mrmlnc) vscode-scss;
      inherit (ms-azuretools) vscode-docker;
      inherit (ms-python) python;
      inherit (ms-vscode-remote) remote-ssh;
      inherit (ms-vscode) remote-explorer;
      inherit (oderwat) indent-rainbow;
      inherit (patbenatar) advanced-new-file;
      inherit (pmneo) tsimporter;
      inherit (pranaygp) vscode-css-peek;
      inherit (redhat) vscode-yaml;
      inherit (sibiraj-s) vscode-scss-formatter;
      inherit (simonsiefke) svg-preview;
      inherit (sleistner) vscode-fileutils;
      inherit (solnurkarim) html-to-css-autocompletion;
      inherit (steoates) autoimport;
      inherit (sumneko) lua;
      inherit (tamasfe) even-better-toml;
      inherit (timonwong) shellcheck;
      inherit (usernamehw) errorlens;
      inherit (vscode-icons-team) vscode-icons;
      inherit (vunguyentuan) vscode-css-variables;
      inherit (tobias-z) vscode-harpoon;
      inherit (johnnymorganz) stylua;
    };
  mkHMVscodeExtensions = {system}: {
    extensions = builtins.mapAttrsToList (name: value: {name = value;}) (stashVscodeExtensions {inherit system;});
  };
}
