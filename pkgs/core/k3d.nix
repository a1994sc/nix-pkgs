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
  pname = "k3d";
  version = "5.8.3";
  hash = "sha256-UBiDDZf/UtgPGRV9WUnoC32wc64nthBpBheEYOTp6Hk=";
  vendorHash = "sha256-lFmIRtkUiohva2Vtg4AqHaB5McVOWW5+SFShkNqYVZ8=";
  # keep-sorted end
  rev = "refs/tags/v" + version;
  versionK3S = "1.31.1+k3s1"; # renovate: depName=k3s-io/k3s
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "k3d-io";
    repo = "k3d";
  };

  deleteVendor = true;

  nativeBuildInputs = [ installShellFiles ];

  excludedPackages = [
    "tools"
    "docgen"
  ];

  ldflags =
    let
      t = "github.com/k3d-io/k3d/v${lib.versions.major version}/version";
    in
    [
      "-s"
      "-w"
      "-X ${t}.Version=v${version}"
      "-X ${t}.K3sVersion=v${builtins.replaceStrings [ "+" ] [ "-" ] versionK3S}"
    ];

  preCheck = ''
    # skip test that uses networking
    substituteInPlace version/version_test.go \
      --replace "TestGetK3sVersion" "SkipGetK3sVersion"
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/k3d --help
    $out/bin/k3d --version | grep -e "k3d version v${version}"
    runHook postInstallCheck
  '';

  env.GOWORK = "off";

  meta = with lib; {
    homepage = "https://github.com/k3d-io/k3d";
    changelog = "https://github.com/k3d-io/k3d/blob/v${version}/CHANGELOG.md";
    description = "A helper to run k3s (Lightweight Kubernetes. 5 less than k8s) in a docker container";
    mainProgram = "k3d";
    license = licenses.mit;
  };
}
