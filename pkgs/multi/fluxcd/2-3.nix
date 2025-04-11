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
  version = "2.3.0";
  manifestsSha256 = "sha256-PdhR+UDquIJWtpSymtT6V7qO5fVJOkFz6RGzAx7xeb4=";
  sha256 = "sha256-ZQs1rWI31qDo/BgjrmiNnEdR2OL8bUHVz+j5VceEp2k=";
  vendorHash = "sha256-0YH3pgFrsnh5jIsZpj/sIgfiOCTtIlPltMS5mdGz1eM=";
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
