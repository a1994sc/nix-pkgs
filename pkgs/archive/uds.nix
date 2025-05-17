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
  pname = "uds";
  version = "0.27.2";
  sha256 = "sha256-eR+AF/pZLVceOswbWXyNePsj07s+s5Or1/fEu3VysJQ=";
  vendorHash = "sha256-fz/a0Oy0q3+78fPmTJnUGUkUqmA6SohbZh7mTDvgJsc=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    zarf = "github.com/defenseunicorns/zarf/src";
    uds = "github.com/defenseunicorns/uds-cli/src";
    k9s = "github.com/derailed/k9s";
    google = "github.com/google/go-containerregistry/cmd/crane";
  };
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "defenseunicorns";
    repo = "uds-cli";
  };

  nativeBuildInputs = [ installShellFiles ];

  # Required to make shell completion to work
  #   panic: mkdir /homeless-shelter: permission denied
  HOME = "$TMPDIR";
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X ${flag.uds}/config.CLIVersion=v${version}"
    "-X ${flag.zarf}/config.ActionsCommandZarfPrefix=zarf"
    "-X ${flag.k9s}/cmd.version=$(go list -f '{{.Version}}' -m github.com/derailed/k9s)"
    "-X ${flag.google}/cmd.Version=$(go list -f '{{.Version}}' -m github.com/google/go-containerregistry)"
    "-X ${flag.zarf}/cmd/tools.syftVersion=$(go list -f '{{.Version}}' -m github.com/anchore/syft)"
    "-X ${flag.zarf}/cmd/tools.archiverVersion=$(go list -f '{{.Version}}' -m github.com/mholt/archiver/v3)"
    "-X ${flag.zarf}/cmd/tools.helmVersion=$(go list -f '{{.Version}}' -m helm.sh/helm/v3)"
  ];

  subPackages = [ "." ];

  doCheck = false;

  buildPhase =
    let
      args = builtins.concatStringsSep " " ldflags;
    in
    ''
      go build -o uds -ldflags="${args}" main.go
    '';

  installPhase = ''
    install -Dm755 uds -t $out/bin
    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    export K9S_LOGS_DIR=$(mktemp -d)
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    description = "DevSecOps for Air Gap & Limited-Connection Systems";
    homepage = "https://github.com/defenseunicorns/uds-cli";
    license = [ licenses.asl20 ];
    mainProgram = "uds";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
