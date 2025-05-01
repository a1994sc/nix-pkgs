{
  # keep-sorted start
  buildGoModule,
  cosign-hauler,
  fetchFromGitHub,
  fetchurl,
  installShellFiles,
  lib,
  stdenv,
  system,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "hauler";
  version = "1.2.4";
  sha256 = "sha256-B0k8fXCj1cIhDNoO81WC+Ax5WIAFcvPM2y2jwpGOw3U=";
  vendorHash = "sha256-T3frKFu7syHapQ4ibwr+NDB5UMm5Bm1KJidjrMoH+uE=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    hauler = "github.com/rancherfederal/hauler/internal/version";
  };

  arch = if system == "x86_64-linux" then "amd64" else "arm64";
  os = if stdenv.isLinux then "linux" else "darwin";
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "hauler-dev";
    repo = pname;
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      date -u -d "@$(git log -1 --pretty=%ct)" +'%Y-%m-%dT%H:%M:%SZ' > $out/SOURCE_DATE_EPOCH
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  preBuild = ''
    mkdir -p cmd/hauler/binaries

    cp ${cosign-hauler}/bin/cosign cmd/hauler/binaries/cosign-${os}-${arch}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X '${flag.hauler}.gitTreeState=clean'"
    "-X '${flag.hauler}.gitVersion=${version}'"
    "-X ${flag.hauler}.gitCommit=$(cat COMMIT)"
    "-X ${flag.hauler}.buildDate=$(cat SOURCE_DATE_EPOCH)"
  ];

  buildPhase =
    let
      args = builtins.concatStringsSep " " ldflags;
    in
    ''
      runHook preBuild

      go build -o hauler -ldflags="${args}" cmd/hauler/main.go
    '';

  installPhase = ''
    install -Dm755 hauler -t $out/bin

    runHook postInstall
  '';

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd hauler \
      --bash <($out/bin/hauler completion bash) \
      --fish <($out/bin/hauler completion fish) \
      --zsh  <($out/bin/hauler completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Airgap Container Swiss Army Knife ";
    homepage = "https://github.com/hauler-dev/hauler";
    license = [ licenses.asl20 ];
    mainProgram = "hauler";
    # keep-sorted end
  };
}
