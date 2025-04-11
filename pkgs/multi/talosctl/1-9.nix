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
  version = "1.9.4";
  sha256 = "sha256-4IA2JV0q2LQN6D9evd99h3375YlEZ6ysBbDckeqn1Gc=";
  vendorHash = "sha256-u0KOQBVclOHzQPH/f8g2jGhtgDTy4PW0nRWbnb/vBHo=";
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
