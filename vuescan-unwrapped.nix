{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
  gtk3,
  glib,
  gdk-pixbuf,
  pango,
  cairo,
  libpng,
  libxkbcommon,
  libuuid,
  libX11,
  systemdLibs,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vuescan-unwrapped";
  version = "9.8.59";

  # Hamrick only hosts the latest release of each major series at this URL
  # (it redirects to files.hamrick.com), so the hash breaks whenever they
  # publish a new 9.8.x. Bump `version` and `hash` when that happens:
  #   nix store prefetch-file https://www.hamrick.com/files/vuex6498.tgz
  src = fetchurl {
    url = "https://www.hamrick.com/files/vuex6498.tgz";
    name = "vuex64-${finalAttrs.version}.tgz";
    hash = "sha256-kY8XVOCxs/qp9Xe9uI7/uL/GHkW1ZmM+MTpNID9BskU=";
  };

  sourceRoot = "VueScan";

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    gtk3
    glib
    gdk-pixbuf
    pango
    cairo
    libpng
    libxkbcommon
    libuuid
    libX11
    systemdLibs # libudev
    zlib
    stdenv.cc.cc.lib # libstdc++, libgcc_s, libgomp
  ];

  dontConfigure = true;
  dontBuild = true;
  # Stripping the prebuilt binary is pointless and risks breaking it.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 vuescan $out/bin/vuescan
    install -Dm644 vuescan.svg $out/share/icons/hicolor/scalable/apps/vuescan.svg
    install -Dm644 vuescan.rul $out/lib/udev/rules.d/60-vuescan.rules

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "vuescan";
      desktopName = "VueScan";
      genericName = "Scanner software";
      exec = "vuescan";
      icon = "vuescan";
      categories = ["Graphics" "Scanning"];
    })
  ];

  meta = {
    description = "Scanner software supporting a large number of scanners";
    homepage = "https://www.hamrick.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "vuescan";
  };
})
