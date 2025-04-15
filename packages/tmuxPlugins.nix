{ inputs, pkgs }:
let
  tmuxPluginSrc = {
    inherit (inputs) fzf-url tmux-nvim;
  };

  mkStashTmuxPlugin =
    name: value:
    let
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
