{
  # keep-sorted start
  buildGoModule,
  callPackage,
  fetchFromGitHub,
  fetchzip,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=version,
  version = "2.6.1";
  manifestsSha256 = "sha256-Kmf9EFOtJI71XtMIVl5NmNvH31UpwoN5ecZufZXCZj4=";
  sha256 = "sha256-BVfgxYoVPRAh/I2aNp1tPytB0JS2BJvzy6zR/18f170=";
  vendorHash = "sha256-RMfxRik5x/DhG6ZFvTmTXUsGZ9OUTq96wHjvUXqY2bY=";
  # keep-sorted end
in
callPackage ./. {
  inherit
    # keep-sorted start
    buildGoModule
    fetchFromGitHub
    fetchzip
    installShellFiles
    lib
    manifestsSha256
    sha256
    stdenv
    vendorHash
    version
    # keep-sorted end
    ;
}
