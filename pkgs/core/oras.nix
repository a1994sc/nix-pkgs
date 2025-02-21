{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  oras,
  stdenv,
  testers,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "oras";
  version = "1.2.2";
  hash = "sha256-iSmoD2HhzVrWQBaZ7HaIjcPmybl4JTVeVVfbn29i91Q=";
  vendorHash = "sha256-zxcRMrr0mfSiuZpXYe7N0nJrEmiBTgw03+Yp4PYieBY=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "oras-project";
    repo = "oras";
  };

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  excludedPackages = [ "./test/e2e" ];

  ldflags = [
    "-s"
    "-w"
    "-X oras.land/oras/internal/version.Version=${version}"
    "-X oras.land/oras/internal/version.BuildMetadata="
    "-X oras.land/oras/internal/version.GitTreeState=clean"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/${pname} --help
    $out/bin/${pname} version | grep "${version}"

    runHook postInstallCheck
  '';

  passthru.tests.version = testers.testVersion {
    package = oras;
    command = "oras version";
  };

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/oras-project/oras/releases/tag/v${version}";
    description = "ORAS project provides a way to push and pull OCI Artifacts to and from OCI Registries";
    homepage = "https://github.com/oras-project/oras";
    license = [ lib.licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
