{
  # keep-sorted start
  buildGoModule,
  callPackage,
  fetchFromGitHub,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=version,
  version = "1.9.5";
  sha256 = "sha256-YsCYXFfGl8JhF2LjJsCl9dWtH3XOW0i1v4mprrVrzCo=";
  vendorHash = "sha256-DbBYhNZ/WEB47HNcJ2b0dNUiTm1imBbTD1oAuT1BAps=";
  # keep-sorted end
in
callPackage ./. {
  inherit
    # keep-sorted start
    buildGoModule
    fetchFromGitHub
    installShellFiles
    lib
    sha256
    stdenv
    vendorHash
    version
    # keep-sorted end
    ;
}
