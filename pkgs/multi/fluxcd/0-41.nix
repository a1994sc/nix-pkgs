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
  version = "0.41.2";
  sha256 = "sha256-RFwuNgMjO4WIXtZ8A0JzOa8p01XPxKvY1HImaqaxkTA=";
  vendorHash = "sha256-ez4yaFZ5JROdu9boN5wI/XGMqLo8OKW6b0FZsJeFw4w=";
  manifestsSha256 = "sha256-QKaZH1ZmjhoHrwD4mysdD6bpkch6cDGpDqvohETRiU0=";
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
