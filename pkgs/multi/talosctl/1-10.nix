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
  version = "1.10.0";
  sha256 = "sha256-86XFjJUCPzd+7xN8ThGxi8Zf4Ych6wZscC963IET6gg=";
  vendorHash = "sha256-7s4EXuBiyf+TZpq8R1Ym6cJvieKoOmYpcUj286zy19w=";
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
