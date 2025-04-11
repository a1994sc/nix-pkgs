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
  version = "2.4.0";
  manifestsSha256 = "sha256-85Ykc6B+DP9PVqwGbvqsQCUHpx/IzIP9TgOt3id7P5g=";
  sha256 = "sha256-b4mu/iijfALBm+7OIdKgZs55fR6xWfPgL6OMOgIOi3w=";
  vendorHash = "sha256-rVyirt6+D1qedbTvPZjLog16sMAq+zyFUmbjnJIieRg=";
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
