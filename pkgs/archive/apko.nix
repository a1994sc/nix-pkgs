{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "apko";
  version = "0.30.12";
  sha256 = "sha256-+Ttriv/CG2dMttig0YjVB6BkxuCDjuLZsH92ENNom2c=";
  vendorHash = "sha256-fv313+8FUmYgC9vOXVMYk6ZbGbT4aDtQLPaJ8izX7pc=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "chainguard-dev";
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

  nativeBuildInputs = [ installShellFiles ];

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

  preCheck = ''
    # some tests require a writable HOME
    export HOME=$(mktemp -d)

    # some test data include SOURCE_DATE_EPOCH (which is different from our default)
    # and the default version info which we get by unsetting our ldflags
    export SOURCE_DATE_EPOCH=0
    ldflags=
  '';

  checkFlags = [
    # requires networking (apk.chainreg.biz)
    "-skip=TestInitDB_ChainguardDiscovery"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/apko --help
    $out/bin/apko version 2>&1 | grep "v${version}"

    runHook postInstallCheck
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/chainguard-dev/apko/blob/main/NEWS.md";
    description = "Build OCI images using APK directly without Dockerfile";
    homepage = "https://github.com/chainguard-dev/apko";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    # keep-sorted end
  };
}
