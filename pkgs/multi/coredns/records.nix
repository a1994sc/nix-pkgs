{
  # keep-sorted start
  buildGoModule,
  callPackage,
  fetchFromGitHub,
  installShellFiles,
  lib,
  nixosTests,
  stdenv,
  # keep-sorted end
  ...
}:
let
  externalPlugins = [
    {
      name = "records";
      repo = "github.com/coredns/records";
      version = "a3157e710d9e57c75e4950a3750228f3ed9bb47a";
    }
  ];
  vendorHash = "sha256-SwZD1+R1ssQi7yji/xSipeUPSvGTuv7ykQhJU+bWjos=";
in
callPackage ./vanilla.nix {
  inherit
    # keep-sorted start
    buildGoModule
    externalPlugins
    fetchFromGitHub
    installShellFiles
    lib
    nixosTests
    stdenv
    vendorHash
    # keep-sorted end
    ;
}
