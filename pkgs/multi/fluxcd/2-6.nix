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
  version = "2.6.0";
  manifestsSha256 = "sha256-FuX6n6CYbb0CkpZ57eG0z++NxyQqXaUStz0EETYpHq8=";
  sha256 = "sha256-51Oj79BJXwdqA9JTbpTJNlCok8CEfXusCKCXT7z8xjg=";
  vendorHash = "sha256-H2whjqipt9gl3lZtSwXDpzjY4NQZnbWWjdSryo7wwFE=";
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
