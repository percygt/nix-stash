{
  pkgs,
  inputs,
}:
{
  yaml2nix = inputs.yaml2nix.packages."${pkgs.system}".default;
  tmux-switcher = inputs.tmux-switcher.packages."${pkgs.system}".default;
  hyprlock = inputs.hyprlock.packages."${pkgs.system}".default;
  television = inputs.television.packages."${pkgs.system}".default;

  simple-completion-language-server =
    inputs.simple-completion-language-server.defaultPackage.${pkgs.system};
}
// (import ./tmuxPlugins.nix { inherit inputs pkgs; })
