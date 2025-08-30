{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "istioctl";
  version = "1.27.0";
  sha256 = "sha256-Rehzwr/6S1c3kzqyJIIvLO3jDTSSrkyb2HHcUn9Tco8=";
  vendorHash = "sha256-AAWGfNRAgR/Vr3VDMphOPah8a02czsf8fpWi2aeG1Jo=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit sha256;
    owner = "istio";
    repo = "istio";
    rev = version;
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  ldflags =
    let
      attrs = [
        "istio.io/istio/pkg/version.buildVersion=${version}"
        "istio.io/istio/pkg/version.buildStatus=Nix"
        "istio.io/istio/pkg/version.buildTag=${version}"
        "istio.io/istio/pkg/version.buildHub=docker.io/istio"
      ];
    in
    [
      "-s"
      "-w"
      "${lib.concatMapStringsSep " " (attr: "-X ${attr}") attrs}"
    ];

  subPackages = [ "istioctl/cmd/istioctl" ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/istioctl version --remote=false | grep ${version} > /dev/null
  '';

  postInstall = ''
    $out/bin/istioctl collateral --man --bash --zsh
    installManPage *.1
    installShellCompletion istioctl.bash
    installShellCompletion --zsh _istioctl
  '';

  env.CGO_ENABLED = 0;

  meta = with lib; {
    # keep-sorted start
    description = "Istio configuration command line utility for service operators to debug and diagnose their Istio mesh";
    homepage = "https://github.com/istio/istio";
    license = [ licenses.asl20 ];
    mainProgram = "istioctl";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
