{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "uds";
  version = "0.27.14";
  sha256 = "sha256-ZjLtnjSU24WgaD2MQPpM8qryYjduiQH4YQoBs9Cu88o=";
  vendorHash = "sha256-jAIO3HyZ/pQF7Jwj5AsFd4H/PPo0xnSq5D+l5AAYvfY=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    # keep-sorted start
    google = "github.com/google/go-containerregistry/cmd/crane";
    k9s = "github.com/derailed/k9s";
    uds = "github.com/defenseunicorns/uds-cli/src";
    zarf = "github.com/zarf-dev/zarf/src";
    # keep-sorted end
  };
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "defenseunicorns";
    repo = "uds-cli";
  };

  proxyVendor = true;

  preBuild = ''
    ldflags+=" -X ${flag.k9s}/cmd.version=$(go list -f '{{.Version}}' -m github.com/derailed/k9s)"
    ldflags+=" -X ${flag.google}/cmd.Version=$(go list -f '{{.Version}}' -m github.com/google/go-containerregistry)"
    ldflags+=" -X ${flag.zarf}/cmd/tools.syftVersion=$(go list -f '{{.Version}}' -m github.com/anchore/syft)"
    ldflags+=" -X ${flag.zarf}/cmd/tools.archivesVersion=$(go list -f '{{.Version}}' -m github.com/mholt/archives)"
    ldflags+=" -X ${flag.zarf}/cmd/tools.helmVersion=$(go list -f '{{.Version}}' -m helm.sh/helm/v3)"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X '${flag.uds}/config.CLIVersion=${version}'"
    "-X '${flag.zarf}/config.ActionsCommandZarfPrefix=zarf'"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall =
    ''
      mv $out/bin/uds-cli $out/bin/${pname}
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      export K9S_LOGS_DIR=$(mktemp -d)
      installShellCompletion --cmd ${pname} \
        --bash <($out/bin/${pname} completion bash) \
        --fish <($out/bin/${pname} completion fish) \
        --zsh  <($out/bin/${pname} completion zsh)
    '';

  subPackages = [ "." ];

  # Required to make shell completion to work
  #   panic: mkdir /homeless-shelter: permission denied
  HOME = "$TMPDIR";
  env.CGO_ENABLED = 0;

  meta = with lib; {
    # keep-sorted start
    description = "DevSecOps for Air Gap & Limited-Connection Systems";
    homepage = "https://github.com/defenseunicorns/uds-cli";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
