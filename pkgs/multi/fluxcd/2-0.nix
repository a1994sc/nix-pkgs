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
  version = "2.0.1";
  sha256 = "sha256-n6nSudGHwt2ZrcdLQaHScW7z2fkUACteIbSm5MXCueo=";
  vendorHash = "sha256-n0915f9mHExAEsHtplpLSPDJBWU5cFgBQC2ElToNRmA=";
  manifestsSha256 = "sha256-Yxk88G9mpgZ2KW/gl1dY6BEJ985jd03UVXGtZt+jEEk=";
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
