{inputs}: {
  extra = final: prev:
    import ../packages {
      pkgs = final;
      inherit (prev) system;
      inherit inputs;
    };
}
