{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  gawk,
  glibc,
  installShellFiles,
  lib,
  makeWrapper,
  nixosTests,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "openbao";
  version = "2.4.0";
  sha256 = "sha256-VJCKZYBuw6fenTqRDxvLVNMXlPuDEq43WB7TI2RNWvc=";
  vendorHash = "sha256-4SWpWGWoesUCgSpgOpblkxOpPbBC/grC2S1m7R9qasY=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "openbao";
    repo = pname;
  };

  proxyVendor = true;

  subPackages = [ "." ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  env.CGO_ENABLED = 0;

  tags = [ "vault" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/openbao/openbao/version.GitCommit=${src.rev}"
    "-X github.com/openbao/openbao/version.Version=${version}"
    "-X github.com/openbao/openbao/version.VersionPrerelease="
  ];

  postInstall =
    ''
      echo "complete -C $out/bin/openbao vault" > vault.bash
      installShellCompletion vault.bash
    ''
    + lib.optionalString stdenv.isLinux ''
      wrapProgram $out/bin/openbao --prefix PATH ${
        lib.makeBinPath [
          gawk
          glibc
        ]
      }
      ln -s openbao $out/bin/bao
      ln -s openbao $out/bin/vault
    '';

  passthru.tests = {
    inherit (nixosTests)
      vault
      vault-postgresql
      vault-dev
      vault-agent
      ;
  };

  meta = with lib; {
    homepage = "https://github.com/openbao/openbao";
    description = "A tool for managing secrets";
    license = licenses.mpl20;
  };
}
