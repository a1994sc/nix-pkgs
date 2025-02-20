{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "cilium-cli";
  version = "0.17.0";
  sha256 = "sha256-fz7D0eit25WAijuekRPjGnLZnXN4Vy/dmw9X9iwfCGo=";
  vendorHash = null;
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "cilium";
    repo = pname;
  };

  nativeBuildInputs = [ installShellFiles ];

  # creates a static binary
  env.CGO_ENABLED = 0;
  # Required to workaround install check error:
  # 2022/06/25 10:36:22 Unable to start gops: mkdir /homeless-shelter: permission denied
  HOME = "$TMPDIR";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/cilium/cilium-cli/defaults.CLIVersion=${version}"
  ];

  subPackages = [ "cmd/cilium" ];

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/cilium version --client
  '';

  postInstall = ''
    installShellCompletion --cmd cilium \
      --bash <($out/bin/cilium completion bash) \
      --fish <($out/bin/cilium completion fish) \
      --zsh <($out/bin/cilium completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/cilium/cilium-cli/releases/tag/v${version}";
    description = "CLI to install, manage & troubleshoot Kubernetes clusters running Cilium";
    homepage = "https://github.com/cilium/cilium-cli";
    license = [ licenses.asl20 ];
    mainProgram = "cilium";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
