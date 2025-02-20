{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "gwctl";
  version = "0.1.0";
  sha256 = "sha256-8MaCijC1YDE2tgkhS+reonUUegB6WmWn/aWe0PhqsrM=";
  vendorHash = "sha256-ZS9/L1UA/o5DtRCNyLoN4dsvSkUKxroY40UBe9Q11tk=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "kubernetes-sigs";
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
    "-X sigs.k8s.io/gwctl/pkg/version.version=${rev}"
  ];

  # ldflags based on metadata from git and source
  preBuild = ''
    ldflags+=" -X sigs.k8s.io/gwctl/pkg/version.gitCommit=$(cat COMMIT)"
    ldflags+=" -X sigs.k8s.io/gwctl/pkg/version.buildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  meta = with lib; {
    # keep-sorted start
    description = "gwctl is a command-line tool for managing and understanding Gateway API resources in your Kubernetes cluster. ";
    homepage = "https://github.com/kubernetes-sigs/gwctl";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    # keep-sorted end
  };
}
