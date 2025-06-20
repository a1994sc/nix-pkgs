{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "eksctl";
  version = "0.210.0";
  owner = "eksctl-io";
  sha256 = "sha256-uDLm/kLilLA5AyeTQDMpbpFb1+54RlPQPRRZG9HcH0U=";
  vendorHash = "sha256-vhYexIdkn8Y5U5YZewj/O8sJCt/VimZU4E4kn0/1lU4=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256 owner;
    repo = pname;
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # 0000-00-00T00:00:00Z
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/weaveworks/eksctl/pkg/version.gitCommit=${src.rev}"
  ];

  preBuild = ''
    ldflags+=" -X github.com/weaveworks/eksctl/pkg/version.buildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  doCheck = false;

  subPackages = [ "cmd/eksctl" ];

  tags = [
    "netgo"
    "release"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/eksctl-io/eksctl/releases/tag/${src.rev}";
    description = "The official CLI for Amazon EKS";
    homepage = "https://github.com/eksctl-io/eksctl";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    # keep-sorted end
  };
}
