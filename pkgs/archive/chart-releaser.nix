{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  git,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "chart-releaser";
  version = "1.8.1";
  sha256 = "sha256-uVe40uetUiKkqMv2ZwHwAzxJVbJuQP8kFooFEBgDvVQ=";
  vendorHash = "sha256-nUqUtm7SUKNEITzFJ4gozlegqGtyiRNGKDyOqteGYTw=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "helm";
    repo = pname;
    leaveDotGit = true;
  };

  postPatch = ''
    substituteInPlace pkg/config/config.go \
      --replace "\"/etc/cr\"," "\"$out/etc/cr\","
  '';

  ldflags = [
    "-w"
    "-s"
    "-X github.com/helm/chart-testing/v3/ct/cmd.Version=${version}"
    "-X github.com/helm/chart-testing/v3/ct/cmd.GitCommit=${src.rev}"
    "-X github.com/helm/chart-testing/v3/ct/cmd.BuildDate=19700101-00:00:00"
  ];

  nativeBuildInputs = [
    installShellFiles
    git
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cr \
      --bash <($out/bin/cr completion bash) \
      --fish <($out/bin/cr completion fish) \
      --zsh  <($out/bin/cr completion zsh)
  '';

  env.CGO_ENABLED = 0;

  meta = with lib; {
    # keep-sorted start
    description = "Hosting Helm Charts via GitHub Pages and Releases ";
    homepage = "https://github.com/helm/chart-releaser";
    license = [ licenses.asl20 ];
    mainProgram = "cr";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
