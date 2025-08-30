{
  # keep-sorted start
  asciiBuildGoModule,
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
  version = "2.6.4";
  manifestsSha256 = "sha256-zhxYTBidIY2bQz1e8wVlbq3B+2c2fLrQenvAD7h6JYg=";
  sha256 = "sha256-uUjdS0vcg6XgHBGEr2A+nc9y0QS7cuMLiOckKm+eio4=";
  vendorHash = "sha256-U37QdGfj7+YXIARORo0AHqgdzrODyUe5DA+eefxzTWA=";
  # keep-sorted end
in
callPackage ./. {
  inherit
    # keep-sorted start
    asciiBuildGoModule
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
