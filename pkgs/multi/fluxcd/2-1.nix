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
  pname = "fluxcd";
  version = "2.1.2";
  sha256 = "sha256-878zVONGJB214ot3JmhVUbPr0XqOu8vKJtZN6J3kh8w=";
  vendorHash = "sha256-4srEYBI/Qay9F0JxEIT0HyOtF29V9dzdB1ei4tZYJbs=";
  manifestsSha256 = "sha256-ynRGJ4tZLQ+fCOIgz0olMs8FBcV4y7oL0KmWW1DdvMY=";
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
