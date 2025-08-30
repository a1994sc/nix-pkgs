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
  version = "2.4.2+hauler.1";
  sha256 = "sha256-gZo7PxX66gO/ACrhQaGD4ws1r0VD589uTTpg6NoWBi8=";
  vendorHash = "sha256-uEeQohqXjHQr1y74pB+oPWq+Ov2Vnpi+fj5GlA9EgTw=";
  # keep-sorted end
  rev = "refs/tags/v" + version;
in
asciiBuildGoModule {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "hauler-dev";
    repo = pname;
    # populate values that require us to use git. By doing this in postFetch we
    # can delete .git afterwards and maintain better reproducibility of the src.
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # '0000-00-00T00:00:00Z'
      date -u -d "@$(git log -1 --pretty=%ct)" "+'%Y-%m-%dT%H:%M:%SZ'" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
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

  # ldflags based on metadata from git and source
  preBuild = ''
    ldflags+=" -X sigs.k8s.io/release-utils/version.gitCommit=$(cat COMMIT)"
    ldflags+=" -X sigs.k8s.io/release-utils/version.buildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  __darwinAllowLocalNetworking = true;

  preCheck = ''
    # test all paths
    unset subPackages

    rm pkg/cosign/ctlog_test.go # Require network access
    rm pkg/cosign/tlog_test.go # Require network access
    rm cmd/cosign/cli/verify/verify_test.go # Require network access
    rm cmd/cosign/cli/verify/verify_blob_attestation_test.go # Require network access
    rm cmd/cosign/cli/verify/verify_blob_test.go # Require network access
    rm cmd/cosign/cli/version_test.go # Broken test
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
    changelog = "https://github.com/hauler-dev/cosign/releases/tag/v${version}";
    description = "Hauler Fork - Container Signing CLI with support for ephemeral keys and Sigstore signing";
    homepage = "https://github.com/hauler-dev/cosign";
    license = [ licenses.asl20 ];
    mainProgram = "cosign";
    # keep-sorted end
  };
}
