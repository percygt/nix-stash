{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in {
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
