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
  version = "1.8.4";
  sha256 = "sha256-kXvSI2leFmVI3/onCvL+CIVpD9ZegdZs6MOzSI6nmjI=";
  vendorHash = "sha256-+dB2BqP6lOVSSWGdih9guJrqZ3j/q/tQlRvpsoRua/s=";
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
