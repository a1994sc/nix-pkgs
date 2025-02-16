{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  installShellFiles,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "fluxcd";
  version = "2.3.0";
  manifestsSha256 = "sha256-PdhR+UDquIJWtpSymtT6V7qO5fVJOkFz6RGzAx7xeb4=";
  sha256 = "sha256-ZQs1rWI31qDo/BgjrmiNnEdR2OL8bUHVz+j5VceEp2k=";
  vendorHash = "sha256-0YH3pgFrsnh5jIsZpj/sIgfiOCTtIlPltMS5mdGz1eM=";
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

  nativeBuildInputs = [ installShellFiles ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/flux --version | grep ${version} > /dev/null
  '';

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/flux completion $shell > flux.$shell
      installShellCompletion flux.$shell
    done
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    # keep-sorted start
    description = "Open and extensible continuous delivery solution for Kubernetes";
    downloadPage = "https://github.com/fluxcd/flux2/releases/tag/v${version}";
    homepage = "https://fluxcd.io";
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
