{
  # keep-sorted start
  buildGoModule,
  clusterctl,
  fetchFromGitHub,
  installShellFiles,
  lib,
  stdenv,
  testers,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "clusterctl";
  version = "1.10.3";
  sha256 = "sha256-xbmhvGCSrGDX/sgq4T7tcWwY8gckXnTk79ukjYjdDig=";
  vendorHash = "sha256-zNYChnY5U31pWCdtjv6HIivmkJoxWbqpmWqmUlb2gw8=";
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

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # errors attempting to write config to read-only $HOME
    export HOME=$TMPDIR

    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --zsh  <($out/bin/${pname} completion zsh)
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
