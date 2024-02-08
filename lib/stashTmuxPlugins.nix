{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in {
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
}
