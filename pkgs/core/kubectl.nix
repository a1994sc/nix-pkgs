{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  makeWrapper,
  rsync,
  runtimeShell,
  which,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "kubectl";
  version = "1.34.0";
  sha256 = "sha256-rKy4X01pX+kovJ8b2JHV0KuzHJ7PYZ08eDEO3GeuPoc=";
  vendorHash = null;
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "kubernetes";
    repo = "kubernetes";
  };

  outputs = [
    "out"
    "man"
    "convert"
  ];

  WHAT = lib.concatStringsSep " " [
    "cmd/${pname}"
    "cmd/${pname}-convert"
  ];

  buildPhase = ''
    runHook preBuild
    substituteInPlace "hack/update-generated-docs.sh" --replace "make" "make SHELL=${runtimeShell}"
    patchShebangs ./hack ./cluster/addons/addon-manager
    make "SHELL=${runtimeShell}" "WHAT=$WHAT"
    ./hack/update-generated-docs.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D _output/local/go/bin/kubectl -t $out/bin
    install -D _output/local/go/bin/kubectl-convert -t $convert/bin

    installManPage docs/man/man1/kubectl*

    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)

    runHook postInstall
  '';

  GOWORK = "off";

  env.CGO_ENABLED = 0;

  nativeBuildInputs = [
    makeWrapper
    which
    rsync
    installShellFiles
  ];

  doCheck = false;

  meta = with lib; {
    # keep-sorted start
    description = "Kubernetes CLI";
    homepage = "https://github.com/kubernetes/kubernetes";
    license = [ licenses.asl20 ];
    mainProgram = "kubectl";
    platforms = lib.platforms.unix;
    # keep-sorted end
  };
}
