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
  version = "2.5.1";
  manifestsSha256 = "sha256-bIIK8igtx0gUcn3hlBohE0MG9PMhyThz4a71pkonBpE=";
  sha256 = "sha256-BuFylOWR30aK7d1eN+9getR5amtAtkkhHNAPfdfASHs=";
  vendorHash = "sha256-2fThvz/5A1/EyS6VTUQQa5Unx1BzYfsVRE18xOHtLHE=";
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
