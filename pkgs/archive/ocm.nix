{
  lib,
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  testers,
  ocm,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "ocm";
  version = "1.0.8";
  sha256 = "sha256-v+BWmdTDJm1oElP/XV59pHm7NlsFj2sDTymtT0xpXKY=";
  vendorHash = "sha256-GOdRYVnFPS1ovFmU+9MEnwTNg1sa9/25AjzbcbBJrQ0=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "openshift-online";
    repo = pname + "-cli";
  };

  postUnpack = ''
    # disable tests that require network access
    rm source/tests/pass_test.go
  '';

  # Strip the final binary.
  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [ installShellFiles ];

  # Tests expect the binary to be located in the root directory.
  preCheck = ''
    ln -s $GOPATH/bin/ocm ocm
  '';

  # Tests fail in Darwin sandbox.
  doCheck = !stdenv.isDarwin;

  postInstall = ''
    installShellCompletion --cmd ocm \
      --bash <($out/bin/ocm completion bash) \
      --fish <($out/bin/ocm completion fish) \
      --zsh <($out/bin/ocm completion zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = ocm;
    command = "ocm version";
  };

  meta = with lib; {
    # keep-sorted start
    description = "CLI for the Red Hat OpenShift Cluster Manager";
    homepage = "https://github.com/openshift-online/ocm-cli";
    license = [ licenses.asl20 ];
    platforms = platforms.linux;
    # keep-sorted end
  };
}
