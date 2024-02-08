{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in {
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
  # stachVscodeExtensions = {system}: let
  #   inherit (inputs.nix-vscode-extensions.extensions."${system}") vscode-marketplace;
  #
  # in {
  #   inherit vscode-marketplace)
  # };
}
