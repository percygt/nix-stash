{
  inputs,
  pkgs,
}: let
  vimPluginSrc = {
    inherit
      (inputs)
      neovim-session-manager
      vim-maximizer
      better-escape
      hmts
      ;
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
