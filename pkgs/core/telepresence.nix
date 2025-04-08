{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  fuse,
  go-fuseftp,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "telepresence";
  version = "2.22.3";
  sha256 = "sha256-xrWlm5crDybvcOX3TevXcEq63Vuw0u9+4NvktIG6LxU=";
  vendorHash = "sha256-spIdC2ZV+2tm3noyEhygoblN2BjE0w75n4I3jsrg6HI=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "telepresenceio";
    repo = pname;
  };

  propagatedBuildInputs = [
    go-fuseftp
  ];

  preBuild = ''
    cp ${go-fuseftp}/bin/main ./pkg/client/remotefs/fuseftp.bits
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/telepresenceio/telepresence/v2/pkg/version.Version=${src.rev}"
  ];

  subPackages = [ "cmd/telepresence" ];

  # Required to make shell completion to work
  #   panic: mkdir /homeless-shelter: permission denied
  HOME = "$TMPDIR";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Local development against a remote Kubernetes or OpenShift cluster";
    homepage = "https://github.com/telepresenceio/telepresence";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
