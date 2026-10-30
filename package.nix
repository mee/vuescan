# VueScan run inside a minimal FHS sandbox. VueScan dlopens Epson iscan
# plugins only from hardcoded paths (/usr/lib/iscan/, /usr/lib/esci/, ...),
# the plugins read their firmware from /usr/share/iscan, and VueScan shells
# out to /usr/bin/curl; none of these paths exist on NixOS.
#
# Override `iscanPlugins` for other Epson models, e.g.
#   vuescan.override { iscanPlugins = [ (callPackage ./iscan-plugin.nix { model = "gt-x830"; hash = "..."; }) ]; }
{
  lib,
  callPackage,
  buildFHSEnv,
  curl,
  iscanPlugins ? [(callPackage ./iscan-plugin.nix {})],
}: let
  unwrapped = callPackage ./vuescan-unwrapped.nix {};
in
  buildFHSEnv {
    pname = "vuescan";
    inherit (unwrapped) version;

    targetPkgs = _: [curl] ++ iscanPlugins;

    runScript = "${unwrapped}/bin/vuescan";

    # Expose the desktop entry, icon and udev rules so the result can go in
    # both environment.systemPackages and services.udev.packages.
    extraInstallCommands = ''
      ln -s ${unwrapped}/share $out/share
      mkdir -p $out/lib
      ln -s ${unwrapped}/lib/udev $out/lib/udev
    '';

    passthru = {inherit unwrapped iscanPlugins;};

    meta = unwrapped.meta // {mainProgram = "vuescan";};
  }
