{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "fluxcd";
  version = "2.6.2";
  manifestsSha256 = "sha256-KXvYURCJ1/BI61jes0Pvy6giKvVmosWOHuzGRHCcqZo=";
  sha256 = "sha256-0Q8U7i1hK2CVWia3t/ayjIzjNjHurhkRGO0oLHLNMH4=";
  vendorHash = "sha256-LS2qgukhLk6nrjkp5Y00B0N/LFLzOUR/TC3qD80WZAQ=";
  # keep-sorted end
  rev = "v" + version;
  manifests = fetchzip {
    url = "https://github.com/fluxcd/flux2/releases/download/v${version}/manifests.tar.gz";
    sha256 = manifestsSha256;
    stripRoot = false;
  };
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "fluxcd";
    repo = "flux2";
  };

  postUnpack = ''
    cp -r ${manifests} source/cmd/flux/manifests

    # disable tests that require network access
    rm source/cmd/flux/create_secret_git_test.go
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.VERSION=${version}"
  ];

  subPackages = [ "cmd/flux" ];

  # Required to workaround test error:
  #   panic: mkdir /homeless-shelter: permission denied
  HOME = "$TMPDIR";
  env.CGO_ENABLED = 0;

  nativeBuildInputs = [ installShellFiles ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/flux --version | grep ${version} > /dev/null
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd flux \
      --bash <($out/bin/flux completion bash) \
      --fish <($out/bin/flux completion fish) \
      --zsh  <($out/bin/flux completion zsh)
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    # keep-sorted start
    description = "Open and extensible continuous delivery solution for Kubernetes";
    downloadPage = "https://github.com/fluxcd/flux2/releases/tag/v${version}";
    homepage = "https://github.com/fluxcd/flux2";
    license = [ licenses.asl20 ];
    mainProgram = "flux";
    # keep-sorted end
    longDescription = ''
      Flux is a tool for keeping Kubernetes clusters in sync
      with sources of configuration (like Git repositories), and automating
      updates to configuration when there is new code to deploy.
    '';
  };
}
