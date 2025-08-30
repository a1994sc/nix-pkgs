{
  lib,
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "containerlab";
  version = "0.68.0";
  sha256 = "sha256-wV2gADDWUO0cHtCOzCTNLcT/Ir1w7ki0kpPhb3y1ImM=";
  vendorHash = "sha256-XRgKfRw6VGg+lkbtPWUVNfAk5a7ZdFwVmhjtM7uSwHs=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "srl-labs";
    repo = "containerlab";
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
    "-X github.com/srl-labs/containerlab/cmd.version=${version}"
    "-X github.com/srl-labs/containerlab/cmd.commit=${src.rev}"
  ];

  preCheck = ''
    # Fix failed TestLabelsInit test
    export USER="runner"
  '';

  preBuild = ''
    ldflags+=" -X github.com/srl-labs/containerlab/cmd.date=$(cat SOURCE_DATE_EPOCH)"
  '';

  postInstall = ''
    local INSTALL="$out/bin/containerlab"
    installShellCompletion --cmd containerlab \
      --bash <($out/bin/containerlab completion bash) \
      --fish <($out/bin/containerlab completion fish) \
      --zsh <($out/bin/containerlab completion zsh)
  '';

  meta = with lib; {
    description = "Container-based networking lab";
    homepage = "https://github.com/srl-labs/containerlab";
    changelog = "https://github.com/srl-labs/containerlab/releases/tag/${src.rev}";
    license = licenses.bsd3;
    platforms = platforms.linux;
    mainProgram = "containerlab";
  };
}
