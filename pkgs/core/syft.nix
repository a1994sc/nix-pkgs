{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "syft";
  version = "1.19.0";
  hash = "sha256-mO4mRMLoYA5WjDsA4FbMd/RLbQOekXKikl1zlZNKYtk=";
  vendorHash = "sha256-KmMES19mGgtSeGw31DqZQm9wp0y+nu3P2LTZh9ofCPM=";
  # keep-sorted end
  rev = "refs/tags/v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "anchore";
    repo = "syft";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # 0000-00-00T00:00:00Z
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  proxyVendor = true;

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  subPackages = [ "cmd/syft" ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${version}"
    "-X=main.gitDescription=v${version}"
    "-X=main.gitTreeState=clean"
  ];

  postPatch = ''
    # Don't check for updates.
    substituteInPlace cmd/syft/internal/options/update_check.go \
      --replace-fail "CheckForAppUpdate: true" "CheckForAppUpdate: false"
  '';

  preBuild = ''
    ldflags+=" -X main.gitCommit=$(cat COMMIT)"
    ldflags+=" -X main.buildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  # tests require a running docker instance
  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd syft \
      --bash <($out/bin/syft completion bash) \
      --fish <($out/bin/syft completion fish) \
      --zsh <($out/bin/syft completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/syft --help
    $out/bin/syft version | grep "${version}"

    runHook postInstallCheck
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/anchore/syft/releases/tag/v${version}";
    description = "CLI tool and library for generating a Software Bill of Materials from container images and filesystems";
    homepage = "https://github.com/anchore/syft";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
