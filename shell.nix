{pkgs, ...}: {
  default = pkgs.mkShell {
    buildInputs = with pkgs; [act];
  };
}
