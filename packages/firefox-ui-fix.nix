{
  firefox-ui-fix,
  stdenv,
}:
stdenv.mkDerivation {
  name = "firefox-ui-fix";
  version = firefox-ui-fix.rev;
  src = firefox-ui-fix;

  installPhase = ''
    mkdir -p $out/
    cp -r user.js icons/ css/ $out/
  '';
}
