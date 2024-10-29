{
  pkgs,
  inputs,
}:
let
  inherit (inputs.nixpkgs) lib;
in
rec {
  clipmon = pkgs.callPackage ./clipmon.nix { };
  yaml2nix = inputs.yaml2nix.packages."${pkgs.system}".default;
  tmuxinoicer = inputs.tmuxinoicer.packages."${pkgs.system}".default;
}
// (import ./tmuxPlugins.nix { inherit inputs pkgs; })
