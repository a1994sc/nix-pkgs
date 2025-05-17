{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  pcsclite,
  pkg-config,
  installShellFiles,
  pivKeySupport ? true,
  pkcs11Support ? true,
  testers,
  cosign,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "cosign";
  version = "2.5.0";
  sha256 = "sha256-QvU+JpIcE9EX+ehRWvs2bS2VGgGVekNX8f5+mITIwU0=";
  vendorHash = "sha256-qIi+Pp4XZg1GxOhM9fCyD9rPaIiQHhoQudB50gzWgrM=";
  # keep-sorted end
  rev = "refs/tags/v" + version;
in
buildGoModule {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "sigstore";
    repo = pname;
  };

  buildInputs = lib.optional (stdenv.hostPlatform.isLinux && pivKeySupport) (lib.getDev pcsclite);

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  subPackages = [
    "cmd/cosign"
  ];

  tags =
    [ ] ++ lib.optionals pivKeySupport [ "pivkey" ] ++ lib.optionals pkcs11Support [ "pkcs11key" ];

  ldflags = [
    "-s"
    "-w"
    "-X sigs.k8s.io/release-utils/version.gitVersion=v${version}"
    "-X sigs.k8s.io/release-utils/version.gitTreeState=clean"
  ];

  __darwinAllowLocalNetworking = true;

  preCheck = ''
    # test all paths
    unset subPackages

    rm pkg/cosign/ctlog_test.go # Require network access
    rm pkg/cosign/tlog_test.go # Require network access
    rm cmd/cosign/cli/verify/verify_test.go # Require network access
    rm cmd/cosign/cli/verify/verify_blob_attestation_test.go # Require network access
    rm cmd/cosign/cli/verify/verify_blob_test.go # Require network access
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cosign \
      --bash <($out/bin/cosign completion bash) \
      --fish <($out/bin/cosign completion fish) \
      --zsh <($out/bin/cosign completion zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = cosign;
    command = "cosign version";
    version = "v${version}";
  };

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/sigstore/cosign/releases/tag/v${version}";
    description = "Container Signing CLI with support for ephemeral keys and Sigstore signing";
    homepage = "https://github.com/sigstore/cosign";
    license = [ licenses.asl20 ];
    mainProgram = "cosign";
    # keep-sorted end
  };
}
