{
  stdenv,
  lib,
  asciiBuildGoModule,
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
  version = "2.6.1";
  sha256 = "sha256-JQxVO7wZFyRovst3qb0EErDyIIhPNsIpBq/iQVf6djY=";
  vendorHash = "sha256-7qVJMQI5htqMavrxFP2lQfQ/7b27bRWnNYg2cHmTZYE=";
  # keep-sorted end
  rev = "refs/tags/v" + version;
in
asciiBuildGoModule {
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

  # failed to get CTLog public keys from TUF: creating cached local store: mkdir /homeless-shelter: permission denied
  HOME = "$TMPDIR";

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
    rm pkg/cosign/verify_sct_test.go # Require network access
    rm pkg/cosign/verify_test.go # Require network access
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
