{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  stdenv,
  callPackage,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=version,
  version = "1.7.7";
  sha256 = "sha256-gihVZX1wwlpV9w/pydV9wQLQVbBCeIwOVMwd2PdI9Nw=";
  vendorHash = "sha256-6KSa1XEAVPI1Pyhatsv8vhzY+1G/Gt426iS3yqNhjCg=";
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
