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
      multicursors-nvim
      hmts
      mini-nvim
      code-runner-nvim
      git-worktree-nvim
      garbage-day-nvim
      harpoon-lualine
      tiny-inline-diagnostic
      lualine-so-fancy-nvim
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
