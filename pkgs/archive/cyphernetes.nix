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
  pname = "cyphernetes";
  version = "0.18.2";
  sha256 = "sha256-U0m0OVgxr9qGthAP/laMyEegzDm5KelFdXbLQHPxyfk=";
  vendorHash = "sha256-OsXrCh0Dzvq0zcOlCC4XGmAaKMsUF6ofFVdp8ss19j8=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "AvitalTamir";
    repo = pname;
  };

  subPackages = [ "cmd/cyphernetes" ];

  ldflags = [
    "-w"
    "-s"
  ];

  doCheck = false;

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    description = "A Kubernetes Query Language ";
    homepage = "https://github.com/AvitalTamir/cyphernetes";
    license = [ lib.licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
