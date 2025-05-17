{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  testers,
  kubeshark,
  nix-update-script,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "kubeshark";
  version = "52.7.0";
  sha256 = "sha256-D3mHLYN6OVk7f1MCCWqSg/3qeg83EHcpqvkm1UTOaaM=";
  vendorHash = "sha256-kzyQW4bVE7oMOlHVG7LKG1AMTRYa5GLiiEhdarIhMSo=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    kubeshark = "github.com/kubeshark/kubeshark";
  };
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "kubeshark";
    repo = pname;
  };

  ldflags = [
    "-s"
    "-w"
    "-X ${flag.kubeshark}/misc.GitCommitHash=${src.rev}"
    "-X ${flag.kubeshark}/misc.Branch=master"
    "-X ${flag.kubeshark}/misc.BuildTimestamp=0"
    "-X ${flag.kubeshark}/misc.Platform=unknown"
    "-X ${flag.kubeshark}/misc.Ver=${rev}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  checkPhase = ''
    go test ./...
  '';

  doCheck = true;

  postInstall = lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
    installShellCompletion --cmd kubeshark \
      --bash <($out/bin/kubeshark completion bash) \
      --fish <($out/bin/kubeshark completion fish) \
      --zsh <($out/bin/kubeshark completion zsh)
  '';

  passthru = {
    tests.version = testers.testVersion {
      package = kubeshark;
      command = "kubeshark version";
      inherit version;
    };
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/kubeshark/kubeshark/releases/tag/${version}";
    description = "The API Traffic Viewer for Kubernetes";
    homepage = "https://github.com/kubeshark/kubeshark";
    license = [ licenses.asl20 ];
    mainProgram = "kubeshark";
    # keep-sorted end
    longDescription = ''
      The API traffic viewer for Kubernetes providing real-time, protocol-aware visibility into Kubernetes’ internal network,
      Think TCPDump and Wireshark re-invented for Kubernetes
      capturing, dissecting and monitoring all traffic and payloads going in, out and across containers, pods, nodes and clusters.
    '';
  };
}
