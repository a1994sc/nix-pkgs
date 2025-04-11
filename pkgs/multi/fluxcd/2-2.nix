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
  version = "2.2.3";
  manifestsSha256 = "sha256-HSl15rJknWeKqi3kYTHJvQlw5eD77OkFhIn0K+Ovv8I=";
  sha256 = "sha256-1Z9EXqK+xnFGeWjoac1QZwOoMiYRRU1HEAZRaEpUOYs=";
  vendorHash = "sha256-UPX5V3VwpX/eDy9ktqpvYb0JOzKRHH2nIQZzZ0jrYoQ=";
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
