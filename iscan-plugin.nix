# Epson "iscan plugin" (interpreter library + firmware) that VueScan needs for
# some Epson scanners. See https://www.hamrick.com/iscan.html for the list of
# models; the default here is the GT-X820, sold as the Perfection V600 Photo.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  model ? "gt-x820",
  pluginVersion ? "2.2.1-1",
  hash ? "sha256-M6+tSvJU+vVZkwIbcX9Vprv3rScMbbEe+iJ0nXfBWYY=",
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "iscan-plugin-${model}";
  version = "2.30.4";

  src = fetchurl {
    url = "https://www.hamrick.com/files/iscan-${model}-bundle-${finalAttrs.version}.x64.deb.tar.gz";
    inherit hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [stdenv.cc.cc.lib];

  # Only the model-specific plugin is needed; VueScan has its own driver and
  # does not use the bundled iscan core or SANE backend.
  installPhase = ''
    runHook preInstall

    dpkg-deb -x plugins/iscan-plugin-${model}_${pluginVersion}_amd64.deb root
    mkdir -p $out
    cp -r root/usr/lib root/usr/share $out/
    rm -rf $out/share/doc

    runHook postInstall
  '';

  meta = {
    description = "Epson iscan interpreter plugin and firmware for the ${model}";
    homepage = "https://www.hamrick.com/iscan.html";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
  };
})
