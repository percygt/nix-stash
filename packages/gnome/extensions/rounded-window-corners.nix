{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gobject-introspection,
  gnome,
  gtk3,
  gtk4,
  libadwaita,
  nodePackages,
}: let
  uuid = "rounded-window-corners@yilozt";
in
  stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-rounded-window-corners";
    version = "12";

    src = fetchFromGitHub {
      owner = "yilozt";
      repo = "rounded-window-corners";
      rev = "1a52cf3b77dc6171cd1714e1b11b5456077e0d68";
      hash = "sha256-dZ4jxyZhbVa8ONmyRn5ikb/wufty57WHJbwAVOvUmgQ=";
    };
    
    nativeBuildInputs = [
      glib
      gobject-introspection
      gnome.gnome-shell
      gtk3
      libadwaita
      gtk4
      nodePackages.npm
    ];

    buildPhase = ''
      runHook preBuild
      if [ -d schemas ]; then
        glib-compile-schemas --strict schemas
      fi
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      npm install
      mkdir -p $out/share/gnome-shell/extensions/${uuid}
      cp -r _build $out/share/gnome-shell/extensions/${uuid}
      runHook postInstall
    '';

    passthru = {
      extensionPortalSlug = pname;
      # Store the extension's UUID, because we might need it at some places
      extensionUuid = uuid;
    };

    meta = with lib; {
      description = "A gnome-shell extensions that try to add rounded corners for all windows";
      license = licenses.gpl3Plus;
      maintainers = [];
      homepage = "https://github.com/yilozt/rounded-window-corners";
    };
  }
