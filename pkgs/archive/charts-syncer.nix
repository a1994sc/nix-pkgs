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
  pname = "charts-syncer";
  version = "2.1.1";
  sha256 = "sha256-KfS5kbx096GyDBXbCg/wfcrIyT+dpaEer6FzR7QUnik=";
  vendorHash = "sha256-P8lO1ahkeBD2mFRadRvYnXK9i8K/jGkitH7mweGzmAI=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "bitnami";
    repo = pname;
  };

  nativeBuildInputs = [ installShellFiles ];

  env.GO111MODULE = "on";
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X 'main.version=${version}'"
  ];

  subPackages = [ "." ];

  doCheck = false;

  buildPhase =
    let
      args = builtins.concatStringsSep " " ldflags;
    in
    ''
      go build -o ${pname} -ldflags="${args}" ./cmd
    '';

  installPhase = ''
    install -Dm755 ${pname} -t $out/bin
    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Tool for synchronizing Helm Chart repositories. ";
    homepage = "https://github.com/bitnami/charts-syncer";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
