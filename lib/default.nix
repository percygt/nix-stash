{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in {
  # imports = [
  #   ./stashTmuxPlugins.nix
  #   {inherit inputs;}
  #   ./stashVimPlugins.nix
  #   {inherit inputs;}
  # ];
  stashTmuxPlugins = {system}: let
    pkgs = legacyPackages.${system};
    pluginSrc = {
      inherit
        (inputs)
        tmux-onedark-theme
        fzf-url
        ;
    };
    extraPluginSrc = {
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
    builtins.mapAttrs mkStashTmuxPlugin pluginSrc
    // extraPluginSrc;
    
  stashVimPlugins = {system}: let
    pkgs = legacyPackages.${system};
    pluginSrc = {
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
    extraPluginSrc = {
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
    builtins.mapAttrs mkStashVimPlugin pluginSrc
    // extraPluginSrc;
}
