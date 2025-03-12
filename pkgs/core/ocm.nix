{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  testers,
  ocm,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "ocm";
  version = "1.0.4";
  sha256 = "sha256-K/hAxzstRY0Mh7qYMqwWfIbop+AhgzvPZsrZo8eTzsQ=";
  vendorHash = "sha256-RQioZq/fdqr6baTTDeLUhFh/dlByNM5Ys0L4pAYXkHI=";
  # keep-sorted end
  rev = "v" + version;
in

buildGoModule rec {
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
    description = "CLI for the Red Hat OpenShift Cluster Manager";
    license = [ licenses.asl20 ];
    homepage = "https://github.com/openshift-online/ocm-cli";
    platforms = platforms.linux;
  };
}
