{
  # keep-sorted start
  buildGoModule,
  clusterctl,
  fetchFromGitHub,
  installShellFiles,
  lib,
  testers,
# keep-sorted end
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "clusterctl";
  version = "1.9.5";
  sha256 = "sha256-4n+7/4ZMD0VzlD4PzEWVDut+rt8/4Vz3gAgCDAj+SVs=";
  vendorHash = "sha256-SdLeME6EFraGUXE1zUdEfxTETUKLDmecYpWEg5DE4PQ=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "kubernetes-sigs";
    repo = "cluster-api";
  };

  subPackages = [ "cmd/clusterctl" ];

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  ldflags =
    let
      t = "sigs.k8s.io/cluster-api/version";
    in
    [
      "-X ${t}.gitMajor=${lib.versions.major version}"
      "-X ${t}.gitMinor=${lib.versions.minor version}"
      "-X ${t}.gitVersion=v${version}"
    ];

  postInstall = ''
    # errors attempting to write config to read-only $HOME
    export HOME=$TMPDIR

    installShellCompletion --cmd clusterctl \
      --bash <($out/bin/clusterctl completion bash) \
      --zsh <($out/bin/clusterctl completion zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = clusterctl;
    command = "HOME=$TMPDIR clusterctl version";
    version = "v${version}";
  };

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/kubernetes-sigs/cluster-api/releases/tag/${src.rev}";
    description = "Kubernetes cluster API tool";
    homepage = "https://github.com/kubernetes-sigs/cluster-api";
    license = [ lib.licenses.asl20 ];
    mainProgram = "clusterctl";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
